import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../errors/regla_negocio_exception.dart';

/// Clasifica errores de la aplicación sin adjuntar datos introducidos por el usuario.
abstract final class AppLogger {
  /// Error esperado del dominio: se ignora para Crashlytics.
  static void business(ReglaNegocioException error) {
    // Deliberadamente no se registra mensaje ni datos de la operación.
  }

  /// Fallo transitorio de conectividad: evento no fatal, sin información personal.
  static void network(Object error, StackTrace stack) {
    if (_isNetworkFailure(error)) {
      FirebaseCrashlytics.instance.recordError(
        error.runtimeType,
        stack,
        reason: 'Fallo de red esperado',
        fatal: false,
      );
    } else {
      unexpected(error, stack);
    }
  }

  /// Excepción inesperada: se envía como no fatal desde este logger.
  static void unexpected(Object error, StackTrace stack) {
    if (error is ReglaNegocioException) return;
    FirebaseCrashlytics.instance.recordError(
      error.runtimeType,
      stack,
      reason: 'Excepción inesperada',
      fatal: false,
    );
  }

  static bool _isNetworkFailure(Object error) =>
      error is SocketException ||
      error is TimeoutException ||
      error is HttpException;
}
