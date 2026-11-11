import 'package:firebase_auth/firebase_auth.dart';

import '../logging/app_logger.dart';

class AuthException implements Exception {
  const AuthException(this.mensaje);

  final String mensaje;

  factory AuthException.fromFirebaseAuthException(
    FirebaseAuthException exception,
  ) {
    final mensaje = mensajeParaCodigo(exception.code);
    if (exception.code == 'network-request-failed') {
      AppLogger.network(exception, StackTrace.current);
    } else if (!_esErrorEsperado(exception.code)) {
      AppLogger.unexpected(exception, StackTrace.current);
    }
    return AuthException(mensaje);
  }

  static String mensajeParaCodigo(String codigo) {
    switch (codigo) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Correo o contraseña incorrectos';
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      case 'weak-password':
        return 'La contraseña debe ser más segura';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo electrónico';
      case 'network-request-failed':
        return 'Sin conexión. Comprueba tu conexión a internet e inténtalo de nuevo';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e inténtalo de nuevo';
      default:
        return 'No fue posible completar la autenticación. Inténtalo de nuevo';
    }
  }

  static bool _esErrorEsperado(String codigo) => const {
    'invalid-credential',
    'wrong-password',
    'user-not-found',
    'invalid-email',
    'weak-password',
    'email-already-in-use',
    'network-request-failed',
    'too-many-requests',
  }.contains(codigo);

  @override
  String toString() => 'AuthException: $mensaje';
}
