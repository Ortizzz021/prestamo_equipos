/// Error esperado del dominio: una regla de negocio impide la operación.
///
/// Se muestra al usuario con [mensaje] y NO se reporta a Crashlytics como
/// fallo, porque no es un error del programa sino una validación.
class ReglaNegocioException implements Exception {
  const ReglaNegocioException(this.codigo, this.mensaje);

  /// Código estable para pruebas, logs y matriz de QA.
  final String codigo;

  /// Mensaje comprensible para el usuario.
  final String mensaje;

  @override
  String toString() => 'ReglaNegocioException($codigo): $mensaje';
}
