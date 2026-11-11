import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/core/errors/regla_negocio_exception.dart';
import 'package:prestamo_equipos/data/local/app_database.dart';
import 'package:prestamo_equipos/data/remote/solicitud_cancelacion_remote_data_source.dart';
import 'package:prestamo_equipos/data/remote/solicitud_remote_data_source.dart';
import 'package:prestamo_equipos/data/repositories/solicitud_repository.dart';
import 'package:prestamo_equipos/data/sync/sync_service.dart';
import 'package:prestamo_equipos/domain/models/equipo.dart';
import 'package:prestamo_equipos/domain/models/estado_solicitud.dart';
import 'package:prestamo_equipos/domain/models/franja.dart';
import 'package:prestamo_equipos/domain/models/solicitud.dart';

import '../../helpers/base_en_memoria.dart';

void main() {
  final ahora = DateTime(2026, 11, 10, 9);
  const equipo = Equipo(
    id: 'equipo-1',
    nombre: 'Portátil de prueba',
    categoria: 'Portátiles',
    descripcion: '',
    imagenUrl: '',
  );
  final franja = Franja(
    fecha: DateTime(2026, 11, 20),
    slot: SlotHorario.manana1,
  );

  late FakeFirebaseFirestore firestore;
  late AppDatabase db;
  late SolicitudRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    db = baseEnMemoria();
    repository = SolicitudRepository(
      db: db,
      reloj: () => ahora,
      cancelacionRemote: SolicitudCancelacionRemoteDataSource(
        firestore: firestore,
        reloj: () => ahora,
      ),
    );
  });

  tearDown(() => db.close());

  test('cancela localmente si no existe en Firestore y no la sincroniza', () async {
    final creada = await repository.crearSolicitud(
      ownerUid: 'uid-solicitante',
      equipo: equipo,
      franja: franja,
    );

    final sincronizada = await repository.cancelarSolicitud(
      id: creada.solicitud.id,
      ownerUid: 'uid-solicitante',
    );

    final local = await repository.observarMisSolicitudes('uid-solicitante').first;
    expect(sincronizada, isFalse);
    expect(local.single.solicitud.estado, EstadoSolicitud.cancelado);
    expect(local.single.solicitud.estadoSync, EstadoSync.pendiente);
    expect(await repository.pendientesDeEnvio('uid-solicitante'), isEmpty);
    final remote = _RemotePrueba();
    await SyncService(repository: repository, remote: remote).sincronizar(
      'uid-solicitante',
    );
    expect(remote.llamadas, 0);
  });

  test('cancela una solicitud sincronizada en SOLICITADO', () async {
    final creada = await _crearLocalSincronizada(
      repository: repository,
      equipo: equipo,
      franja: franja,
      ahora: ahora,
    );
    await _crearRemota(
      firestore: firestore,
      id: creada.solicitud.id,
      estado: 'SOLICITADO',
      equipo: equipo,
      franja: franja,
      ahora: ahora,
    );

    final sincronizada = await repository.cancelarSolicitud(
      id: creada.solicitud.id,
      ownerUid: 'uid-solicitante',
    );

    final remota = await firestore
        .collection('solicitudes')
        .doc(creada.solicitud.id)
        .get();
    final local = await repository.observarMisSolicitudes('uid-solicitante').first;
    expect(sincronizada, isTrue);
    expect(remota.data()?['estado'], 'CANCELADO');
    expect(remota.data()?['canceladaEn'], isA<Timestamp>());
    expect(remota.data()?['version'], 2);
    expect(local.single.solicitud.estado, EstadoSolicitud.cancelado);
    expect(local.single.solicitud.estadoSync, EstadoSync.sincronizado);
  });

  test('cancelar una solicitud APROBADO elimina su franja', () async {
    final creada = await _crearLocalSincronizada(
      repository: repository,
      equipo: equipo,
      franja: franja,
      ahora: ahora,
      estadoLocal: EstadoSolicitud.aprobado,
    );
    await _crearRemota(
      firestore: firestore,
      id: creada.solicitud.id,
      estado: 'APROBADO',
      equipo: equipo,
      franja: franja,
      ahora: ahora,
    );
    await firestore.collection('franjas').doc(franja.idOcupacion(equipo.id)).set({
      'equipoId': equipo.id,
      'fechaClave': franja.fechaClave,
      'slot': franja.slot.codigo,
      'solicitudId': creada.solicitud.id,
    });

    await repository.cancelarSolicitud(
      id: creada.solicitud.id,
      ownerUid: 'uid-solicitante',
    );

    final franjaRemota = await firestore
        .collection('franjas')
        .doc(franja.idOcupacion(equipo.id))
        .get();
    expect(franjaRemota.exists, isFalse);
  });

  test('no se puede cancelar una solicitud ENTREGADO', () async {
    final creada = await _crearLocalSincronizada(
      repository: repository,
      equipo: equipo,
      franja: franja,
      ahora: ahora,
    );
    await _crearRemota(
      firestore: firestore,
      id: creada.solicitud.id,
      estado: 'ENTREGADO',
      equipo: equipo,
      franja: franja,
      ahora: ahora,
    );

    await expectLater(
      repository.cancelarSolicitud(
        id: creada.solicitud.id,
        ownerUid: 'uid-solicitante',
      ),
      throwsA(
        isA<ReglaNegocioException>().having(
          (error) => error.codigo,
          'codigo',
          'ESTADO_NO_CANCELABLE',
        ),
      ),
    );
  });

  test('otro usuario no puede cancelar la solicitud', () async {
    final creada = await _crearLocalSincronizada(
      repository: repository,
      equipo: equipo,
      franja: franja,
      ahora: ahora,
    );
    await _crearRemota(
      firestore: firestore,
      id: creada.solicitud.id,
      estado: 'SOLICITADO',
      equipo: equipo,
      franja: franja,
      ahora: ahora,
    );
    final remote = SolicitudCancelacionRemoteDataSource(
      firestore: firestore,
      reloj: () => ahora,
    );

    await expectLater(
      remote.cancelar(
        solicitudId: creada.solicitud.id,
        solicitanteUid: 'uid-otro',
      ),
      throwsA(
        isA<ReglaNegocioException>().having(
          (error) => error.codigo,
          'codigo',
          'NO_ES_DUENO',
        ),
      ),
    );
  });

}

class _RemotePrueba implements SolicitudRemoteDataSource {
  var llamadas = 0;

  @override
  Future<ResultadoEnvio> enviarNueva(
    Solicitud solicitud, {
    required String equipoNombre,
  }) async {
    llamadas++;
    return const EnvioConfirmado(EstadoSolicitud.solicitado);
  }
}

Future<MiSolicitud> _crearLocalSincronizada({
  required SolicitudRepository repository,
  required Equipo equipo,
  required Franja franja,
  required DateTime ahora,
  EstadoSolicitud estadoLocal = EstadoSolicitud.solicitado,
}) async {
  final creada = await repository.crearSolicitud(
    ownerUid: 'uid-solicitante',
    equipo: equipo,
    franja: franja,
  );
  await repository.confirmarEnvio(
    id: creada.solicitud.id,
    versionEnviada: creada.solicitud.version,
    estadoRemoto: estadoLocal,
  );
  return creada;
}

Future<void> _crearRemota({
  required FakeFirebaseFirestore firestore,
  required String id,
  required String estado,
  required Equipo equipo,
  required Franja franja,
  required DateTime ahora,
}) async {
  await firestore.collection('solicitudes').doc(id).set({
    'id': id,
    'solicitanteUid': 'uid-solicitante',
    'equipoId': equipo.id,
    'equipoNombre': equipo.nombre,
    'fecha': Timestamp.fromDate(franja.fecha),
    'fechaClave': franja.fechaClave,
    'slot': franja.slot.codigo,
    'franjaId': franja.idOcupacion(equipo.id),
    'estado': estado,
    'version': 1,
    'creadaEn': Timestamp.fromDate(ahora),
    'actualizadaEn': Timestamp.fromDate(ahora),
  });
}
