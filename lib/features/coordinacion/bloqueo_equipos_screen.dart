import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/api_exception.dart';
import '../../core/errors/regla_negocio_exception.dart';
import '../../data/repositories/coordinacion_repository.dart';
import '../../data/repositories/disponibilidad_repository.dart';
import '../../data/repositories/equipo_repository.dart';
import '../../domain/models/estado_equipo.dart';
import '../../domain/models/equipo.dart';
import '../../domain/models/rol.dart';
import '../auth/auth_controller.dart';
import '../auth/requiere_rol.dart';

class BloqueoEquiposScreen extends StatelessWidget {
  const BloqueoEquiposScreen({super.key});

  @override
  Widget build(BuildContext context) => const RequiereRol(
    roles: {Rol.coordinador},
    child: _BloqueoEquiposProtegido(),
  );
}

class _BloqueoEquiposProtegido extends StatefulWidget {
  const _BloqueoEquiposProtegido();

  @override
  State<_BloqueoEquiposProtegido> createState() =>
      _BloqueoEquiposProtegidoState();
}

class _BloqueoEquiposProtegidoState extends State<_BloqueoEquiposProtegido> {
  late Future<List<Equipo>> _equipos;
  final Set<String> _enProceso = {};
  int _revision = 0;
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    _equipos = context.read<EquipoRepository>().obtenerEquipos();
  }

  Future<void> _cambiarBloqueo(Equipo equipo, bool bloquear) async {
    final motivo = bloquear ? await _pedirMotivo(equipo) : null;
    if (bloquear && (motivo == null || motivo.isEmpty)) return;
    if (!mounted) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bloquear ? 'Bloquear equipo' : 'Desbloquear equipo'),
        content: Text(
          bloquear
              ? '¿Confirmas bloquear ${equipo.nombre}?'
              : '¿Confirmas desbloquear ${equipo.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(bloquear ? 'Bloquear' : 'Desbloquear'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final uid = context.read<AuthController>().perfil?.uid;
    if (uid == null) return;
    setState(() => _enProceso.add(equipo.id));
    try {
      final repository = context.read<CoordinacionRepository>();
      if (bloquear) {
        await repository.bloquear(
          equipoId: equipo.id,
          motivo: motivo!,
          coordinadorUid: uid,
        );
      } else {
        await repository.desbloquear(equipoId: equipo.id, coordinadorUid: uid);
      }
      if (mounted) _mensaje('Estado del equipo actualizado.');
    } catch (error) {
      if (!mounted) return;
      _mensaje(
        error is ReglaNegocioException
            ? error.mensaje
            : 'Sin conexión o no fue posible actualizar el equipo.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _enProceso.remove(equipo.id));
    }
  }

  Future<String?> _pedirMotivo(Equipo equipo) async {
    final controller = TextEditingController();
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Motivo del bloqueo: ${equipo.nombre}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motivo',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    controller.dispose();
    return resultado?.trim().isEmpty ?? true ? null : resultado;
  }

  void _mensaje(String texto, {bool error = false}) {
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
    final disponibilidad = context.read<DisponibilidadRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Bloqueo de equipos')),
      body: FutureBuilder<List<Equipo>>(
        key: ValueKey(_revision),
        future: _equipos,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_mensajeCatalogo(snapshot.error)),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const Key('bloqueo_reintentar'),
                      onPressed: () {
                        setState(() {
                          _equipos = context
                              .read<EquipoRepository>()
                              .obtenerEquipos();
                          _revision++;
                        });
                      },
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
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay equipos en el catálogo.'));
          }
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final equipo = snapshot.data![index];
              return StreamBuilder<EstadoEquipo>(
                key: ValueKey('${equipo.id}_$_revision'),
                stream: disponibilidad.observarEstadoEquipo(equipo.id),
                builder: (context, estadoSnapshot) {
                  final estado = estadoSnapshot.hasError
                      ? const EstadoEquipo.noVerificado()
                      : estadoSnapshot.data ?? const EstadoEquipo.noVerificado();
                  final ocupado = _enProceso.contains(equipo.id);
                  return SwitchListTile(
                    title: Text(equipo.nombre),
                    subtitle: estado.bloqueado
                        ? Text(estado.motivo ?? 'Bloqueado')
                        : estado.verificado
                        ? Text(equipo.categoria)
                        : const Text('Sin conexión: no se verificó el estado'),
                    value: estado.bloqueado,
                    onChanged: !estado.verificado || ocupado
                        ? null
                        : (valor) => _cambiarBloqueo(equipo, valor),
                    secondary: ocupado
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _mensajeCatalogo(Object? error) => switch (error) {
    ApiException api => api.mensaje,
    _ => 'No se pudo cargar el catálogo. Comprueba tu conexión e inténtalo de nuevo.',
  };
}
