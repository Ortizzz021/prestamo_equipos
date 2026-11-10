import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/data/remote/disponibilidad_remote_data_source.dart';
import 'package:prestamo_equipos/domain/models/franja.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late DisponibilidadRemoteDataSource source;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    source = DisponibilidadRemoteDataSource(firestore: firestore);
  });

  test('un equipo sin documento de estado está disponible', () async {
    final estado = await source.observarEstadoEquipo('equipo-1').first;

    expect(estado.bloqueado, isFalse);
    expect(estado.motivo, isNull);
    expect(estado.verificado, isTrue);
  });

  test('lee el bloqueo y su motivo desde Firestore', () async {
    await firestore.collection('equipos_estado').doc('equipo-1').set({
      'bloqueado': true,
      'motivo': 'En mantenimiento',
      'actualizadoPor': 'coordinador-1',
      'actualizadoEn': DateTime(2026, 11, 10),
    });

    final estado = await source.observarEstadoEquipo('equipo-1').first;

    expect(estado.bloqueado, isTrue);
    expect(estado.motivo, 'En mantenimiento');
  });

  test('obtiene solo los slots ocupados del equipo y día consultados', () async {
    await firestore
        .collection('franjas')
        .doc('equipo-1_20261111_08-10')
        .set({
          'equipoId': 'equipo-1',
          'fechaClave': '20261111',
          'slot': '08-10',
          'solicitudId': 'sol-1',
        });
    await firestore
        .collection('franjas')
        .doc('equipo-1_20261111_14-16')
        .set({
          'equipoId': 'equipo-1',
          'fechaClave': '20261111',
          'slot': '14-16',
          'solicitudId': 'sol-2',
        });
    await firestore
        .collection('franjas')
        .doc('equipo-1_20261112_10-12')
        .set({
          'equipoId': 'equipo-1',
          'fechaClave': '20261112',
          'slot': '10-12',
          'solicitudId': 'sol-3',
        });
    await firestore
        .collection('franjas')
        .doc('equipo-2_20261111_16-18')
        .set({
          'equipoId': 'equipo-2',
          'fechaClave': '20261111',
          'slot': '16-18',
          'solicitudId': 'sol-4',
        });

    final ocupados = await source.slotsOcupados(
      'equipo-1',
      DateTime(2026, 11, 11),
    );

    expect(ocupados, {SlotHorario.manana1, SlotHorario.tarde1});
  });
}
