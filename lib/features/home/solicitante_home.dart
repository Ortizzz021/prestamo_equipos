import 'package:flutter/material.dart';

import '../../domain/models/perfil.dart';
import 'home_scaffold.dart';

class SolicitanteHome extends StatelessWidget {
  const SolicitanteHome({super.key, required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    return HomeScaffold(
      perfil: perfil,
      titulo: 'Préstamo de Equipos',
      opciones: const [
        OpcionInicio(
          icono: Icons.devices_other,
          titulo: 'Catálogo de equipos',
          descripcion: 'Consulta los equipos y solicita un préstamo',
        ),
        OpcionInicio(
          icono: Icons.assignment_outlined,
          titulo: 'Mis préstamos',
          descripcion: 'Revisa o cancela tus solicitudes',
        ),
      ],
    );
  }
}
