/// Roles del caso G61-1.
///
/// Un usuario recién registrado siempre recibe [Rol.solicitante]. Los roles
/// privilegiados se asignan manualmente desde Firebase Console.
enum Rol {
  solicitante('solicitante', 'Solicitante'),
  coordinador('coordinador', 'Coordinador'),
  bodega('bodega', 'Encargado de bodega');

  const Rol(this.valor, this.etiqueta);

  /// Valor guardado en Firestore (`users/{uid}.rol`).
  final String valor;

  /// Texto para la interfaz.
  final String etiqueta;

  static const Rol porDefecto = Rol.solicitante;

  /// Convierte el valor remoto en un [Rol]. Un valor desconocido o ausente
  /// se trata como el rol básico, nunca como uno privilegiado.
  static Rol desdeValor(String? valor) {
    for (final rol in Rol.values) {
      if (rol.valor == valor) return rol;
    }
    return porDefecto;
  }
}
