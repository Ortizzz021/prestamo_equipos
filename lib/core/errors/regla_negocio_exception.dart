class ReglaNegocioException implements Exception {
  const ReglaNegocioException(this.codigo, this.mensaje);

  final String codigo;

  final String mensaje;

  @override
  String toString() => 'ReglaNegocioException($codigo): $mensaje';
}
