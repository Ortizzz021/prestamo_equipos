import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/app.dart';

void main() {
  testWidgets('la app arranca y muestra el título', (tester) async {
    await tester.pumpWidget(const PrestamoEquiposApp());
    expect(find.text('Préstamo de Equipos'), findsOneWidget);
  });
}
