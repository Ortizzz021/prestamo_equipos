import 'package:flutter/material.dart';

import '../../domain/models/perfil.dart';
import 'home_scaffold.dart';

class BodegaHome extends StatelessWidget {
  const BodegaHome({super.key, required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    return HomeScaffold(
      perfil: perfil,
      titulo: 'Bodega',
      opciones: const [
        OpcionInicio(
          icono: Icons.outbox_outlined,
          titulo: 'Registrar entrega',
          descripcion: 'Entrega física de préstamos aprobados',
        ),
        OpcionInicio(
          icono: Icons.assignment_return_outlined,
          titulo: 'Registrar devolución',
          descripcion: 'Recibe equipos entregados con observación',
        ),
      ],
    );
  }
}
