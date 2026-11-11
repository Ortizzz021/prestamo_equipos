import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/preferences/preferencias_service.dart';
import 'core/theme/app_theme.dart';
import 'data/local/app_database.dart';
import 'data/remote/equipo_api_service.dart';
import 'data/remote/disponibilidad_remote_data_source.dart';
import 'data/remote/coordinacion_remote_data_source.dart';
import 'data/remote/bodega_remote_data_source.dart';
import 'data/remote/solicitud_remote_data_source.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/coordinacion_repository.dart';
import 'data/repositories/bodega_repository.dart';
import 'data/repositories/disponibilidad_repository.dart';
import 'data/repositories/equipo_repository.dart';
import 'data/repositories/solicitud_repository.dart';
import 'data/sync/sync_service.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/auth_gate.dart';

class PrestamoEquiposApp extends StatelessWidget {
  const PrestamoEquiposApp({
    super.key,
    required this.authRepository,
    this.equipoRepository,
    this.preferencias,
    this.solicitudRepository,
    this.syncService,
    this.disponibilidadRepository,
    this.coordinacionRepository,
    this.bodegaRepository,
  });

  final AuthRepository authRepository;
  final EquipoRepository? equipoRepository;
  final PreferenciasService? preferencias;
  final SolicitudRepository? solicitudRepository;
  final SyncService? syncService;
  final DisponibilidadRepository? disponibilidadRepository;
  final CoordinacionRepository? coordinacionRepository;
  final BodegaRepository? bodegaRepository;

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
        Provider<DisponibilidadRepository>(
          create: (_) =>
              disponibilidadRepository ??
              DisponibilidadRepository(
                remote: DisponibilidadRemoteDataSource(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
        ),
        Provider<CoordinacionRepository>(
          create: (_) =>
              coordinacionRepository ??
              CoordinacionRepository(
                remote: CoordinacionRemoteDataSource(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
        ),
        Provider<BodegaRepository>(
          create: (_) =>
              bodegaRepository ??
              BodegaRepository(
                remote: BodegaRemoteDataSource(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
        ),
        Provider<SolicitudRepository>(
          create: (_) =>
              solicitudRepository ?? SolicitudRepository(db: AppDatabase()),
          dispose: (_, repo) {
            if (solicitudRepository == null) repo.db.close();
          },
        ),
        Provider<SyncService>(
          create: (context) =>
              syncService ??
              SyncService(
                repository: context.read<SolicitudRepository>(),
                remote: FirestoreSolicitudRemote(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
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
