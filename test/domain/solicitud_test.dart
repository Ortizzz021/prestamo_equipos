import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/core/errors/regla_negocio_exception.dart';
import 'package:prestamo_equipos/domain/models/estado_solicitud.dart';
import 'package:prestamo_equipos/domain/models/franja.dart';
import 'package:prestamo_equipos/domain/models/rol.dart';
import 'package:prestamo_equipos/domain/models/solicitud.dart';

void main() {
  final ahora = DateTime(2026, 11, 4, 11);
  const solicitante = 'uid-solicitante';
  const coordinador = 'uid-coordinador';
  const bodega = 'uid-bodega';

  final franjaManana =
      Franja(fecha: DateTime(2026, 11, 5), slot: SlotHorario.manana1);

  Solicitud nueva() => Solicitud.nueva(
        id: 'sol-1',
        solicitanteUid: solicitante,
        equipoId: 'eq-1',
        franja: franjaManana,
        ahora: ahora,
      );

  Matcher reglaConCodigo(String codigo) => throwsA(
        isA<ReglaNegocioException>().having((e) => e.codigo, 'codigo', codigo),
      );

  group('Solicitud.nueva', () {
    test('nace SOLICITADO y pendiente de sincronizar', () {
      final s = nueva();
      expect(s.estado, EstadoSolicitud.solicitado);
      expect(s.estadoSync, EstadoSync.pendiente);
      expect(s.version, 1);
    });

    test('rechaza franjas pasadas', () {
      expect(
        () => Solicitud.nueva(
          id: 'sol-2',
          solicitanteUid: solicitante,
          equipoId: 'eq-1',
          franja:
              Franja(fecha: DateTime(2026, 11, 3), slot: SlotHorario.manana1),
          ahora: ahora,
        ),
        reglaConCodigo('FRANJA_PASADA'),
      );
    });

    test('exige un usuario autenticado', () {
      expect(
        () => Solicitud.nueva(
          id: 'sol-3',
          solicitanteUid: '',
          equipoId: 'eq-1',
          franja: franjaManana,
          ahora: ahora,
        ),
        reglaConCodigo('SIN_SESION'),
      );
    });
  });

  group('Solicitud.transicionar', () {
    test('recorrido completo SOLICITADO → APROBADO → ENTREGADO → DEVUELTO', () {
      final aprobada = nueva().transicionar(
        destino: EstadoSolicitud.aprobado,
        rol: Rol.coordinador,
        actorUid: coordinador,
        ahora: ahora,
      );
      final entregada = aprobada.transicionar(
        destino: EstadoSolicitud.entregado,
        rol: Rol.bodega,
        actorUid: bodega,
        ahora: ahora,
        observacion: 'Sin rayones, con cargador',
      );
      final devuelta = entregada.transicionar(
        destino: EstadoSolicitud.devuelto,
        rol: Rol.bodega,
        actorUid: bodega,
        ahora: ahora,
        observacion: 'Devuelto en buen estado',
      );

      expect(devuelta.estado, EstadoSolicitud.devuelto);
      expect(devuelta.observacionEntrega, 'Sin rayones, con cargador');
      expect(devuelta.observacionDevolucion, 'Devuelto en buen estado');
      expect(devuelta.version, 4);
      expect(devuelta.estadoSync, EstadoSync.pendiente);
    });

    test('bodega intenta entregar un préstamo solicitado: se rechaza', () {
      expect(
        () => nueva().transicionar(
          destino: EstadoSolicitud.entregado,
          rol: Rol.bodega,
          actorUid: bodega,
          ahora: ahora,
          observacion: 'ok',
        ),
        reglaConCodigo('TRANSICION_INVALIDA'),
      );
    });

    test('el solicitante no puede aprobar', () {
      expect(
        () => nueva().transicionar(
          destino: EstadoSolicitud.aprobado,
          rol: Rol.solicitante,
          actorUid: solicitante,
          ahora: ahora,
        ),
        reglaConCodigo('ROL_NO_AUTORIZADO'),
      );
    });

    test('un coordinador no aprueba su propio préstamo', () {
      final propia = Solicitud.nueva(
        id: 'sol-4',
        solicitanteUid: coordinador,
        equipoId: 'eq-1',
        franja: franjaManana,
        ahora: ahora,
      );
      expect(
        () => propia.transicionar(
          destino: EstadoSolicitud.aprobado,
          rol: Rol.coordinador,
          actorUid: coordinador,
          ahora: ahora,
        ),
        reglaConCodigo('AUTOAPROBACION'),
      );
    });

    test('solo el dueño cancela su solicitud', () {
      expect(
        () => nueva().transicionar(
          destino: EstadoSolicitud.cancelado,
          rol: Rol.solicitante,
          actorUid: 'otro-uid',
          ahora: ahora,
        ),
        reglaConCodigo('NO_ES_DUENO'),
      );
    });

    test('cancelar un aprobado deja de ocupar la franja', () {
      final aprobada = nueva().transicionar(
        destino: EstadoSolicitud.aprobado,
        rol: Rol.coordinador,
        actorUid: coordinador,
        ahora: ahora,
      );
      expect(aprobada.estado.ocupaFranja, isTrue);

      final cancelada = aprobada.transicionar(
        destino: EstadoSolicitud.cancelado,
        rol: Rol.solicitante,
        actorUid: solicitante,
        ahora: ahora,
      );
      expect(cancelada.estado.ocupaFranja, isFalse);
    });

    test('no se aprueba una franja que ya comenzó', () {
      expect(
        () => nueva().transicionar(
          destino: EstadoSolicitud.aprobado,
          rol: Rol.coordinador,
          actorUid: coordinador,
          ahora: DateTime(2026, 11, 5, 9),
        ),
        reglaConCodigo('FRANJA_PASADA'),
      );
    });

    test('entrega y devolución exigen observación', () {
      final aprobada = nueva().transicionar(
        destino: EstadoSolicitud.aprobado,
        rol: Rol.coordinador,
        actorUid: coordinador,
        ahora: ahora,
      );
      expect(
        () => aprobada.transicionar(
          destino: EstadoSolicitud.entregado,
          rol: Rol.bodega,
          actorUid: bodega,
          ahora: ahora,
          observacion: '   ',
        ),
        reglaConCodigo('OBSERVACION_REQUERIDA'),
      );
    });

    test('un estado terminal no admite más transiciones', () {
      final rechazada = nueva().transicionar(
        destino: EstadoSolicitud.rechazado,
        rol: Rol.coordinador,
        actorUid: coordinador,
        ahora: ahora,
        observacion: 'Equipo en mantenimiento',
      );
      expect(rechazada.motivoRechazo, 'Equipo en mantenimiento');
      expect(
        () => rechazada.transicionar(
          destino: EstadoSolicitud.aprobado,
          rol: Rol.coordinador,
          actorUid: coordinador,
          ahora: ahora,
        ),
        reglaConCodigo('TRANSICION_INVALIDA'),
      );
    });
  });

  group('Estado de sincronización', () {
    test('solo se confirma la versión que se envió', () {
      final enviada = nueva();
      final editada = enviada.transicionar(
        destino: EstadoSolicitud.cancelado,
        rol: Rol.solicitante,
        actorUid: solicitante,
        ahora: ahora,
      );

      expect(editada.confirmarSync(1).estadoSync, EstadoSync.pendiente);
      expect(editada.confirmarSync(2).estadoSync, EstadoSync.sincronizado);
    });

    test('un fallo temporal sigue pendiente; un rechazo no se reintenta', () {
      final s = nueva();
      final temporal = s.marcarFalloTemporal('Sin conexión');
      expect(temporal.estadoSync, EstadoSync.pendiente);
      expect(temporal.ultimoError, 'Sin conexión');

      final rechazada = s.marcarRechazada('Permiso denegado');
      expect(rechazada.estadoSync, EstadoSync.rechazado);
      expect(rechazada.ultimoError, 'Permiso denegado');
    });

    test('confirmar limpia el último error', () {
      final s = nueva().marcarFalloTemporal('timeout').confirmarSync(1);
      expect(s.estadoSync, EstadoSync.sincronizado);
      expect(s.ultimoError, isNull);
    });
  });
}
