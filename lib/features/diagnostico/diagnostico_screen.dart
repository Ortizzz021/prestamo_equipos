import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/logging/app_logger.dart';

class DiagnosticoScreen extends StatelessWidget {
  const DiagnosticoScreen({super.key});

  Future<void> _enviarEvento(BuildContext context) async {
    final enviado = await AppLogger.sendTestNonFatal();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enviado
              ? 'Evento no fatal enviado. Revisa Crashlytics después de unos minutos.'
              : 'No se pudo enviar el evento de diagnóstico.',
        ),
      ),
    );
  }

  Future<void> _confirmarCierre(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Forzar cierre de prueba'),
        content: const Text(
          'La aplicación se cerrará. Crashlytics enviará el reporte al volver a abrirla.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Forzar cierre'),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;
    await AppLogger.forceTestCrash();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Las pruebas habilitan Crashlytics para esta ejecución de desarrollo. Al reiniciar, el modo debug vuelve a iniciar con la colección desactivada.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _enviarEvento(context),
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Enviar error no fatal de prueba'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _confirmarCierre(context),
            icon: const Icon(Icons.warning_amber_outlined),
            label: const Text('Forzar cierre de prueba'),
          ),
        ],
      ),
    );
  }
}
