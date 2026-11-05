/// Validaciones de formulario de autenticación. Devuelven `null` si el valor
/// es válido o un mensaje para mostrar bajo el campo.
///
/// Se validan en el cliente para dar respuesta inmediata; Firebase vuelve a
/// validar y sus errores se traducen en [AuthException].
abstract final class Validadores {
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  /// Firebase Authentication exige al menos 6 caracteres.
  static const int longitudMinimaPassword = 6;

  static String? email(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Ingresa tu correo electrónico';
    if (!_email.hasMatch(texto)) return 'El correo electrónico no es válido';
    return null;
  }

  static String? password(String? valor) {
    final texto = valor ?? '';
    if (texto.isEmpty) return 'Ingresa tu contraseña';
    if (texto.length < longitudMinimaPassword) {
      return 'La contraseña debe tener al menos $longitudMinimaPassword caracteres';
    }
    return null;
  }

  static String? nombre(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Ingresa tu nombre';
    if (texto.length < 3) return 'El nombre es demasiado corto';
    return null;
  }

  static String? confirmarPassword(String? valor, String original) {
    if ((valor ?? '').isEmpty) return 'Confirma tu contraseña';
    if (valor != original) return 'Las contraseñas no coinciden';
    return null;
  }
}
