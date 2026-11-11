import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/errors/auth_exception.dart';
import '../../core/logging/app_logger.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/perfil.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this.repository}) {
    _perfilSubscription = repository.perfilActual().listen(
      (perfil) {
        _perfil = perfil;
        unawaited(AppLogger.identify(perfil?.uid));
        _sesionResuelta = true;
        _notifyIfAlive();
      },
      onError: (Object error, StackTrace stack) {
        if (error is! AuthException) AppLogger.network(error, stack);
        _mensajeError = error is AuthException
            ? error.mensaje
            : 'No fue posible cargar el perfil. Inténtalo de nuevo';
        _sesionResuelta = true;
        _notifyIfAlive();
      },
    );
  }

  final AuthRepository repository;
  late final StreamSubscription<Perfil?> _perfilSubscription;
  bool _cargando = false;
  bool _disposed = false;
  bool _sesionResuelta = false;
  Perfil? _perfil;
  String? _mensajeError;

  bool get cargando => _cargando;
  Perfil? get perfil => _perfil;
  String? get mensajeError => _mensajeError;

  bool get sesionResuelta => _sesionResuelta;

  void limpiarError() {
    if (_mensajeError == null) return;
    _mensajeError = null;
    _notifyIfAlive();
  }

  Future<void> registrar({
    required String nombre,
    required String email,
    required String password,
  }) => _ejecutar(
    () =>
        repository.registrar(nombre: nombre, email: email, password: password),
  );

  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) => _ejecutar(
    () => repository.iniciarSesion(email: email, password: password),
  );

  Future<void> cerrarSesion() => _ejecutar(() async {
    await repository.cerrarSesion();
    await AppLogger.identify(null);
    return null;
  });

  Future<void> _ejecutar(Future<Perfil?> Function() operacion) async {
    if (_cargando || _disposed) return;
    _cargando = true;
    _mensajeError = null;
    _notifyIfAlive();
    try {
      final resultado = await operacion();
      if (resultado != null) {
        _perfil = resultado;
        await AppLogger.identify(resultado.uid);
      }
    } on AuthException catch (error) {
      _mensajeError = error.mensaje;
    } catch (error, stack) {
      if (error is! AuthException) AppLogger.unexpected(error, stack);
      _mensajeError = 'Ocurrió un error. Inténtalo de nuevo';
    } finally {
      _cargando = false;
      _notifyIfAlive();
    }
  }

  void _notifyIfAlive() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_perfilSubscription.cancel());
    super.dispose();
  }
}
