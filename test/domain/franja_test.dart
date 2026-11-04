import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/core/errors/regla_negocio_exception.dart';
import 'package:prestamo_equipos/domain/models/franja.dart';

void main() {
  // Miércoles 4 de noviembre de 2026, 11:00 a. m.
  final ahora = DateTime(2026, 11, 4, 11);

  Matcher reglaConCodigo(String codigo) => throwsA(
        isA<ReglaNegocioException>().having((e) => e.codigo, 'codigo', codigo),
      );

  group('Franja', () {
    test('calcula inicio y fin a partir del slot', () {
      final f = Franja(fecha: DateTime(2026, 11, 5), slot: SlotHorario.tarde1);
      expect(f.inicio, DateTime(2026, 11, 5, 14));
      expect(f.fin, DateTime(2026, 11, 5, 16));
      expect(f.inicio.isBefore(f.fin), isTrue);
    });

    test('ignora la hora de la fecha recibida', () {
      final f = Franja(
        fecha: DateTime(2026, 11, 5, 23, 59),
        slot: SlotHorario.manana1,
      );
      expect(f.inicio, DateTime(2026, 11, 5, 8));
    });

    test('una franja futura es válida', () {
      final f = Franja(fecha: DateTime(2026, 11, 5), slot: SlotHorario.manana1);
      expect(() => f.validar(ahora), returnsNormally);
    });

    test('una franja pasada se rechaza', () {
      final f = Franja(fecha: DateTime(2026, 11, 3), slot: SlotHorario.tarde2);
      expect(() => f.validar(ahora), reglaConCodigo('FRANJA_PASADA'));
    });

    test('una franja que ya comenzó se rechaza', () {
      final f = Franja(fecha: DateTime(2026, 11, 4), slot: SlotHorario.manana2);
      expect(() => f.validar(ahora), reglaConCodigo('FRANJA_PASADA'));
    });

    test('disponiblesDelDia omite los bloques que ya empezaron', () {
      final hoy = Franja.disponiblesDelDia(DateTime(2026, 11, 4), ahora);
      expect(hoy.map((f) => f.slot), [SlotHorario.tarde1, SlotHorario.tarde2]);

      final manana = Franja.disponiblesDelDia(DateTime(2026, 11, 5), ahora);
      expect(manana, hasLength(SlotHorario.values.length));
    });

    test('el id de ocupación es determinístico por equipo, día y slot', () {
      final a = Franja(fecha: DateTime(2026, 11, 5), slot: SlotHorario.manana1);
      final b = Franja(
        fecha: DateTime(2026, 11, 5, 15),
        slot: SlotHorario.manana1,
      );
      expect(a.idOcupacion('eq-7'), 'eq-7_20261105_08-10');
      expect(a.idOcupacion('eq-7'), b.idOcupacion('eq-7'));
      expect(a, b);
    });

    test('SlotHorario.desdeCodigo', () {
      expect(SlotHorario.desdeCodigo('16-18'), SlotHorario.tarde2);
      expect(() => SlotHorario.desdeCodigo('00-01'), throwsArgumentError);
    });
  });
}
