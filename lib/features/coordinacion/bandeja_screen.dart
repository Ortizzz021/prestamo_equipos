import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/regla_negocio_exception.dart';
import '../../data/repositories/coordinacion_repository.dart';
import '../../domain/models/rol.dart';
import '../../domain/models/solicitud.dart';
import '../auth/auth_controller.dart';
import '../auth/requiere_rol.dart';
import '../../core/widgets/dialogo_texto.dart';

class BandejaScreen extends StatelessWidget {
  const BandejaScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const RequiereRol(roles: {Rol.coordinador}, child: _BandejaProtegida());
}

class _BandejaProtegida extends StatefulWidget {
  const _BandejaProtegida();

  @override
  State<_BandejaProtegida> createState() => _BandejaProtegidaState();
}

class _BandejaProtegidaState extends State<_BandejaProtegida> {
  int _revision = 0;
  final Set<String> _enProceso = {};

  Future<bool> _confirmar({
    required String titulo,
    required String mensaje,
    required String accion,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(titulo),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(accion),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> _pedirMotivo() {
    return DialogoTexto.mostrar(
      context,
      titulo: 'Motivo del rechazo',
      etiqueta: 'Motivo',
      mensajeObligatorio: 'Escribe el motivo del rechazo.',
    );
  }

  Future<void> _aprobar(Solicitud solicitud) async {
    final confirmado = await _confirmar(
      titulo: 'Aprobar solicitud',
      mensaje:
          '¿Confirmas aprobar el préstamo de '
          '${solicitud.equipoNombre ?? solicitud.equipoId}?',
      accion: 'Aprobar',
    );
    if (!confirmado || !mounted) return;
    await _ejecutar(solicitud, (repo, uid) => repo.aprobar(solicitud.id, uid));
  }

  Future<void> _rechazar(Solicitud solicitud) async {
    final motivo = await _pedirMotivo();
    if (motivo == null || !mounted) return;
    final confirmado = await _confirmar(
      titulo: 'Confirmar rechazo',
      mensaje:
          '¿Rechazas la solicitud de '
          '${solicitud.equipoNombre ?? solicitud.equipoId}?',
      accion: 'Rechazar',
    );
    if (!confirmado || !mounted) return;
    await _ejecutar(
      solicitud,
      (repo, uid) => repo.rechazar(solicitud.id, uid, motivo),
    );
  }

  Future<void> _ejecutar(
    Solicitud solicitud,
    Future<void> Function(CoordinacionRepository, String) operacion,
  ) async {
    final uid = context.read<AuthController>().perfil?.uid;
    if (uid == null || _enProceso.contains(solicitud.id)) return;
    setState(() => _enProceso.add(solicitud.id));
    try {
      await operacion(context.read<CoordinacionRepository>(), uid);
      if (mounted) _mostrarMensaje('Operación completada.');
    } catch (error) {
      if (!mounted) return;
      _mostrarMensaje(
        error is ReglaNegocioException
            ? error.mensaje
            : 'Sin conexión o no fue posible completar la operación.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _enProceso.remove(solicitud.id));
    }
  }

  void _mostrarMensaje(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: error ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<CoordinacionRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Bandeja de solicitudes')),
      body: StreamBuilder<List<Solicitud>>(
        key: ValueKey(_revision),
        stream: repository.observarSolicitudesPendientes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_mensajeCarga(snapshot.error)),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const Key('bandeja_reintentar'),
                      onPressed: () => setState(() => _revision++),
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
            return const Center(child: Text('No hay solicitudes pendientes.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: solicitudes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final solicitud = solicitudes[index];
              final enProceso = _enProceso.contains(solicitud.id);
              final ocupado = _enProceso.isNotEmpty;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        solicitud.equipoNombre ?? solicitud.equipoId,
                        key: Key('solicitud_equipo_${solicitud.id}'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('Fecha: ${_fecha(solicitud.franja.fecha)}'),
                      Text('Franja: ${solicitud.franja.slot.etiqueta}'),
                      Text('Solicitante: ${solicitud.solicitanteUid}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              key: Key('rechazar_${solicitud.id}'),
                              onPressed: ocupado
                                  ? null
                                  : () => _rechazar(solicitud),
                              child: const Text('Rechazar'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              key: Key('aprobar_${solicitud.id}'),
                              onPressed: ocupado
                                  ? null
                                  : () => _aprobar(solicitud),
                              child: enProceso
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Aprobar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _fecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

  String _mensajeCarga(Object? error) {
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
}
