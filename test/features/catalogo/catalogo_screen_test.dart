import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/core/errors/api_exception.dart';
import 'package:prestamo_equipos/core/preferences/preferencias_service.dart';
import 'package:prestamo_equipos/data/repositories/equipo_repository.dart';
import 'package:prestamo_equipos/features/catalogo/catalogo_screen.dart';
import 'package:prestamo_equipos/features/catalogo/detalle_equipo_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_equipo_repository.dart';

void main() {
  late FakeEquipoRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = FakeEquipoRepository();
  });

  Future<void> abrir(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<EquipoRepository>.value(value: repo),
          Provider<PreferenciasService>(create: (_) => PreferenciasService()),
        ],
        child: const MaterialApp(home: CatalogoScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra la lista de equipos y los filtros', (tester) async {
    await abrir(tester);

    expect(find.text('Portátil Lenovo'), findsOneWidget);
    expect(find.text('Proyector Epson'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Todas'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Tablets'), findsOneWidget);
  });

  testWidgets('filtrar por categoría oculta los demás equipos', (tester) async {
    await abrir(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Proyectores'));
    await tester.pumpAndSettle();

    expect(find.text('Proyector Epson'), findsOneWidget);
    expect(find.text('Portátil Lenovo'), findsNothing);
  });

  testWidgets('estado vacío', (tester) async {
    repo.equipos = [];
    await abrir(tester);
    expect(find.text('No hay equipos disponibles en el catálogo.'), findsOneWidget);
  });

  testWidgets('error con reintento', (tester) async {
    repo.errorSiguiente = RespuestaHttpException(503);
    await abrir(tester);

    expect(
      find.text('El servicio del catálogo no está disponible en este momento.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('catalogo_reintentar')));
    await tester.pumpAndSettle();

    expect(find.text('Portátil Lenovo'), findsOneWidget);
    expect(repo.llamadas, 2);
  });

  testWidgets('tocar un equipo abre su detalle', (tester) async {
    await abrir(tester);
    await tester.tap(find.text('Proyector Epson'));
    await tester.pumpAndSettle();

    expect(find.byType(DetalleEquipoScreen), findsOneWidget);
    expect(find.text('3600 lúmenes'), findsOneWidget);
    expect(find.text('Código: eq-2'), findsOneWidget);
  });
}
