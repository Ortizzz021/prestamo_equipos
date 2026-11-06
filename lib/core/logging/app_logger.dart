import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../errors/regla_negocio_exception.dart';

abstract final class AppLogger {
  static void business(ReglaNegocioException error) {
  }

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
