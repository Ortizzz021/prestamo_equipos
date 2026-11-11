import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/regla_negocio_exception.dart';
import '../../data/repositories/bodega_repository.dart';
import '../../domain/models/solicitud.dart';
import '../auth/auth_controller.dart';
import '../../core/widgets/dialogo_texto.dart';

class BodegaSolicitudesScreen extends StatefulWidget {
  const BodegaSolicitudesScreen({super.key, required this.devoluciones});

  final bool devoluciones;

  @override
  State<BodegaSolicitudesScreen> createState() =>
      _BodegaSolicitudesScreenState();
}

class _BodegaSolicitudesScreenState extends State<BodegaSolicitudesScreen> {
  int _revision = 0;
  final Set<String> _guardando = {};
  late Stream<List<Solicitud>> _solicitudes;
  bool _inicializado = false;

  Stream<List<Solicitud>> _stream(BodegaRepository repository) =>
      widget.devoluciones
      ? repository.observarSolicitudesEntregadas()
      : repository.observarSolicitudesAprobadas();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    _solicitudes = _stream(context.read<BodegaRepository>());
  }

  void _reintentar() {
    setState(() {
      _revision++;
      _solicitudes = _stream(context.read<BodegaRepository>());
    });
  }

  Future<String?> _pedirObservacion(Solicitud solicitud) {
    return DialogoTexto.mostrar(
      context,
      titulo: widget.devoluciones
          ? 'Registrar devolución'
          : 'Registrar entrega',
      subtitulo: solicitud.equipoNombre ?? solicitud.equipoId,
      etiqueta: 'Observación del estado físico',
      hint: 'Describe el estado del equipo',
      mensajeObligatorio: 'La observación es obligatoria.',
      maxLength: 240,
    );
  }

  Future<bool> _confirmar(Solicitud solicitud) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            widget.devoluciones ? 'Confirmar devolución' : 'Confirmar entrega',
          ),
          content: Text(
            widget.devoluciones
                ? '¿Confirmas que recibiste '
                      '${solicitud.equipoNombre ?? solicitud.equipoId}?'
                : '¿Confirmas que entregaste '
                      '${solicitud.equipoNombre ?? solicitud.equipoId}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _registrar(Solicitud solicitud) async {
    if (_guardando.contains(solicitud.id)) return;
    final observacion = await _pedirObservacion(solicitud);
    if (observacion == null || !mounted) return;
    final confirmado = await _confirmar(solicitud);
    if (!confirmado || !mounted) return;
    final uid = context.read<AuthController>().perfil?.uid;
    if (uid == null) {
      _mostrarMensaje(
        'Tu sesión expiró. Vuelve a iniciar sesión.',
        error: true,
      );
      return;
    }

    setState(() => _guardando.add(solicitud.id));
    try {
      final repository = context.read<BodegaRepository>();
      if (widget.devoluciones) {
        await repository.registrarDevolucion(solicitud.id, uid, observacion);
      } else {
        await repository.registrarEntrega(solicitud.id, uid, observacion);
      }
      if (mounted) {
        _mostrarMensaje(
          widget.devoluciones
              ? 'Devolución registrada. La franja quedó liberada.'
              : 'Entrega registrada.',
        );
      }
    } catch (error) {
      if (!mounted) return;
      _mostrarMensaje(
        error is ReglaNegocioException
            ? error.mensaje
            : 'Sin conexión o no fue posible registrar la operación.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _guardando.remove(solicitud.id));
    }
  }

  void _mostrarMensaje(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: error ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.devoluciones ? 'Registrar devolución' : 'Registrar entrega',
        ),
      ),
      body: StreamBuilder<List<Solicitud>>(
        key: ValueKey(_revision),
        stream: _solicitudes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_mensajeError(snapshot.error)),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const Key('bodega_reintentar'),
                      onPressed: _reintentar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final solicitudes = snapshot.data!;
          if (solicitudes.isEmpty) {
            return Center(
              child: Text(
                widget.devoluciones
                    ? 'No hay equipos pendientes de devolución.'
                    : 'No hay equipos pendientes de entrega.',
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: solicitudes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final solicitud = solicitudes[index];
              final ocupado = _guardando.contains(solicitud.id);
              return Card(
                child: ListTile(
                  key: Key('bodega_solicitud_${solicitud.id}'),
                  title: Text(solicitud.equipoNombre ?? solicitud.equipoId),
                  subtitle: Text(
                    'Solicitante: ${solicitud.solicitanteUid}\n'
                    'Fecha: ${_fecha(solicitud.franja.fecha)} · '
                    '${solicitud.franja.slot.etiqueta}',
                  ),
                  isThreeLine: true,
                  trailing: ocupado
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  enabled: !ocupado,
                  onTap: ocupado ? null : () => _registrar(solicitud),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _mensajeError(Object? error) {
    if (error is FirebaseException &&
        const {
          'unavailable',
          'deadline-exceeded',
          'cancelled',
          'network-request-failed',
        }.contains(error.code)) {
      return 'Sin conexión. Conéctate a internet e inténtalo de nuevo.';
    }
    return 'No se pudieron cargar las solicitudes.';
  }

  String _fecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
}
