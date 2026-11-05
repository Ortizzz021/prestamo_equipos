import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/core/errors/auth_exception.dart';

void main() {
  group('AuthException.mensajeParaCodigo', () {
    test('agrupa credenciales inválidas', () {
      for (final code in [
        'invalid-credential',
        'wrong-password',
        'user-not-found',
      ]) {
        expect(
          AuthException.mensajeParaCodigo(code),
          'Correo o contraseña incorrectos',
        );
      }
    });

    test('traduce códigos conocidos a mensajes seguros', () {
      expect(
        AuthException.mensajeParaCodigo('invalid-email'),
        'El correo electrónico no es válido',
      );
      expect(
        AuthException.mensajeParaCodigo('weak-password'),
        'La contraseña debe ser más segura',
      );
      expect(
        AuthException.mensajeParaCodigo('email-already-in-use'),
        'Ya existe una cuenta con ese correo electrónico',
      );
      expect(
        AuthException.mensajeParaCodigo('network-request-failed'),
        contains('Sin conexión'),
      );
      expect(
        AuthException.mensajeParaCodigo('too-many-requests'),
        contains('Demasiados intentos'),
      );
    });

    test('usa mensaje genérico para códigos no reconocidos', () {
      expect(
        AuthException.mensajeParaCodigo('unknown-code'),
        'No fue posible completar la autenticación. Inténtalo de nuevo',
      );
    });
  });
}
