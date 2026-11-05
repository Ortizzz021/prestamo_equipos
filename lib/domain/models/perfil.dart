import 'rol.dart';

/// Perfil público asociado a un usuario autenticado.
///
/// No contiene contraseñas ni tokens. Los roles privilegiados se asignan
/// administrativamente en Firestore, no durante el registro.
class Perfil {
  const Perfil({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  final String uid;
  final String nombre;
  final String email;
  final Rol rol;

  factory Perfil.fromMap(Map<String, dynamic> map, {required String uid}) {
    final nombre = map['nombre'];
    final email = map['email'];
    final rolValor = map['rol'];
    return Perfil(
      uid: uid,
      nombre: nombre is String ? nombre : '',
      email: email is String ? email : '',
      rol: Rol.desdeValor(rolValor is String ? rolValor : null),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'nombre': nombre,
    'email': email,
    'rol': rol.valor,
  };
}
