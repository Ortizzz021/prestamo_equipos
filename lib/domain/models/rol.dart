enum Rol {
  solicitante('solicitante', 'Solicitante'),
  coordinador('coordinador', 'Coordinador'),
  bodega('bodega', 'Encargado de bodega');

  const Rol(this.valor, this.etiqueta);

  final String valor;

  final String etiqueta;

  static const Rol porDefecto = Rol.solicitante;

  static Rol desdeValor(String? valor) {
    for (final rol in Rol.values) {
      if (rol.valor == valor) return rol;
    }
    return porDefecto;
  }
}
