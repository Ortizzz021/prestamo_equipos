import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/app.dart';
import 'package:prestamo_equipos/core/errors/auth_exception.dart';
import 'package:prestamo_equipos/domain/models/perfil.dart';
import 'package:prestamo_equipos/domain/models/rol.dart';
import 'package:prestamo_equipos/features/auth/auth_controller.dart';
import 'package:prestamo_equipos/features/auth/requiere_rol.dart';
import 'package:prestamo_equipos/features/home/bodega_home.dart';
import 'package:prestamo_equipos/features/home/coordinador_home.dart';
import 'package:prestamo_equipos/features/home/solicitante_home.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;

  setUp(() => repo = FakeAuthRepository());
  tearDown(() => repo.close());

  /// Abre la app y emite la sesión guardada [sesion] (null = sin sesión).
  /// Con [restaurar] en false no se emite nada: la sesión sigue cargando.
  Future<void> abrirApp(
    WidgetTester tester, {
    Perfil? sesion,
    bool restaurar = true,
  }) async {
    await tester.pumpWidget(PrestamoEquiposApp(authRepository: repo));
    if (restaurar) {
      repo.emitirSesion(sesion);
      await tester.pumpAndSettle();
    }
  }

  Future<void> llenarLogin(WidgetTester tester) async {
    await tester.enterText(find.byKey(const Key('login_email')), 'a@prueba.com');
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('login_password')),
        matching: find.byType(TextFormField),
      ),
      'secreto123',
    );
  }

  testWidgets('muestra carga mientras se restaura la sesión', (tester) async {
    await abrirApp(tester, restaurar: false);
    expect(find.text('Restaurando sesión...'), findsOneWidget);
  });

  testWidgets('sin sesión guardada muestra el login', (tester) async {
    await abrirApp(tester);
    expect(find.text('Inicia sesión para continuar'), findsOneWidget);
  });

  testWidgets('una sesión guardada se restaura en el inicio de su rol',
      (tester) async {
    await abrirApp(tester, sesion: perfilDePrueba(Rol.bodega));
    expect(find.byType(BodegaHome), findsOneWidget);
    expect(find.text('Rol: Encargado de bodega'), findsOneWidget);
  });

  testWidgets('valida el formulario antes de llamar a Firebase',
      (tester) async {
    await abrirApp(tester);
    await tester.tap(find.byKey(const Key('login_enviar')));
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    expect(repo.llamadasLogin, 0);
  });

  testWidgets('login de coordinador lleva al inicio de coordinación',
      (tester) async {
    repo.perfilParaLogin = perfilDePrueba(Rol.coordinador);
    await abrirApp(tester);
    await llenarLogin(tester);
    await tester.tap(find.byKey(const Key('login_enviar')));
    await tester.pumpAndSettle();

    expect(find.byType(CoordinadorHome), findsOneWidget);
    expect(find.text('Bandeja de solicitudes'), findsOneWidget);
    expect(find.byType(SolicitanteHome), findsNothing);
  });

  testWidgets('credenciales inválidas muestran un mensaje comprensible',
      (tester) async {
    repo.errorSiguiente = const AuthException('Correo o contraseña incorrectos');
    await abrirApp(tester);
    await llenarLogin(tester);
    await tester.tap(find.byKey(const Key('login_enviar')));
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
    expect(find.text('Inicia sesión para continuar'), findsOneWidget);
  });

  testWidgets('bloquea envíos repetidos mientras el login está pendiente',
      (tester) async {
    repo.bloqueo = Completer<void>();
    await abrirApp(tester);
    await llenarLogin(tester);

    await tester.tap(find.byKey(const Key('login_enviar')));
    await tester.pump();
    // Botón deshabilitado con indicador de carga.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byKey(const Key('login_enviar')));
    await tester.pump();

    expect(repo.llamadasLogin, 1);

    repo.bloqueo!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(SolicitanteHome), findsOneWidget);
  });

  testWidgets('registro crea un solicitante y vuelve al inicio',
      (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();

    Finder campo(String key) => find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(TextFormField),
        );
    await tester.enterText(find.byKey(const Key('registro_nombre')), 'Ana Pérez');
    await tester.enterText(
        find.byKey(const Key('registro_email')), 'ana@prueba.com');
    await tester.enterText(campo('registro_password'), 'secreto123');
    await tester.enterText(campo('registro_confirmar'), 'secreto123');
    await tester.ensureVisible(find.byKey(const Key('registro_enviar')));
    await tester.tap(find.byKey(const Key('registro_enviar')));
    await tester.pumpAndSettle();

    expect(repo.llamadasRegistro, 1);
    expect(find.byType(SolicitanteHome), findsOneWidget);
    expect(find.text('Crear cuenta'), findsNothing);
  });

  testWidgets('cerrar sesión pide confirmación y vuelve al login',
      (tester) async {
    await abrirApp(tester, sesion: perfilDePrueba(Rol.solicitante));
    await tester.tap(find.byKey(const Key('cerrar_sesion')));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(repo.llamadasCierre, 1);
    expect(find.text('Inicia sesión para continuar'), findsOneWidget);
  });

  testWidgets('RequiereRol niega una pantalla de otro rol', (tester) async {
    final controller = AuthController(repository: repo);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(
          home: RequiereRol(
            roles: {Rol.coordinador},
            child: Text('Bandeja secreta'),
          ),
        ),
      ),
    );
    repo.emitirSesion(perfilDePrueba(Rol.solicitante));
    await tester.pumpAndSettle();

    expect(find.byType(AccesoDenegado), findsOneWidget);
    expect(find.text('Bandeja secreta'), findsNothing);
  });
}
