import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/errors/auth_exception.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/perfil.dart';

class AuthController extends ChangeNotifier {
  // ignore: prefer_initializing_formals
  AuthController({required AuthRepository repository}) : _repository = repository {
    _perfilSubscription = _repository.perfilActual().listen(
      (perfil) {
        _perfil = perfil;
        _sesionResuelta = true;
        _notifyIfAlive();
      },
      onError: (Object error) {
        _mensajeError = error is AuthException
            ? error.mensaje
            : 'No fue posible cargar el perfil. Inténtalo de nuevo';
        _sesionResuelta = true;
        _notifyIfAlive();
      },
    );
  }

  final AuthRepository _repository;
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
    () => _repository.registrar(
      nombre: nombre,
      email: email,
      password: password,
    ),
  );

  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) => _ejecutar(
    () => _repository.iniciarSesion(email: email, password: password),
  );

  Future<void> cerrarSesion() => _ejecutar(() async {
    await _repository.cerrarSesion();
    return null;
  });

  Future<void> _ejecutar(Future<Perfil?> Function() operacion) async {
    if (_cargando || _disposed) return;
    _cargando = true;
    _mensajeError = null;
    _notifyIfAlive();
    try {
      final resultado = await operacion();
      if (resultado != null) _perfil = resultado;
    } on AuthException catch (error) {
      _mensajeError = error.mensaje;
    } catch (_) {
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
