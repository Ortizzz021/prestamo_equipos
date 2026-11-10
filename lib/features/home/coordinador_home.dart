import 'package:flutter/material.dart';

import '../../domain/models/perfil.dart';
import '../coordinacion/bandeja_screen.dart';
import '../coordinacion/bloqueo_equipos_screen.dart';
import 'home_scaffold.dart';

class CoordinadorHome extends StatelessWidget {
  const CoordinadorHome({super.key, required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    return HomeScaffold(
      perfil: perfil,
      titulo: 'Coordinación',
      opciones: [
        OpcionInicio(
          icono: Icons.inbox_outlined,
          titulo: 'Bandeja de solicitudes',
          descripcion: 'Aprueba o rechaza solicitudes pendientes',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const BandejaScreen()),
          ),
        ),
        OpcionInicio(
          icono: Icons.block,
          titulo: 'Bloqueo de equipos',
          descripcion: 'Marca equipos que no deben prestarse',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const BloqueoEquiposScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
