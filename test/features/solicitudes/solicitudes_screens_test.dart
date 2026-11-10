import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/data/local/app_database.dart';
import 'package:prestamo_equipos/data/repositories/auth_repository.dart';
import 'package:prestamo_equipos/data/repositories/solicitud_repository.dart';
import 'package:prestamo_equipos/data/sync/sync_service.dart';
import 'package:prestamo_equipos/domain/models/equipo.dart';
import 'package:prestamo_equipos/domain/models/rol.dart';
import 'package:prestamo_equipos/features/auth/auth_controller.dart';
import 'package:prestamo_equipos/features/solicitudes/mis_prestamos_screen.dart';
import 'package:prestamo_equipos/features/solicitudes/solicitar_prestamo_screen.dart';
import 'package:provider/provider.dart';

import '../../helpers/base_en_memoria.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_sync_service.dart';

void main() {
  final ahora = DateTime(2026, 11, 10, 11);
  const proyector = Equipo(
    id: 'eq-6',
    nombre: 'Proyector Epson',
    categoria: 'Proyectores',
    descripcion: '',
    imagenUrl: '',
  );

  late AppDatabase db;
  late SolicitudRepository solicitudes;
  late FakeAuthRepository auth;
  late AuthController authController;
  late FakeSyncService sync;

  setUp(() {
    db = baseEnMemoria();
    solicitudes = SolicitudRepository(db: db, reloj: () => ahora);
    auth = FakeAuthRepository();
    authController = AuthController(repository: auth);
    sync = FakeSyncService();
  });

  tearDown(() async {
    authController.dispose();
    await auth.close();
    await db.close();
  });

  Future<void> abrir(WidgetTester tester, Widget pantalla) async {
    auth.emitirSesion(perfilDePrueba(Rol.solicitante));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: auth),
          Provider<SolicitudRepository>.value(value: solicitudes),
          Provider<SyncService>.value(value: sync),
          ChangeNotifierProvider<AuthController>.value(value: authController),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => pantalla),
                  ),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('hoy a las 11 solo ofrece las franjas de la tarde', (tester) async {
    await abrir(
      tester,
      SolicitarPrestamoScreen(equipo: proyector, reloj: () => ahora),
    );

    expect(find.byKey(const Key('franja_08-10')), findsNothing);
    expect(find.byKey(const Key('franja_10-12')), findsNothing);
    expect(find.byKey(const Key('franja_14-16')), findsOneWidget);
    expect(find.byKey(const Key('franja_16-18')), findsOneWidget);
  });

  testWidgets('el botón se habilita solo al elegir una franja', (tester) async {
    await abrir(
      tester,
      SolicitarPrestamoScreen(equipo: proyector, reloj: () => ahora),
    );

    FilledButton boton() => tester.widget<FilledButton>(
          find.byKey(const Key('solicitar_guardar')),
        );
    expect(boton().onPressed, isNull);

    await tester.tap(find.byKey(const Key('franja_14-16')));
    await tester.pump();
    expect(boton().onPressed, isNotNull);
  });

  testWidgets('guardar crea la solicitud y Mis préstamos la muestra pendiente',
      (tester) async {
    await abrir(
      tester,
      SolicitarPrestamoScreen(equipo: proyector, reloj: () => ahora),
    );

    await tester.tap(find.byKey(const Key('franja_16-18')));
    await tester.pump();
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('solicitar_guardar')));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('Solicitud guardada. Queda pendiente de sincronizar.'), findsOneWidget);
    expect(find.byType(SolicitarPrestamoScreen), findsNothing);
    expect(sync.sincronizaciones, ['uid-solicitante']);

    await tester.pumpWidget(const SizedBox());
    await abrir(tester, const MisPrestamosScreen());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.text('Proyector Epson'), findsOneWidget);
    expect(find.text('Solicitado'), findsOneWidget);
    expect(find.text('Pendiente de sincronizar'), findsOneWidget);
  });

  testWidgets('Mis préstamos sin solicitudes muestra el estado vacío', (tester) async {
    await abrir(tester, const MisPrestamosScreen());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Aún no tienes solicitudes.'), findsOneWidget);
  });
}
