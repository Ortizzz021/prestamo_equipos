import 'dart:async';

import 'package:prestamo_equipos/core/errors/auth_exception.dart';
import 'package:prestamo_equipos/data/repositories/auth_repository.dart';
import 'package:prestamo_equipos/domain/models/perfil.dart';
import 'package:prestamo_equipos/domain/models/rol.dart';

/// Repositorio de autenticación en memoria para pruebas de widgets, sin
/// Firebase. Simula la sesión con un stream controlado por la prueba.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.perfilParaLogin});

  final _sesion = StreamController<Perfil?>.broadcast();

  /// Perfil que devuelve un inicio de sesión exitoso.
  Perfil? perfilParaLogin;

  /// Si se asigna, el próximo login/registro lanza este error.
  AuthException? errorSiguiente;

  /// Si se asigna, el login queda pendiente hasta completarlo.
  Completer<void>? bloqueo;

  int llamadasLogin = 0;
  int llamadasRegistro = 0;
  int llamadasCierre = 0;

  /// Emite el estado inicial de la sesión (como al abrir la app).
  void emitirSesion(Perfil? perfil) => _sesion.add(perfil);

  @override
  Stream<Perfil?> perfilActual() => _sesion.stream;

  @override
  Future<Perfil> iniciarSesion({
    required String email,
    required String password,
  }) async {
    llamadasLogin++;
    if (bloqueo != null) await bloqueo!.future;
    final error = errorSiguiente;
    if (error != null) {
      errorSiguiente = null;
      throw error;
    }
    final perfil = perfilParaLogin ?? perfilDePrueba(Rol.solicitante);
    _sesion.add(perfil);
    return perfil;
  }

  @override
  Future<Perfil> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    llamadasRegistro++;
    final error = errorSiguiente;
    if (error != null) {
      errorSiguiente = null;
      throw error;
    }
    final perfil = Perfil(
      uid: 'uid-nuevo',
      nombre: nombre,
      email: email,
      rol: Rol.solicitante,
    );
    _sesion.add(perfil);
    return perfil;
  }

  @override
  Future<void> cerrarSesion() async {
    llamadasCierre++;
    _sesion.add(null);
  }

  Future<void> close() => _sesion.close();
}

Perfil perfilDePrueba(Rol rol) => Perfil(
      uid: 'uid-${rol.valor}',
      nombre: 'Usuario ${rol.etiqueta}',
      email: '${rol.valor}@prueba.com',
      rol: rol,
    );
