import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/core/errors/regla_negocio_exception.dart';
import 'package:prestamo_equipos/core/logging/app_logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AppLogger.reportSinkForTesting = null;
  });

  test('no lanza cuando Firebase no está inicializado', () async {
    AppLogger.reportSinkForTesting = null;

    expect(
      () => AppLogger.unexpected(StateError('internal'), StackTrace.current),
      returnsNormally,
    );
    expect(
      () => AppLogger.network(
        const SocketException('offline'),
        StackTrace.current,
      ),
      returnsNormally,
    );
    await expectLater(AppLogger.log('Catálogo actualizado'), completes);
    await expectLater(AppLogger.identify('uid-de-prueba'), completes);
  });

  test('las reglas de negocio no se envían a Crashlytics', () {
    var reportes = 0;
    AppLogger.reportSinkForTesting =
        (error, stack, {required reason, required fatal}) {
          reportes++;
        };

    AppLogger.business(const ReglaNegocioException('ESTADO', 'No permitido'));
    AppLogger.unexpected(
      const ReglaNegocioException('ESTADO', 'No permitido'),
      StackTrace.current,
    );

    expect(reportes, 0);
  });

  test('los errores inesperados se registran como no fatales', () {
    Object? errorReportado;
    String? motivo;
    bool? isFatalResult;
    AppLogger.reportSinkForTesting =
        (error, stack, {required reason, required bool fatal}) {
          errorReportado = error;
          motivo = reason;
          isFatalResult = fatal;
        };

    AppLogger.unexpected(
      StateError('no incluir este mensaje'),
      StackTrace.current,
    );

    expect(errorReportado, StateError);
    expect(motivo, 'Excepción inesperada');
    expect(isFatalResult, isFalse);
  });
}
