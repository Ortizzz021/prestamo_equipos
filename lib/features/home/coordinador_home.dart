import 'package:flutter/material.dart';

import '../../domain/models/perfil.dart';
import 'home_scaffold.dart';

/// Inicio del rol Coordinador: aprueba o rechaza solicitudes y bloquea equipos.
class CoordinadorHome extends StatelessWidget {
  const CoordinadorHome({super.key, required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    return HomeScaffold(
      perfil: perfil,
      titulo: 'Coordinación',
      opciones: const [
        OpcionInicio(
          icono: Icons.inbox_outlined,
          titulo: 'Bandeja de solicitudes',
          descripcion: 'Aprueba o rechaza solicitudes pendientes',
        ),
        OpcionInicio(
          icono: Icons.block,
          titulo: 'Bloqueo de equipos',
          descripcion: 'Marca equipos que no deben prestarse',
        ),
      ],
    );
  }
}
