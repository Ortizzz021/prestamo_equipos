import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/core/errors/regla_negocio_exception.dart';
import 'package:prestamo_equipos/data/remote/coordinacion_remote_data_source.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CoordinacionRemoteDataSource source;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    source = CoordinacionRemoteDataSource(
      firestore: firestore,
      reloj: () => DateTime(2026, 11, 10),
    );
  });

  test('aprobar ocupa la franja y actualiza la solicitud', () async {
    await _crearSolicitud(firestore, 'sol-1');

    await source.aprobar('sol-1', 'coord-1');

    final solicitud = await firestore.collection('solicitudes').doc('sol-1').get();
    final franja = await firestore
        .collection('franjas')
        .doc('equipo-1_20261120_08-10')
        .get();
    expect(solicitud.data()?['estado'], 'APROBADO');
    expect(solicitud.data()?['aprobadoPor'], 'coord-1');
    expect(solicitud.data()?['version'], 2);
    expect(franja.exists, isTrue);
    expect(franja.data()?['solicitudId'], 'sol-1');
  });

  test('la segunda aprobación para una franja falla con FRANJA_OCUPADA', () async {
    await _crearSolicitud(firestore, 'sol-1');
    await _crearSolicitud(firestore, 'sol-2');
    await source.aprobar('sol-1', 'coord-1');

    await expectLater(
      source.aprobar('sol-2', 'coord-2'),
      throwsA(
        isA<ReglaNegocioException>().having(
          (error) => error.codigo,
          'codigo',
          'FRANJA_OCUPADA',
        ),
      ),
    );
  });

  test('no aprueba solicitudes de equipos bloqueados', () async {
    await _crearSolicitud(firestore, 'sol-bloqueo');
    await firestore.collection('equipos_estado').doc('equipo-1').set({
      'bloqueado': true,
      'motivo': 'Mantenimiento',
    });

    await expectLater(
      source.aprobar('sol-bloqueo', 'coord-1'),
      throwsA(
        isA<ReglaNegocioException>().having(
          (error) => error.codigo,
          'codigo',
          'EQUIPO_BLOQUEADO',
        ),
      ),
    );
  });

  test('no permite aprobar la propia solicitud', () async {
    await _crearSolicitud(firestore, 'sol-propia', solicitanteUid: 'coord-1');

    await expectLater(
      source.aprobar('sol-propia', 'coord-1'),
      throwsA(
        isA<ReglaNegocioException>().having(
          (error) => error.codigo,
          'codigo',
          'AUTOAPROBACION',
        ),
      ),
    );
  });

  test('solo permite rechazar solicitudes en estado SOLICITADO', () async {
    await _crearSolicitud(firestore, 'sol-aprobada', estado: 'APROBADO');
    await expectLater(
      source.rechazar('sol-aprobada', 'coord-1', 'No disponible'),
      throwsA(
        isA<ReglaNegocioException>().having(
          (error) => error.codigo,
          'codigo',
          'ESTADO_CAMBIO',
        ),
      ),
    );

    await _crearSolicitud(firestore, 'sol-rechazo');
    await source.rechazar('sol-rechazo', 'coord-1', 'No hay justificación');
    final rechazada = await firestore
        .collection('solicitudes')
        .doc('sol-rechazo')
        .get();
    expect(rechazada.data()?['estado'], 'RECHAZADO');
    expect(rechazada.data()?['motivoRechazo'], 'No hay justificación');
  });
}

Future<void> _crearSolicitud(
  FakeFirebaseFirestore firestore,
  String id, {
  String solicitanteUid = 'solicitante-1',
  String estado = 'SOLICITADO',
}) async {
  final fecha = DateTime(2026, 11, 20);
  await firestore.collection('solicitudes').doc(id).set({
    'id': id,
    'solicitanteUid': solicitanteUid,
    'equipoId': 'equipo-1',
    'equipoNombre': 'Portátil de prueba',
    'fecha': Timestamp.fromDate(fecha),
    'fechaClave': '20261120',
    'slot': '08-10',
    'franjaId': 'equipo-1_20261120_08-10',
    'estado': estado,
    'version': 1,
    'creadaEn': Timestamp.fromDate(DateTime(2026, 11, 10)),
    'actualizadaEn': Timestamp.fromDate(DateTime(2026, 11, 10)),
  });
}
