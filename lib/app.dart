import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class PrestamoEquiposApp extends StatelessWidget {
  const PrestamoEquiposApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Préstamo de Equipos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      darkTheme: AppTheme.oscuro,
      // Pantalla temporal: el AuthGate con enrutamiento por rol la reemplaza.
      home: const _InicioTemporal(),
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
