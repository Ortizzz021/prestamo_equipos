import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/fechas.dart';
import '../../data/repositories/solicitud_repository.dart';
import '../../domain/models/estado_solicitud.dart';
import '../../domain/models/solicitud.dart';
import '../auth/auth_controller.dart';

class MisPrestamosScreen extends StatefulWidget {
  const MisPrestamosScreen({super.key});

  static Route<void> ruta() => MaterialPageRoute<void>(
        builder: (_) => const MisPrestamosScreen(),
      );

  @override
  State<MisPrestamosScreen> createState() => _MisPrestamosScreenState();
}

class _MisPrestamosScreenState extends State<MisPrestamosScreen> {
  Stream<List<MiSolicitud>>? _solicitudes;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthController>().perfil?.uid;
    if (uid != null) {
      _solicitudes = context.read<SolicitudRepository>().observarMisSolicitudes(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis préstamos')),
      body: _solicitudes == null
          ? const _Mensaje(
              icono: Icons.lock_outline,
              texto: 'Inicia sesión para ver tus préstamos.',
            )
          : StreamBuilder<List<MiSolicitud>>(
              stream: _solicitudes,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _Mensaje(
                    icono: Icons.error_outline,
                    texto: 'No fue posible leer tus préstamos guardados.',
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final lista = snapshot.data!;
                if (lista.isEmpty) {
                  return const _Mensaje(
                    icono: Icons.assignment_outlined,
                    texto: 'Aún no tienes solicitudes.\n'
                        'Elige un equipo del catálogo para solicitar un préstamo.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _TarjetaSolicitud(item: lista[i]),
                );
              },
            ),
    );
  }
}

class _TarjetaSolicitud extends StatelessWidget {
  const _TarjetaSolicitud({required this.item});

  final MiSolicitud item;

  @override
  Widget build(BuildContext context) {
    final s = item.solicitud;
    final textos = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.equipoNombre, style: textos.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${Fechas.completa(s.franja.fecha)} · ${s.franja.slot.etiqueta}',
              style: textos.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _EtiquetaEstado(estado: s.estado),
                _EtiquetaSync(estadoSync: s.estadoSync),
              ],
            ),
            if (s.ultimoError != null) ...[
              const SizedBox(height: 6),
              Text(
                s.ultimoError!,
                style: textos.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EtiquetaEstado extends StatelessWidget {
  const _EtiquetaEstado({required this.estado});

  final EstadoSolicitud estado;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: const Icon(Icons.flag_outlined, size: 16),
      label: Text(estado.etiqueta),
    );
  }
}

class _EtiquetaSync extends StatelessWidget {
  const _EtiquetaSync({required this.estadoSync});

  final EstadoSync estadoSync;

  @override
  Widget build(BuildContext context) {
    final (icono, texto) = switch (estadoSync) {
      EstadoSync.pendiente => (Icons.cloud_upload_outlined, 'Pendiente de sincronizar'),
      EstadoSync.sincronizado => (Icons.cloud_done_outlined, 'Sincronizado'),
      EstadoSync.rechazado => (Icons.cloud_off_outlined, 'Rechazado por el servidor'),
    };
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icono, size: 16),
      label: Text(texto),
    );
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56),
            const SizedBox(height: 16),
            Text(texto, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
