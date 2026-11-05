import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/features/auth/validadores.dart';

void main() {
  group('Validadores.email', () {
    test('acepta correos válidos (con espacios alrededor)', () {
      expect(Validadores.email('ana@udem.edu.co'), isNull);
      expect(Validadores.email('  ana@udem.edu.co '), isNull);
    });

    test('rechaza vacío y formatos inválidos', () {
      expect(Validadores.email(''), isNotNull);
      expect(Validadores.email(null), isNotNull);
      expect(Validadores.email('ana'), 'El correo electrónico no es válido');
      expect(Validadores.email('ana@udem'), 'El correo electrónico no es válido');
      expect(Validadores.email('ana @udem.co'), 'El correo electrónico no es válido');
    });
  });

  group('Validadores.password', () {
    test('exige mínimo 6 caracteres como Firebase', () {
      expect(Validadores.password(''), 'Ingresa tu contraseña');
      expect(Validadores.password('12345'), isNotNull);
      expect(Validadores.password('123456'), isNull);
    });
  });

  group('Validadores.nombre', () {
    test('no acepta vacío ni nombres de menos de 3 letras', () {
      expect(Validadores.nombre('   '), 'Ingresa tu nombre');
      expect(Validadores.nombre('Al'), isNotNull);
      expect(Validadores.nombre('Ana María'), isNull);
    });
  });

  group('Validadores.confirmarPassword', () {
    test('debe coincidir con la contraseña', () {
      expect(Validadores.confirmarPassword('', 'secreto'), isNotNull);
      expect(
        Validadores.confirmarPassword('otra', 'secreto'),
        'Las contraseñas no coinciden',
      );
      expect(Validadores.confirmarPassword('secreto', 'secreto'), isNull);
    });
  });
}
