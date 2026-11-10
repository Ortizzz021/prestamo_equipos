import 'package:flutter/material.dart';

import '../../domain/models/equipo.dart';
import '../solicitudes/solicitar_prestamo_screen.dart';
import 'widgets/imagen_equipo.dart';

class DetalleEquipoScreen extends StatelessWidget {
  const DetalleEquipoScreen({super.key, required this.equipo});

  final Equipo equipo;

  static Route<void> ruta(Equipo equipo) => MaterialPageRoute<void>(
    builder: (_) => DetalleEquipoScreen(equipo: equipo),
  );

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del equipo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'equipo-${equipo.id}',
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: ImagenEquipo(url: equipo.imagenUrl, borderRadius: 12),
              ),
            ),
            const SizedBox(height: 16),
            Text(equipo.nombre, style: textos.headlineSmall),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.category_outlined, size: 18),
                label: Text(equipo.categoria),
              ),
            ),
            const SizedBox(height: 16),
            Text('Descripción', style: textos.titleMedium),
            const SizedBox(height: 4),
            Text(
              equipo.descripcion.isEmpty
                  ? 'Este equipo no tiene descripción.'
                  : equipo.descripcion,
              style: textos.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text('Código: ${equipo.id}', style: textos.bodySmall),
            const SizedBox(height: 24),
            Text(
              'La disponibilidad del equipo se confirma al momento de aprobar la solicitud.',
              style: textos.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('detalle_solicitar'),
              onPressed: () => Navigator.of(context).push(
                SolicitarPrestamoScreen.ruta(equipo),
              ),
              icon: const Icon(Icons.event_available),
              label: const Text('Solicitar préstamo'),
            ),
          ],
        ),
      ),
    );
  }
}
