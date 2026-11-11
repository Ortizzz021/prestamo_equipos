import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/data/local/app_database.dart';
import 'package:prestamo_equipos/data/remote/solicitud_remote_data_source.dart';
import 'package:prestamo_equipos/data/remote/solicitud_seguimiento_remote_data_source.dart';
import 'package:prestamo_equipos/data/repositories/solicitud_repository.dart';
import 'package:prestamo_equipos/data/sync/sync_service.dart';
import 'package:prestamo_equipos/domain/models/equipo.dart';
import 'package:prestamo_equipos/domain/models/estado_solicitud.dart';
import 'package:prestamo_equipos/domain/models/franja.dart';
import 'package:prestamo_equipos/domain/models/solicitud.dart';

import '../../helpers/base_en_memoria.dart';

void main() {
  final ahora = DateTime(2026, 11, 11, 9);
  const laptop = Equipo(
    id: 'eq-1',
    nombre: 'Portátil Lenovo',
    categoria: 'Portátiles',
    descripcion: '',
    imagenUrl: '',
  );
  final franja = Franja(
    fecha: DateTime(2026, 11, 12),
    slot: SlotHorario.manana1,
  );

  late AppDatabase db;
  late SolicitudRepository repo;
  late FakeFirebaseFirestore firestore;

  setUp(() {
    db = baseEnMemoria();
    repo = SolicitudRepository(db: db, reloj: () => ahora);
    firestore = FakeFirebaseFirestore();
  });

  tearDown(() => db.close());

  SyncService crearSync({String? Function()? uidActual}) => SyncService(
    repository: repo,
    remote: FirestoreSolicitudRemote(firestore: firestore),
    seguimiento: FirestoreSolicitudSeguimiento(firestore: firestore),
    uidActual: uidActual,
  );

  Map<String, dynamic> docRemoto({
    required String solicitante,
    required String estado,
    int version = 1,
    String? observacionEntrega,
    String? observacionDevolucion,
  }) => {
    'solicitanteUid': solicitante,
    'equipoId': 'eq-1',
    'equipoNombre': 'Portátil Lenovo',
    'fecha': Timestamp.fromDate(DateTime(2026, 11, 12)),
    'slot': '08-10',
    'estado': estado,
    'version': version,
    'creadaEn': Timestamp.fromDate(ahora),
    'actualizadaEn': Timestamp.fromDate(ahora),
    'observacionEntrega': ?observacionEntrega,
    'observacionDevolucion': ?observacionDevolucion,
  };

  Future<Solicitud> local(String uid) async =>
      (await repo.observarMisSolicitudes(uid).first).single.solicitud;

  Future<void> esperarEventos() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  test('el solicitante ve la aprobación hecha por el coordinador', () async {
    final sync = crearSync();
    final creada = await repo.crearSolicitud(
      ownerUid: 'uid-ana',
      equipo: laptop,
      franja: franja,
    );
    await sync.sincronizar('uid-ana');
    final escucha = sync.escucharCambiosRemotos('uid-ana');

    await firestore.collection('solicitudes').doc(creada.solicitud.id).update({
      'estado': 'APROBADO',
      'version': 2,
    });
    await esperarEventos();

    final s = await local('uid-ana');
    expect(s.estado, EstadoSolicitud.aprobado);
    expect(s.version, 2);
    expect(s.estadoSync, EstadoSync.sincronizado);
    await escucha.cancel();
  });

  test(
    'tras la devolución el solicitante ve el estado final y las observaciones',
    () async {
      final sync = crearSync();
      final creada = await repo.crearSolicitud(
        ownerUid: 'uid-ana',
        equipo: laptop,
        franja: franja,
      );
      await sync.sincronizar('uid-ana');
      final escucha = sync.escucharCambiosRemotos('uid-ana');

      await firestore
          .collection('solicitudes')
          .doc(creada.solicitud.id)
          .update({
            'estado': 'DEVUELTO',
            'version': 4,
            'observacionEntrega': 'Con cargador',
            'observacionDevolucion': 'Sin daños',
          });
      await esperarEventos();

      final s = await local('uid-ana');
      expect(s.estado, EstadoSolicitud.devuelto);
      expect(s.observacionEntrega, 'Con cargador');
      expect(s.observacionDevolucion, 'Sin daños');
      await escucha.cancel();
    },
  );

  test('una solicitud creada en otro dispositivo se guarda en Drift', () async {
    await firestore
        .collection('solicitudes')
        .doc('sol-remota')
        .set(docRemoto(solicitante: 'uid-ana', estado: 'SOLICITADO'));
    final escucha = crearSync().escucharCambiosRemotos('uid-ana');
    await esperarEventos();

    final lista = await repo.observarMisSolicitudes('uid-ana').first;
    expect(lista.single.solicitud.id, 'sol-remota');
    expect(lista.single.solicitud.estadoSync, EstadoSync.sincronizado);
    expect(lista.single.equipoNombre, 'Portátil Lenovo');
    await escucha.cancel();
  });

  test('no escucha ni guarda solicitudes de otra cuenta', () async {
    await firestore
        .collection('solicitudes')
        .doc('de-luis')
        .set(docRemoto(solicitante: 'uid-luis', estado: 'SOLICITADO'));
    final escucha = crearSync().escucharCambiosRemotos('uid-ana');
    await esperarEventos();

    expect(await repo.observarMisSolicitudes('uid-ana').first, isEmpty);
    expect(await repo.observarMisSolicitudes('uid-luis').first, isEmpty);
    await escucha.cancel();
  });

  test(
    'un cambio remoto no pisa una edición local más reciente sin enviar',
    () async {
      final creada = await repo.crearSolicitud(
        ownerUid: 'uid-ana',
        equipo: laptop,
        franja: franja,
      );
      await db.actualizarSolicitud(
        creada.solicitud.id,
        const SolicitudesCompanion(version: Value(3)),
      );

      final cambio = await repo.aplicarRemota(
        ownerUid: 'uid-ana',
        remota: SolicitudRemota.desdeFirestore(
          creada.solicitud.id,
          docRemoto(solicitante: 'uid-ana', estado: 'SOLICITADO', version: 2),
        )!,
      );

      expect(cambio, isFalse);
      final s = await local('uid-ana');
      expect(s.version, 3);
      expect(s.estadoSync, EstadoSync.pendiente);
    },
  );

  test('aplicarRemota ignora un documento de otro solicitante', () async {
    final remota = SolicitudRemota.desdeFirestore(
      'x',
      docRemoto(solicitante: 'uid-luis', estado: 'APROBADO'),
    )!;
    expect(
      await repo.aplicarRemota(ownerUid: 'uid-ana', remota: remota),
      isFalse,
    );
    expect(await repo.observarMisSolicitudes('uid-luis').first, isEmpty);
  });

  test('un documento remoto incompleto se descarta sin romper la escucha', () {
    expect(
      SolicitudRemota.desdeFirestore('a', {'estado': 'SOLICITADO'}),
      isNull,
    );
    expect(
      SolicitudRemota.desdeFirestore(
        'b',
        docRemoto(solicitante: 'u', estado: 'INVENTADO'),
      ),
      isNull,
    );
  });

  group('cambio de cuenta', () {
    test('no sube pendientes si la sesión activa es de otra cuenta', () async {
      var sesion = 'uid-luis';
      final sync = crearSync(uidActual: () => sesion);
      await repo.crearSolicitud(
        ownerUid: 'uid-ana',
        equipo: laptop,
        franja: franja,
      );

      final resumen = await sync.sincronizar('uid-ana');

      expect(resumen.enviadas, 0);
      expect((await firestore.collection('solicitudes').get()).docs, isEmpty);
      expect((await local('uid-ana')).estadoSync, EstadoSync.pendiente);

      sesion = 'uid-ana';
      await sync.sincronizar('uid-ana');
      expect(
        (await firestore.collection('solicitudes').get()).docs,
        hasLength(1),
      );
    });

    test('cada cuenta solo ve sus solicitudes locales', () async {
      await repo.crearSolicitud(
        ownerUid: 'uid-ana',
        equipo: laptop,
        franja: franja,
      );
      await repo.crearSolicitud(
        ownerUid: 'uid-luis',
        equipo: laptop,
        franja: franja,
      );

      final deAna = await repo.observarMisSolicitudes('uid-ana').first;
      final deLuis = await repo.observarMisSolicitudes('uid-luis').first;

      expect(deAna.single.solicitud.solicitanteUid, 'uid-ana');
      expect(deLuis.single.solicitud.solicitanteUid, 'uid-luis');
    });
  });
}
