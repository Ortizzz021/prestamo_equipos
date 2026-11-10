import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/app.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_sync_service.dart';

void main() {
  testWidgets('la app arranca y, sin sesión, muestra el login', (tester) async {
    final repo = FakeAuthRepository();
    addTearDown(repo.close);

    await tester.pumpWidget(PrestamoEquiposApp(authRepository: repo, syncService: FakeSyncService()));
    repo.emitirSesion(null);
    await tester.pumpAndSettle();

    expect(find.text('Préstamo de Equipos'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
