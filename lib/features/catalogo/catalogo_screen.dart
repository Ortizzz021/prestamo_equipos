import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/preferences/preferencias_service.dart';
import '../../data/repositories/equipo_repository.dart';
import '../../domain/models/equipo.dart';
import 'catalogo_controller.dart';
import 'detalle_equipo_screen.dart';
import 'widgets/imagen_equipo.dart';

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  static Route<void> ruta() => MaterialPageRoute<void>(
        builder: (_) => const CatalogoScreen(),
      );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CatalogoController(
        repository: context.read<EquipoRepository>(),
        preferencias: context.read<PreferenciasService>(),
      )..cargar(),
      child: const _CatalogoVista(),
    );
  }
}

class _CatalogoVista extends StatelessWidget {
  const _CatalogoVista();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CatalogoController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de equipos')),
      body: switch (controller.estado) {
        EstadoCatalogo.cargando => const _Cargando(),
        EstadoCatalogo.error => _Error(
            mensaje: controller.mensajeError ?? 'No fue posible cargar el catálogo.',
            puedeReintentar: controller.puedeReintentar,
            onReintentar: controller.reintentar,
          ),
        EstadoCatalogo.vacio => _Vacio(onRecargar: controller.cargar),
        EstadoCatalogo.datos => _ListaEquipos(controller: controller),
      },
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando equipos...'),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({
    required this.mensaje,
    required this.puedeReintentar,
    required this.onReintentar,
  });

  final String mensaje;
  final bool puedeReintentar;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('catalogo_reintentar'),
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: Text(puedeReintentar ? 'Reintentar' : 'Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.onRecargar});

  final Future<void> Function() onRecargar;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRecargar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.inventory_2_outlined, size: 56),
          SizedBox(height: 16),
          Text(
            'No hay equipos disponibles en el catálogo.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ListaEquipos extends StatelessWidget {
  const _ListaEquipos({required this.controller});

  final CatalogoController controller;

  @override
  Widget build(BuildContext context) {
    final equipos = controller.equiposFiltrados;
    final error = controller.mensajeError;

    return Column(
      children: [
        _FiltroCategorias(
          categorias: controller.categorias,
          seleccionada: controller.categoriaSeleccionada,
          onSeleccionar: controller.seleccionarCategoria,
        ),
        if (error != null)
          MaterialBanner(
            content: Text(error),
            leading: const Icon(Icons.warning_amber),
            actions: [
              TextButton(
                onPressed: controller.descartarError,
                child: const Text('Cerrar'),
              ),
              TextButton(
                onPressed: controller.reintentar,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.cargar,
            child: equipos.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      Text(
                        'No hay equipos en esta categoría.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: equipos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _TarjetaEquipo(equipo: equipos[i]),
                  ),
          ),
        ),
      ],
    );
  }
}

class _FiltroCategorias extends StatelessWidget {
  const _FiltroCategorias({
    required this.categorias,
    required this.seleccionada,
    required this.onSeleccionar,
  });

  final List<String> categorias;
  final String? seleccionada;
  final ValueChanged<String?> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Todas'),
              selected: seleccionada == null,
              onSelected: (_) => onSeleccionar(null),
            ),
          ),
          for (final categoria in categorias)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(categoria),
                selected: seleccionada == categoria,
                onSelected: (_) => onSeleccionar(categoria),
              ),
            ),
        ],
      ),
    );
  }
}

class _TarjetaEquipo extends StatelessWidget {
  const _TarjetaEquipo({required this.equipo});

  final Equipo equipo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(DetalleEquipoScreen.ruta(equipo)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'equipo-${equipo.id}',
                child: ImagenEquipo(url: equipo.imagenUrl, width: 88, height: 66),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipo.nombre,
                      style: textos.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(equipo.categoria, style: textos.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
