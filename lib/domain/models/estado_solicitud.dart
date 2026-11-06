import 'rol.dart';

enum EstadoSolicitud {
  solicitado('SOLICITADO', 'Solicitado'),
  aprobado('APROBADO', 'Aprobado'),
  rechazado('RECHAZADO', 'Rechazado'),
  cancelado('CANCELADO', 'Cancelado'),
  entregado('ENTREGADO', 'Entregado'),
  devuelto('DEVUELTO', 'Devuelto');

  const EstadoSolicitud(this.valor, this.etiqueta);

  final String valor;

  final String etiqueta;

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

  bool get esTerminal => _transiciones[this] == null;

  bool get ocupaFranja =>
      this == EstadoSolicitud.aprobado || this == EstadoSolicitud.entregado;

  Set<EstadoSolicitud> get siguientes =>
      _transiciones[this]?.keys.toSet() ?? const {};

  Rol? rolAutorizado(EstadoSolicitud destino) => _transiciones[this]?[destino];

  bool puedeTransicionar(EstadoSolicitud destino, Rol rol) =>
      rolAutorizado(destino) == rol;

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
