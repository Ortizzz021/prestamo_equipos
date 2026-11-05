import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/auth_repository.dart';
import 'features/auth/auth_controller.dart';
import 'core/theme/app_theme.dart';

class PrestamoEquiposApp extends StatelessWidget {
  const PrestamoEquiposApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => AuthRepository(
            auth: FirebaseAuth.instance,
            db: FirebaseFirestore.instance,
          ),
        ),
        ChangeNotifierProvider<AuthController>(
          lazy: true,
          create: (context) => AuthController(
            repository: context.read<AuthRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Préstamo de Equipos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro,
        darkTheme: AppTheme.oscuro,
        // Pantalla temporal: el AuthGate con enrutamiento por rol la reemplaza.
        home: const _InicioTemporal(),
      ),
    );
  }
}

class _InicioTemporal extends StatelessWidget {
  const _InicioTemporal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Préstamo de Equipos')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Préstamo de equipos tecnológicos',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
