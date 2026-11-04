import 'rol.dart';

/// Estados del préstamo:
///
///   SOLICITADO → APROBADO → ENTREGADO → DEVUELTO
///   SOLICITADO → RECHAZADO           (coordinador)
///   SOLICITADO | APROBADO → CANCELADO (solicitante, antes de la entrega)
enum EstadoSolicitud {
  solicitado('SOLICITADO', 'Solicitado'),
  aprobado('APROBADO', 'Aprobado'),
  rechazado('RECHAZADO', 'Rechazado'),
  cancelado('CANCELADO', 'Cancelado'),
  entregado('ENTREGADO', 'Entregado'),
  devuelto('DEVUELTO', 'Devuelto');

  const EstadoSolicitud(this.valor, this.etiqueta);

  /// Valor guardado en Drift y Firestore.
  final String valor;

  /// Texto para la interfaz.
  final String etiqueta;

  /// Transiciones permitidas: estado destino → rol que puede ejecutarla.
  static const Map<EstadoSolicitud, Map<EstadoSolicitud, Rol>> _transiciones = {
    EstadoSolicitud.solicitado: {
      EstadoSolicitud.aprobado: Rol.coordinador,
      EstadoSolicitud.rechazado: Rol.coordinador,
      EstadoSolicitud.cancelado: Rol.solicitante,
    },
    EstadoSolicitud.aprobado: {
      EstadoSolicitud.entregado: Rol.bodega,
      EstadoSolicitud.cancelado: Rol.solicitante,
    },
    EstadoSolicitud.entregado: {
      EstadoSolicitud.devuelto: Rol.bodega,
    },
  };

  /// Estados sin transiciones de salida.
  bool get esTerminal => _transiciones[this] == null;

  /// Estados en los que el préstamo mantiene ocupada su franja.
  /// Al pasar a CANCELADO o DEVUELTO la franja se libera.
  bool get ocupaFranja =>
      this == EstadoSolicitud.aprobado || this == EstadoSolicitud.entregado;

  /// Estados a los que se puede pasar desde este (sin importar el rol).
  Set<EstadoSolicitud> get siguientes =>
      _transiciones[this]?.keys.toSet() ?? const {};

  /// Rol autorizado para pasar de este estado a [destino], o `null` si la
  /// transición no existe.
  Rol? rolAutorizado(EstadoSolicitud destino) => _transiciones[this]?[destino];

  /// Indica si [rol] puede mover una solicitud de este estado a [destino].
  bool puedeTransicionar(EstadoSolicitud destino, Rol rol) =>
      rolAutorizado(destino) == rol;

  /// Acciones que [rol] puede ejecutar desde este estado. Útil para decidir
  /// qué botones mostrar (la validación real se repite en el repositorio y
  /// en las reglas de Firestore).
  Set<EstadoSolicitud> accionesPara(Rol rol) => {
        for (final entry in (_transiciones[this] ?? const {}).entries)
          if (entry.value == rol) entry.key,
      };

  static EstadoSolicitud desdeValor(String valor) {
    for (final estado in EstadoSolicitud.values) {
      if (estado.valor == valor) return estado;
    }
    throw ArgumentError.value(valor, 'valor', 'Estado de solicitud desconocido');
  }
}
