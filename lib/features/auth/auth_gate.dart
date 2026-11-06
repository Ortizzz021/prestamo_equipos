import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/rol.dart';
import '../home/bodega_home.dart';
import '../home/coordinador_home.dart';
import '../home/solicitante_home.dart';
import 'auth_controller.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (!auth.sesionResuelta) return const _RestaurandoSesion();

    final perfil = auth.perfil;
    if (perfil == null) return const LoginScreen();

    final key = ValueKey('${perfil.uid}_${perfil.rol.valor}');
    return switch (perfil.rol) {
      Rol.solicitante => SolicitanteHome(key: key, perfil: perfil),
      Rol.coordinador => CoordinadorHome(key: key, perfil: perfil),
      Rol.bodega => BodegaHome(key: key, perfil: perfil),
    };
  }
}

class _RestaurandoSesion extends StatelessWidget {
  const _RestaurandoSesion();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Restaurando sesión...'),
          ],
        ),
      ),
    );
  }
}
