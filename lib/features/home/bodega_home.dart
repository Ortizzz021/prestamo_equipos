import 'package:flutter/material.dart';

import '../../domain/models/perfil.dart';
import '../bodega/devoluciones_screen.dart';
import '../bodega/entregas_screen.dart';
import 'home_scaffold.dart';

class BodegaHome extends StatelessWidget {
  const BodegaHome({super.key, required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    return HomeScaffold(
      perfil: perfil,
      titulo: 'Bodega',
      opciones: [
        OpcionInicio(
          icono: Icons.outbox_outlined,
          titulo: 'Registrar entrega',
          descripcion: 'Entrega física de préstamos aprobados',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const EntregasScreen()),
          ),
        ),
        OpcionInicio(
          icono: Icons.assignment_return_outlined,
          titulo: 'Registrar devolución',
          descripcion: 'Recibe equipos entregados con observación',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const DevolucionesScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
