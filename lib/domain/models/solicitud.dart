import '../../core/errors/regla_negocio_exception.dart';
import 'estado_solicitud.dart';
import 'franja.dart';
import 'rol.dart';

enum EstadoSync {
  pendiente('PENDIENTE'),

  sincronizado('SINCRONIZADO'),

  rechazado('RECHAZADO');

  const EstadoSync(this.valor);
  final String valor;

  static EstadoSync desdeValor(String valor) => EstadoSync.values.firstWhere(
        (e) => e.valor == valor,
        orElse: () => EstadoSync.pendiente,
      );
}

class Solicitud {
  const Solicitud({
    required this.id,
    required this.solicitanteUid,
    required this.equipoId,
    this.equipoNombre,
    required this.franja,
    required this.estado,
    required this.creadaEn,
    required this.actualizadaEn,
    this.version = 1,
    this.estadoSync = EstadoSync.pendiente,
    this.ultimoError,
    this.observacionEntrega,
    this.observacionDevolucion,
    this.motivoRechazo,
  });

  factory Solicitud.nueva({
    required String id,
    required String solicitanteUid,
    required String equipoId,
    required Franja franja,
    required DateTime ahora,
  }) {
    if (solicitanteUid.isEmpty) {
      throw const ReglaNegocioException(
        'SIN_SESION',
        'Debes iniciar sesión para crear una solicitud.',
      );
    }
    franja.validar(ahora);
    return Solicitud(
      id: id,
      solicitanteUid: solicitanteUid,
      equipoId: equipoId,
      franja: franja,
      estado: EstadoSolicitud.solicitado,
      creadaEn: ahora,
      actualizadaEn: ahora,
    );
  }

  final String id;
  final String solicitanteUid;
  final String equipoId;
  final String? equipoNombre;
  final Franja franja;
  final EstadoSolicitud estado;
  final DateTime creadaEn;
  final DateTime actualizadaEn;

  final int version;
  final EstadoSync estadoSync;
  final String? ultimoError;
  final String? observacionEntrega;
  final String? observacionDevolucion;
  final String? motivoRechazo;

  Solicitud transicionar({
    required EstadoSolicitud destino,
    required Rol rol,
    required String actorUid,
    required DateTime ahora,
    String? observacion,
  }) {
    if (!estado.siguientes.contains(destino)) {
      throw ReglaNegocioException(
        'TRANSICION_INVALIDA',
        'No se puede pasar de ${estado.etiqueta} a ${destino.etiqueta}.',
      );
    }
    if (!estado.puedeTransicionar(destino, rol)) {
      throw ReglaNegocioException(
        'ROL_NO_AUTORIZADO',
        'El rol ${rol.etiqueta} no puede marcar la solicitud como '
            '${destino.etiqueta}.',
      );
    }
    if (destino == EstadoSolicitud.aprobado && actorUid == solicitanteUid) {
      throw const ReglaNegocioException(
        'AUTOAPROBACION',
        'No puedes aprobar tu propio préstamo.',
      );
    }
    if (destino == EstadoSolicitud.cancelado && actorUid != solicitanteUid) {
      throw const ReglaNegocioException(
        'NO_ES_DUENO',
        'Solo quien creó la solicitud puede cancelarla.',
      );
    }
    if (destino == EstadoSolicitud.aprobado && !franja.esFutura(ahora)) {
      throw const ReglaNegocioException(
        'FRANJA_PASADA',
        'La franja de esta solicitud ya comenzó; no se puede aprobar.',
      );
    }

    final texto = observacion?.trim();
    final requiereObservacion = destino == EstadoSolicitud.entregado ||
        destino == EstadoSolicitud.devuelto;
    if (requiereObservacion && (texto == null || texto.isEmpty)) {
      throw const ReglaNegocioException(
        'OBSERVACION_REQUERIDA',
        'Registra una observación del estado físico del equipo.',
      );
    }

    return Solicitud(
      id: id,
      solicitanteUid: solicitanteUid,
      equipoId: equipoId,
      equipoNombre: equipoNombre,
      franja: franja,
      estado: destino,
      creadaEn: creadaEn,
      actualizadaEn: ahora,
      version: version + 1,
      estadoSync: EstadoSync.pendiente,
      observacionEntrega:
          destino == EstadoSolicitud.entregado ? texto : observacionEntrega,
      observacionDevolucion:
          destino == EstadoSolicitud.devuelto ? texto : observacionDevolucion,
      motivoRechazo: destino == EstadoSolicitud.rechazado
          ? (texto?.isEmpty ?? true ? null : texto)
          : motivoRechazo,
    );
  }

  Solicitud confirmarSync(int versionConfirmada) {
    if (versionConfirmada != version) return this;
    return _conSync(EstadoSync.sincronizado, null);
  }

  Solicitud marcarRechazada(String motivo) =>
      _conSync(EstadoSync.rechazado, motivo);

  Solicitud marcarFalloTemporal(String motivo) =>
      _conSync(EstadoSync.pendiente, motivo);

  Solicitud _conSync(EstadoSync sync, String? error) => Solicitud(
        id: id,
        solicitanteUid: solicitanteUid,
        equipoId: equipoId,
        equipoNombre: equipoNombre,
        franja: franja,
        estado: estado,
        creadaEn: creadaEn,
        actualizadaEn: actualizadaEn,
        version: version,
        estadoSync: sync,
        ultimoError: error,
        observacionEntrega: observacionEntrega,
        observacionDevolucion: observacionDevolucion,
        motivoRechazo: motivoRechazo,
      );

  @override
  String toString() =>
      'Solicitud($id, $equipoId, $franja, ${estado.valor}, ${estadoSync.valor})';
}
