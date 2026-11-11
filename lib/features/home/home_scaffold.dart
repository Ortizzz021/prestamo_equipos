import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/perfil.dart';
import '../auth/auth_controller.dart';
import '../diagnostico/diagnostico_screen.dart';

class OpcionInicio {
  const OpcionInicio({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;

  final VoidCallback? onTap;
}

class HomeScaffold extends StatelessWidget {
  const HomeScaffold({
    super.key,
    required this.perfil,
    required this.titulo,
    required this.opciones,
  });

  final Perfil perfil;
  final String titulo;
  final List<OpcionInicio> opciones;

  Future<void> _confirmarCierre(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;

    final auth = context.read<AuthController>();
    Navigator.of(context).popUntil((ruta) => ruta.isFirst);
    await auth.cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.select<AuthController, bool>((a) => a.cargando);
    final nombre = perfil.nombre.isEmpty ? perfil.email : perfil.nombre;

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          if (kDebugMode)
            IconButton(
              key: const Key('diagnostico'),
              tooltip: 'Diagnóstico',
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DiagnosticoScreen(),
                ),
              ),
            ),
          IconButton(
            key: const Key('cerrar_sesion'),
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: cargando ? null : () => _confirmarCierre(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Hola, $nombre', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: const Icon(Icons.badge_outlined, size: 18),
              label: Text('Rol: ${perfil.rol.etiqueta}'),
            ),
          ),
          const SizedBox(height: 16),
          for (final opcion in opciones)
            Card(
              child: ListTile(
                leading: Icon(opcion.icono),
                title: Text(opcion.titulo),
                subtitle: Text(opcion.descripcion),
                trailing: opcion.onTap == null
                    ? const Text('Próximamente')
                    : const Icon(Icons.chevron_right),
                enabled: opcion.onTap != null,
                onTap: opcion.onTap,
              ),
            ),
        ],
      ),
    );
  }
}
