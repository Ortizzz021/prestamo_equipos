import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../errors/api_exception.dart';
import '../errors/regla_negocio_exception.dart';

abstract final class AppLogger {
  static const _erroresRedFirebase = {
    'unavailable',
    'deadline-exceeded',
    'aborted',
    'cancelled',
    'network-request-failed',
    'unknown',
  };

  static FirebaseCrashlytics? get _crashlytics {
    if (kIsWeb) return null;
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseCrashlytics.instance;
    } catch (_) {
      return null;
    }
  }

  static void business(ReglaNegocioException error) {}

  static void network(Object error, StackTrace stack) {
    if (error is ReglaNegocioException) return;
    if (!_isNetworkFailure(error)) {
      unexpected(error, stack);
      return;
    }
    _record(error, stack, reason: 'Fallo de red esperado', fatal: false);
  }

  static void unexpected(Object error, StackTrace stack) {
    if (error is ReglaNegocioException) return;
    _record(error, stack, reason: 'Excepción inesperada', fatal: false);
  }

  static Future<void> log(String message) async {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;
    await _ignoreFailure(() => crashlytics.log(_sanitize(message)));
  }

  static Future<void> identify(String? uid) async {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;
    await _ignoreFailure(() => crashlytics.setUserIdentifier(uid ?? ''));
  }

  static Future<void> setAppContext({
    required String version,
    required String buildMode,
  }) async {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;
    await _ignoreFailure(() async {
      await crashlytics.setCustomKey('app_version', version);
      await crashlytics.setCustomKey('build_mode', buildMode);
    });
  }

  static Future<bool> sendTestNonFatal() async {
    if (!kDebugMode) return false;
    final crashlytics = _crashlytics;
    if (crashlytics == null) return false;
    try {
      await crashlytics.setCrashlyticsCollectionEnabled(true);
      await crashlytics.recordError(
        StateError('Crashlytics diagnostic event'),
        StackTrace.current,
        reason: 'Evento no fatal de diagnóstico',
        fatal: false,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> forceTestCrash() async {
    if (!kDebugMode) return false;
    final crashlytics = _crashlytics;
    if (crashlytics == null) return false;
    try {
      await crashlytics.setCrashlyticsCollectionEnabled(true);
      crashlytics.crash();
      return true;
    } catch (_) {
      return false;
    }
  }

  static void _record(
    Object error,
    StackTrace stack, {
    required String reason,
    required bool fatal,
  }) {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;
    unawaited(
      _ignoreFailure(
        () => crashlytics.recordError(
          error.runtimeType,
          stack,
          reason: reason,
          fatal: fatal,
        ),
      ),
    );
  }

  static Future<void> _ignoreFailure(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (_) {}
  }

  static bool _isNetworkFailure(Object error) {
    if (error is SocketException ||
        error is TimeoutException ||
        error is HttpException ||
        error is http.ClientException ||
        error is SinConexionException ||
        error is TiempoAgotadoException) {
      return true;
    }
    if (error is FirebaseException) {
      return _erroresRedFirebase.contains(error.code);
    }
    if (error is FirebaseAuthException) {
      return _erroresRedFirebase.contains(error.code);
    }
    return false;
  }

  static String _sanitize(String message) {
    return message
        .replaceAll(
          RegExp(
            r'\b(password|passwd|token|access_token|refresh_token|authorization|email|correo)\s*[:=]\s*[^\s,;]+',
            caseSensitive: false,
          ),
          r'$1=[REDACTED]',
        )
        .replaceAll(
          RegExp(
            r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b',
            caseSensitive: false,
          ),
          '[REDACTED_EMAIL]',
        )
        .replaceAll(
          RegExp(
            r'\beyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\b',
          ),
          '[REDACTED_TOKEN]',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
