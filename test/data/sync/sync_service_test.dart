import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/data/local/app_database.dart';
import 'package:prestamo_equipos/data/remote/solicitud_remote_data_source.dart';
import 'package:prestamo_equipos/data/repositories/solicitud_repository.dart';
import 'package:prestamo_equipos/data/sync/sync_service.dart';
import 'package:prestamo_equipos/domain/models/equipo.dart';
import 'package:prestamo_equipos/domain/models/estado_solicitud.dart';
import 'package:prestamo_equipos/domain/models/franja.dart';
import 'package:prestamo_equipos/domain/models/solicitud.dart';

import '../../helpers/base_en_memoria.dart';

class _RemoteProgramable implements SolicitudRemoteDataSource {
  final List<ResultadoEnvio> respuestas = [];
  final List<String> enviados = [];
  Future<void> Function()? antesDeResponder;

  @override
  Future<ResultadoEnvio> enviarNueva(
    Solicitud solicitud, {
    required String equipoNombre,
  }) async {
    enviados.add(solicitud.id);
    await antesDeResponder?.call();
    return respuestas.isEmpty
        ? const EnvioConfirmado(EstadoSolicitud.solicitado)
        : respuestas.removeAt(0);
  }
}

void main() {
  final ahora = DateTime(2026, 11, 10, 9);
  const laptop = Equipo(
    id: 'eq-1',
    nombre: 'Portátil Lenovo',
    categoria: 'Portátiles',
    descripcion: '',
    imagenUrl: '',
  );
  Franja franja(SlotHorario slot) =>
      Franja(fecha: DateTime(2026, 11, 11), slot: slot);

  late AppDatabase db;
  late SolicitudRepository repo;

  setUp(() {
    db = baseEnMemoria();
    repo = SolicitudRepository(db: db, reloj: () => ahora);
  });

  tearDown(() => db.close());

  Future<Solicitud> local(String uid) async =>
      (await repo.observarMisSolicitudes(uid).first).single.solicitud;

  group('SyncService con Firestore simulado', () {
    late FakeFirebaseFirestore firestore;
    late SyncService sync;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      sync = SyncService(
        repository: repo,
        remote: FirestoreSolicitudRemote(firestore: firestore),
      );
    });

    test('sube la solicitud pendiente y la marca sincronizada', () async {
      final creada = await repo.crearSolicitud(
        ownerUid: 'uid-ana',
        equipo: laptop,
        franja: franja(SlotHorario.manana1),
      );

      final resumen = await sync.sincronizar('uid-ana');

      expect(resumen.enviadas, 1);
      final doc = await firestore
          .collection('solicitudes')
          .doc(creada.solicitud.id)
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['estado'], 'SOLICITADO');
      expect(doc.data()!['solicitanteUid'], 'uid-ana');
      expect(doc.data()!['franjaId'], 'eq-1_20261111_08-10');
      expect((await local('uid-ana')).estadoSync, EstadoSync.sincronizado);
    });

    test('al sincronizar queda SOLICITADO, nunca APROBADO', () async {
      await repo.crearSolicitud(
        ownerUid: 'uid-ana',
        equipo: laptop,
        franja: franja(SlotHorario.manana1),
      );
      await sync.sincronizar('uid-ana');
      expect((await local('uid-ana')).estado, EstadoSolicitud.solicitado);
    });

    test('reintentar no duplica la solicitud en Firestore', () async {
      final creada = await repo.crearSolicitud(
        ownerUid: 'uid-ana',
        equipo: laptop,
        franja: franja(SlotHorario.manana1),
      );
      await sync.sincronizar('uid-ana');
      await repo.volverAIntentar(creada.solicitud.id);
      await sync.sincronizar('uid-ana');

      final todas = await firestore.collection('solicitudes').get();
      expect(todas.docs, hasLength(1));
    });

    test(
      'un reintento no sobrescribe la aprobación hecha por el coordinador',
      () async {
        final creada = await repo.crearSolicitud(
          ownerUid: 'uid-ana',
          equipo: laptop,
          franja: franja(SlotHorario.manana1),
        );
        await firestore.collection('solicitudes').doc(creada.solicitud.id).set({
          'solicitanteUid': 'uid-ana',
          'estado': 'APROBADO',
        });

        await sync.sincronizar('uid-ana');

        final doc = await firestore
            .collection('solicitudes')
            .doc(creada.solicitud.id)
            .get();
        expect(doc.data()!['estado'], 'APROBADO');
        final s = await local('uid-ana');
        expect(s.estado, EstadoSolicitud.aprobado);
        expect(s.estadoSync, EstadoSync.sincronizado);
      },
    );

    test('no sube los pendientes de otra cuenta', () async {
      await repo.crearSolicitud(
        ownerUid: 'uid-ana',
        equipo: laptop,
        franja: franja(SlotHorario.manana1),
      );
      await repo.crearSolicitud(
        ownerUid: 'uid-luis',
        equipo: laptop,
        franja: franja(SlotHorario.tarde1),
      );

      await sync.sincronizar('uid-luis');

      final subidas = await firestore.collection('solicitudes').get();
      expect(subidas.docs.map((d) => d.data()['solicitanteUid']), ['uid-luis']);
      expect((await local('uid-ana')).estadoSync, EstadoSync.pendiente);
    });
  });

  group('SyncService ante errores', () {
    late _RemoteProgramable remote;
    late SyncService sync;

    setUp(() {
      remote = _RemoteProgramable();
      sync = SyncService(repository: repo, remote: remote);
    });

    test(
      'un fallo temporal deja la solicitud pendiente con el motivo',
      () async {
        await repo.crearSolicitud(
          ownerUid: 'u',
          equipo: laptop,
          franja: franja(SlotHorario.manana1),
        );
        remote.respuestas.add(const EnvioFalloTemporal('Sin conexión'));

        final resumen = await sync.sincronizar('u');

        expect(resumen.pendientes, 1);
        final s = await local('u');
        expect(s.estadoSync, EstadoSync.pendiente);
        expect(s.ultimoError, 'Sin conexión');

        await sync.sincronizar('u');
        expect((await local('u')).estadoSync, EstadoSync.sincronizado);
        expect((await local('u')).ultimoError, isNull);
      },
    );

    test('un rechazo se conserva y no se reenvía solo', () async {
      await repo.crearSolicitud(
        ownerUid: 'u',
        equipo: laptop,
        franja: franja(SlotHorario.manana1),
      );
      remote.respuestas.add(const EnvioRechazado('Permiso denegado'));

      await sync.sincronizar('u');
      await sync.sincronizar('u');

      expect(remote.enviados, hasLength(1));
      final s = await local('u');
      expect(s.estadoSync, EstadoSync.rechazado);
      expect(s.ultimoError, 'Permiso denegado');
    });

    test('el usuario puede descartar una solicitud rechazada', () async {
      final creada = await repo.crearSolicitud(
        ownerUid: 'u',
        equipo: laptop,
        franja: franja(SlotHorario.manana1),
      );
      remote.respuestas.add(const EnvioRechazado('Permiso denegado'));
      await sync.sincronizar('u');

      expect(
        await repo.descartarRechazada(
          id: creada.solicitud.id,
          ownerUid: 'otro',
        ),
        isFalse,
      );
      expect(
        await repo.descartarRechazada(id: creada.solicitud.id, ownerUid: 'u'),
        isTrue,
      );
      expect(await repo.observarMisSolicitudes('u').first, isEmpty);
    });

    test(
      'una edición local posterior al envío no se marca sincronizada',
      () async {
        final creada = await repo.crearSolicitud(
          ownerUid: 'u',
          equipo: laptop,
          franja: franja(SlotHorario.manana1),
        );
        remote.antesDeResponder = () async {
          await db.actualizarSolicitud(
            creada.solicitud.id,
            const SolicitudesCompanion(version: Value(2)),
          );
        };

        final resumen = await sync.sincronizar('u');

        expect(resumen.enviadas, 0);
        expect((await local('u')).estadoSync, EstadoSync.pendiente);
      },
    );

    test(
      'dos llamadas simultáneas comparten la misma sincronización',
      () async {
        await repo.crearSolicitud(
          ownerUid: 'u',
          equipo: laptop,
          franja: franja(SlotHorario.manana1),
        );
        final a = sync.sincronizar('u');
        final b = sync.sincronizar('u');
        await Future.wait([a, b]);

        expect(remote.enviados, hasLength(1));
      },
    );

    test('avisa cuando se recupera la conexión', () async {
      final red = StreamController<List<ConnectivityResult>>();
      final s = SyncService(
        repository: repo,
        remote: remote,
        cambiosConectividad: red.stream,
      );
      final eventos = <void>[];
      final sub = s.conexionRecuperada.listen(eventos.add);

      red.add([ConnectivityResult.none]);
      red.add([ConnectivityResult.wifi]);
      red.add([ConnectivityResult.wifi, ConnectivityResult.mobile]);
      red.add([ConnectivityResult.none]);
      red.add([ConnectivityResult.mobile]);
      await Future<void>.delayed(Duration.zero);

      expect(eventos, hasLength(2));
      await sub.cancel();
      await red.close();
    });
  });

  group('FirestoreSolicitudRemote.clasificarError', () {
    test('errores de red son temporales', () {
      expect(
        FirestoreSolicitudRemote.clasificarError('unavailable'),
        isA<EnvioFalloTemporal>(),
      );
      expect(
        FirestoreSolicitudRemote.clasificarError('deadline-exceeded'),
        isA<EnvioFalloTemporal>(),
      );
    });

    test('permisos y datos inválidos son rechazos', () {
      expect(
        FirestoreSolicitudRemote.clasificarError('permission-denied'),
        isA<EnvioRechazado>(),
      );
      expect(
        FirestoreSolicitudRemote.clasificarError('invalid-argument'),
        isA<EnvioRechazado>(),
      );
    });
  });

  test('ResumenSync describe el resultado', () {
    expect(
      const ResumenSync(enviadas: 2, rechazadas: 1).descripcion,
      '2 sincronizadas, 1 rechazada por el servidor.',
    );
    expect(
      const ResumenSync().descripcion,
      'No hay solicitudes pendientes de sincronizar.',
    );
  });
}
