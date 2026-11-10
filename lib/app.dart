import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/preferences/preferencias_service.dart';
import 'core/theme/app_theme.dart';
import 'data/local/app_database.dart';
import 'data/remote/equipo_api_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/equipo_repository.dart';
import 'data/repositories/solicitud_repository.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/auth_gate.dart';

class PrestamoEquiposApp extends StatelessWidget {
  const PrestamoEquiposApp({
    super.key,
    required this.authRepository,
    this.equipoRepository,
    this.preferencias,
    this.solicitudRepository,
  });

  final AuthRepository authRepository;
  final EquipoRepository? equipoRepository;
  final PreferenciasService? preferencias;
  final SolicitudRepository? solicitudRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<EquipoRepository>(
          create: (_) =>
              equipoRepository ?? EquipoRepository(api: EquipoApiService()),
        ),
        Provider<PreferenciasService>(
          create: (_) => preferencias ?? PreferenciasService(),
        ),
        Provider<SolicitudRepository>(
          create: (_) =>
              solicitudRepository ?? SolicitudRepository(db: AppDatabase()),
          dispose: (_, repo) {
            if (solicitudRepository == null) repo.db.close();
          },
        ),
        ChangeNotifierProvider<AuthController>(
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
        home: const AuthGate(),
      ),
    );
  }
}
