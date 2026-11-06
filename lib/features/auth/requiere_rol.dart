import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/rol.dart';
import 'auth_controller.dart';

class RequiereRol extends StatelessWidget {
  const RequiereRol({super.key, required this.roles, required this.child});

  final Set<Rol> roles;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rol = context.select<AuthController, Rol?>((a) => a.perfil?.rol);
    if (rol != null && roles.contains(rol)) return child;
    return const AccesoDenegado();
  }
}

class AccesoDenegado extends StatelessWidget {
  const AccesoDenegado({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso restringido')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48),
              SizedBox(height: 12),
              Text(
                'Tu rol no tiene permiso para ver esta sección.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
