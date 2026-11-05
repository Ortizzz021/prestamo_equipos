import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Error de autenticación seguro para mostrar en la interfaz.
class AuthException implements Exception {
  const AuthException(this.mensaje);

  final String mensaje;

  /// Convierte errores de Firebase a mensajes en español sin exponer datos.
  factory AuthException.fromFirebaseAuthException(
    FirebaseAuthException exception,
  ) {
    final mensaje = mensajeParaCodigo(exception.code);
    if (!_esErrorEsperado(exception.code)) {
      // Reportar únicamente el código (sin email, credenciales ni mensaje
      // original de Firebase), como evento no fatal.
      FirebaseCrashlytics.instance.recordError(
        'FirebaseAuthException(${exception.code})',
        StackTrace.current,
        reason: 'Error no esperado de autenticación',
        fatal: false,
      );
    }
    return AuthException(mensaje);
  }

  /// Mapeo puro para permitir probar todos los códigos sin Firebase activo.
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
