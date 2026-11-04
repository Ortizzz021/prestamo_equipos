import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/domain/models/estado_solicitud.dart';
import 'package:prestamo_equipos/domain/models/rol.dart';

void main() {
  group('EstadoSolicitud - transiciones por rol', () {
    test('el coordinador aprueba o rechaza una solicitud', () {
      expect(
        EstadoSolicitud.solicitado
            .puedeTransicionar(EstadoSolicitud.aprobado, Rol.coordinador),
        isTrue,
      );
      expect(
        EstadoSolicitud.solicitado
            .puedeTransicionar(EstadoSolicitud.rechazado, Rol.coordinador),
        isTrue,
      );
    });

    test('el solicitante no puede aprobar', () {
      expect(
        EstadoSolicitud.solicitado
            .puedeTransicionar(EstadoSolicitud.aprobado, Rol.solicitante),
        isFalse,
      );
    });

    test('bodega no entrega una solicitud sin aprobar', () {
      expect(
        EstadoSolicitud.solicitado
            .puedeTransicionar(EstadoSolicitud.entregado, Rol.bodega),
        isFalse,
      );
      expect(
        EstadoSolicitud.aprobado
            .puedeTransicionar(EstadoSolicitud.entregado, Rol.bodega),
        isTrue,
      );
    });

    test('solo se devuelve lo que fue entregado', () {
      expect(
        EstadoSolicitud.aprobado
            .puedeTransicionar(EstadoSolicitud.devuelto, Rol.bodega),
        isFalse,
      );
      expect(
        EstadoSolicitud.entregado
            .puedeTransicionar(EstadoSolicitud.devuelto, Rol.bodega),
        isTrue,
      );
    });

    test('el solicitante cancela antes de la entrega, no después', () {
      expect(
        EstadoSolicitud.solicitado
            .puedeTransicionar(EstadoSolicitud.cancelado, Rol.solicitante),
        isTrue,
      );
      expect(
        EstadoSolicitud.aprobado
            .puedeTransicionar(EstadoSolicitud.cancelado, Rol.solicitante),
        isTrue,
      );
      expect(
        EstadoSolicitud.entregado
            .puedeTransicionar(EstadoSolicitud.cancelado, Rol.solicitante),
        isFalse,
      );
    });

    test('rechazado, cancelado y devuelto son terminales', () {
      expect(EstadoSolicitud.rechazado.esTerminal, isTrue);
      expect(EstadoSolicitud.cancelado.esTerminal, isTrue);
      expect(EstadoSolicitud.devuelto.esTerminal, isTrue);
      expect(EstadoSolicitud.solicitado.esTerminal, isFalse);
    });

    test('solo aprobado y entregado ocupan la franja', () {
      final ocupan =
          EstadoSolicitud.values.where((e) => e.ocupaFranja).toSet();
      expect(ocupan, {EstadoSolicitud.aprobado, EstadoSolicitud.entregado});
    });

    test('accionesPara devuelve los botones de cada rol', () {
      expect(
        EstadoSolicitud.solicitado.accionesPara(Rol.coordinador),
        {EstadoSolicitud.aprobado, EstadoSolicitud.rechazado},
      );
      expect(EstadoSolicitud.solicitado.accionesPara(Rol.bodega), isEmpty);
    });

    test('desdeValor convierte y rechaza valores desconocidos', () {
      expect(EstadoSolicitud.desdeValor('APROBADO'), EstadoSolicitud.aprobado);
      expect(() => EstadoSolicitud.desdeValor('X'), throwsArgumentError);
    });
  });

  group('Rol', () {
    test('un valor desconocido nunca otorga privilegios', () {
      expect(Rol.desdeValor('admin'), Rol.solicitante);
      expect(Rol.desdeValor(null), Rol.solicitante);
      expect(Rol.desdeValor('bodega'), Rol.bodega);
    });
  });
}
