import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/core/errors/regla_negocio_exception.dart';
import 'package:prestamo_equipos/data/remote/bodega_remote_data_source.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late BodegaRemoteDataSource source;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    source = BodegaRemoteDataSource(
      firestore: firestore,
      reloj: () => DateTime(2026, 11, 10, 9),
    );
  });

  test('no permite entregar una solicitud en estado SOLICITADO', () async {
    await _crearSolicitud(firestore, 'sol-solicitada', 'SOLICITADO');

    await expectLater(
      source.registrarEntrega('sol-solicitada', 'bodega-1', 'Buen estado'),
      throwsA(
        isA<ReglaNegocioException>().having(
          (error) => error.codigo,
          'codigo',
          'TRANSICION_INVALIDA',
        ),
      ),
    );
  });

  test('exige observación física para entregar', () async {
    await _crearSolicitud(firestore, 'sol-sin-observacion', 'APROBADO');

    await expectLater(
      source.registrarEntrega('sol-sin-observacion', 'bodega-1', '  '),
      throwsA(
        isA<ReglaNegocioException>().having(
          (error) => error.codigo,
          'codigo',
          'OBSERVACION_REQUERIDA',
        ),
      ),
    );
  });

  test('registra la entrega de una solicitud APROBADO', () async {
    await _crearSolicitud(firestore, 'sol-entrega', 'APROBADO');

    await source.registrarEntrega(
      'sol-entrega',
      'bodega-1',
      'Carcasa y pantalla sin daños',
    );

    final snapshot = await firestore
        .collection('solicitudes')
        .doc('sol-entrega')
        .get();
    expect(snapshot.data()?['estado'], 'ENTREGADO');
    expect(snapshot.data()?['observacionEntrega'], 'Carcasa y pantalla sin daños');
    expect(snapshot.data()?['entregadoPor'], 'bodega-1');
    expect(snapshot.data()?['version'], 2);
    expect(snapshot.data()?['entregadoEn'], isA<Timestamp>());
  });

  test('no permite devolver una solicitud APROBADO', () async {
    await _crearSolicitud(firestore, 'sol-no-entregada', 'APROBADO');

    await expectLater(
      source.registrarDevolucion(
        'sol-no-entregada',
        'bodega-1',
        'Devuelto en buen estado',
      ),
      throwsA(
        isA<ReglaNegocioException>().having(
          (error) => error.codigo,
          'codigo',
          'TRANSICION_INVALIDA',
        ),
      ),
    );
  });

  test('registra la devolución y libera la franja', () async {
    await _crearSolicitud(firestore, 'sol-devolucion', 'ENTREGADO');
    await firestore
        .collection('franjas')
        .doc('equipo-1_20261120_08-10')
        .set({
          'equipoId': 'equipo-1',
          'fechaClave': '20261120',
          'slot': '08-10',
          'solicitudId': 'sol-devolucion',
          'ocupadaEn': Timestamp.fromDate(DateTime(2026, 11, 10)),
        });

    await source.registrarDevolucion(
      'sol-devolucion',
      'bodega-1',
      'Equipo completo y sin daños',
    );

    final solicitud = await firestore
        .collection('solicitudes')
        .doc('sol-devolucion')
        .get();
    final franja = await firestore
        .collection('franjas')
        .doc('equipo-1_20261120_08-10')
        .get();
    expect(solicitud.data()?['estado'], 'DEVUELTO');
    expect(solicitud.data()?['observacionDevolucion'], 'Equipo completo y sin daños');
    expect(solicitud.data()?['devueltoPor'], 'bodega-1');
    expect(solicitud.data()?['version'], 2);
    expect(solicitud.data()?['devueltoEn'], isA<Timestamp>());
    expect(franja.exists, isFalse);
  });
}

Future<void> _crearSolicitud(
  FakeFirebaseFirestore firestore,
  String id,
  String estado,
) async {
  final fecha = DateTime(2026, 11, 20);
  await firestore.collection('solicitudes').doc(id).set({
    'id': id,
    'solicitanteUid': 'solicitante-1',
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
