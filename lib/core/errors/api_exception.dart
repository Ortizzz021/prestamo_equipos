sealed class ApiException implements Exception {
  const ApiException(this.mensaje);

  final String mensaje;

  bool get esReintentable => true;

  @override
  String toString() => '$runtimeType: $mensaje';
}

class SinConexionException extends ApiException {
  const SinConexionException()
      : super('Sin conexión a internet. Revisa tu conexión e inténtalo de nuevo.');
}

class TiempoAgotadoException extends ApiException {
  const TiempoAgotadoException()
      : super('El servidor tardó demasiado en responder. Inténtalo de nuevo.');
}

class RespuestaHttpException extends ApiException {
  RespuestaHttpException(this.statusCode)
      : super(
          statusCode == 404
              ? 'No se encontró el catálogo de equipos.'
              : statusCode >= 500
                  ? 'El servicio del catálogo no está disponible en este momento.'
                  : 'No fue posible consultar el catálogo (código $statusCode).',
        );

  final int statusCode;

  @override
  bool get esReintentable => statusCode >= 500 || statusCode == 408 || statusCode == 429;
}

class FormatoInvalidoException extends ApiException {
  const FormatoInvalidoException(this.detalle)
      : super('La información del catálogo llegó con un formato inválido.');

  final String detalle;

  @override
  bool get esReintentable => false;
}

class ErrorInesperadoApiException extends ApiException {
  const ErrorInesperadoApiException(this.causa)
      : super('Ocurrió un error inesperado al consultar el catálogo.');

  final Object causa;
}
