import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/auth_exception.dart';
import '../../domain/models/perfil.dart';
import '../../domain/models/rol.dart';

class AuthRepository {
  AuthRepository({required FirebaseAuth auth, required FirebaseFirestore db})
    : this._internal(auth, db);

  AuthRepository._internal(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<Perfil> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          'No fue posible crear la cuenta. Inténtalo de nuevo',
        );
      }

      final perfil = Perfil(
        uid: user.uid,
        nombre: nombre.trim(),
        email: user.email ?? email.trim(),
        rol: Rol.solicitante,
      );
      await _users.doc(user.uid).set({
        ...perfil.toMap(),
        'creadoEn': FieldValue.serverTimestamp(),
      });
      return perfil;
    } on FirebaseAuthException catch (error) {
      throw AuthException.fromFirebaseAuthException(error);
    }
  }

  Future<Perfil> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          'No fue posible iniciar sesión. Inténtalo de nuevo',
        );
      }
      return await _leerPerfil(user);
    } on FirebaseAuthException catch (error) {
      throw AuthException.fromFirebaseAuthException(error);
    }
  }

  bool get haySesion => _auth.currentUser != null;

  Future<void> cerrarSesion() => _auth.signOut();

  Stream<Perfil?> perfilActual() {
    StreamSubscription<User?>? authSub;
    StreamSubscription<Perfil>? perfilSub;
    late final StreamController<Perfil?> controller;

    void escucharPerfil(User? user) {
      unawaited(perfilSub?.cancel());
      perfilSub = null;
      if (user == null) {
        controller.add(null);
        return;
      }
      perfilSub = _users
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
            final data = snapshot.data();
            if (data == null) return _perfilSolicitante(user);
            return Perfil.fromMap(data, uid: user.uid);
          })
          .listen(controller.add, onError: controller.addError);
    }

    controller = StreamController<Perfil?>(
      onListen: () {
        authSub = _auth.authStateChanges().listen(
          escucharPerfil,
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await perfilSub?.cancel();
        await authSub?.cancel();
      },
    );
    return controller.stream;
  }

  Future<Perfil> _leerPerfil(User user) async {
    final snapshot = await _users.doc(user.uid).get();
    final data = snapshot.data();
    if (data == null) return _perfilSolicitante(user);
    return Perfil.fromMap(data, uid: user.uid);
  }

  Perfil _perfilSolicitante(User user) => Perfil(
    uid: user.uid,
    nombre: user.displayName ?? '',
    email: user.email ?? '',
    rol: Rol.solicitante,
  );
}
