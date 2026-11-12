import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/regla_negocio_exception.dart';
import '../../core/utils/fechas.dart';
import '../../data/repositories/solicitud_repository.dart';
import '../../data/sync/sync_service.dart';
import '../../domain/models/estado_solicitud.dart';
import '../../domain/models/solicitud.dart';
import '../auth/auth_controller.dart';

class MisPrestamosScreen extends StatefulWidget {
  const MisPrestamosScreen({super.key});

  static Route<void> ruta() =>
      MaterialPageRoute<void>(builder: (_) => const MisPrestamosScreen());

  @override
  State<MisPrestamosScreen> createState() => _MisPrestamosScreenState();
}

class _MisPrestamosScreenState extends State<MisPrestamosScreen> {
  Stream<List<MiSolicitud>>? _solicitudes;
  String? _uid;
  bool _sincronizando = false;
  final Set<String> _cancelando = {};

  @override
  void initState() {
    super.initState();
    _uid = context.read<AuthController>().perfil?.uid;
    final uid = _uid;
    if (uid != null) {
      _solicitudes = context.read<SolicitudRepository>().observarMisSolicitudes(
        uid,
      );
    }
  }

  Future<void> _sincronizar() async {
    final uid = _uid;
    if (uid == null || _sincronizando) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sincronizando = true);
    try {
      final resumen = await context.read<SyncService>().sincronizar(uid);
      messenger.showSnackBar(SnackBar(content: Text(resumen.descripcion)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No fue posible sincronizar. Inténtalo de nuevo.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  Future<void> _reintentar(MiSolicitud item) async {
    await context.read<SolicitudRepository>().volverAIntentar(
      item.solicitud.id,
    );
    await _sincronizar();
  }

  Future<void> _descartar(MiSolicitud item) async {
    final uid = _uid;
    if (uid == null) return;
    final repo = context.read<SolicitudRepository>();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar solicitud'),
        content: Text(
          'Se eliminará del dispositivo la solicitud de ${item.equipoNombre} '
          'que el servidor rechazó. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await repo.descartarRechazada(id: item.solicitud.id, ownerUid: uid);
  }

  Future<void> _cancelar(MiSolicitud item) async {
    final uid = _uid;
    if (uid == null || _cancelando.contains(item.solicitud.id)) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar solicitud'),
        content: Text(
          '¿Quieres cancelar la solicitud de ${item.equipoNombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancelar solicitud'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    setState(() => _cancelando.add(item.solicitud.id));
    try {
      final sync = context.read<SyncService>();
      final sincronizada = await sync.ejecutarExclusivo(
        item.solicitud.id,
        () => context
            .read<SolicitudRepository>()
            .cancelarSolicitud(id: item.solicitud.id, ownerUid: uid),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sincronizada
                ? 'Solicitud cancelada.'
                : 'Solicitud cancelada en este dispositivo; no se enviará al servidor.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final mensaje = error is ReglaNegocioException
          ? error.mensaje
          : 'No fue posible cancelar la solicitud. Inténtalo de nuevo.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _cancelando.remove(item.solicitud.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis préstamos'),
        actions: [
          if (_uid != null)
            IconButton(
              key: const Key('mis_prestamos_sincronizar'),
              tooltip: 'Sincronizar',
              onPressed: _sincronizando ? null : _sincronizar,
              icon: _sincronizando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
            ),
        ],
      ),
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
                    texto:
                        'Aún no tienes solicitudes.\n'
                        'Elige un equipo del catálogo para solicitar un préstamo.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _TarjetaSolicitud(
                    item: lista[i],
                    onReintentar: () => _reintentar(lista[i]),
                    onDescartar: () => _descartar(lista[i]),
                    onCancelar: () => _cancelar(lista[i]),
                    cancelando: _cancelando.contains(lista[i].solicitud.id),
                  ),
                );
              },
            ),
    );
  }
}

class _TarjetaSolicitud extends StatelessWidget {
  const _TarjetaSolicitud({
    required this.item,
    required this.onReintentar,
    required this.onDescartar,
    required this.onCancelar,
    required this.cancelando,
  });

  final MiSolicitud item;
  final VoidCallback onReintentar;
  final VoidCallback onDescartar;
  final VoidCallback onCancelar;
  final bool cancelando;

  @override
  Widget build(BuildContext context) {
    final s = item.solicitud;
    final textos = Theme.of(context).textTheme;
    final canceladaLocalmente =
        s.estado == EstadoSolicitud.cancelado &&
        s.estadoSync != EstadoSync.sincronizado;
    final puedeDescartarRechazo =
        s.estadoSync == EstadoSync.rechazado && !canceladaLocalmente;

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
                _EtiquetaSync(estadoSync: s.estadoSync, estado: s.estado),
              ],
            ),
            if (s.estado == EstadoSolicitud.rechazado &&
                (s.motivoRechazo?.trim().isNotEmpty ?? false)) ...[
              const SizedBox(height: 6),
              Text(
                'Motivo del rechazo: ${s.motivoRechazo!.trim()}',
                style: textos.bodyMedium,
              ),
            ],
            if (s.ultimoError != null) ...[
              const SizedBox(height: 6),
              Text(
                s.ultimoError!,
                style: textos.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (puedeDescartarRechazo ||
                s.estado == EstadoSolicitud.solicitado ||
                s.estado == EstadoSolicitud.aprobado) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (s.estado == EstadoSolicitud.solicitado ||
                      s.estado == EstadoSolicitud.aprobado) ...[
                    TextButton(
                      key: Key('cancelar_${s.id}'),
                      onPressed: cancelando ? null : onCancelar,
                      child: cancelando
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (puedeDescartarRechazo) ...[
                    TextButton(
                      key: Key('descartar_${s.id}'),
                      onPressed: onDescartar,
                      child: const Text('Descartar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      key: Key('reintentar_${s.id}'),
                      onPressed: onReintentar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ],
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
  const _EtiquetaSync({required this.estadoSync, required this.estado});

  final EstadoSync estadoSync;
  final EstadoSolicitud estado;

  @override
  Widget build(BuildContext context) {
    final (icono, texto) = estado == EstadoSolicitud.cancelado &&
            estadoSync != EstadoSync.sincronizado
        ? (Icons.cloud_off_outlined, 'Cancelado sin enviar')
        : switch (estadoSync) {
      EstadoSync.pendiente => (
        Icons.cloud_upload_outlined,
        'Pendiente de sincronizar',
      ),
      EstadoSync.sincronizado => (Icons.cloud_done_outlined, 'Sincronizado'),
      EstadoSync.rechazado => (
        Icons.cloud_off_outlined,
        'Rechazado por el servidor',
      ),
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
