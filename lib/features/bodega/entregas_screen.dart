import 'package:flutter/material.dart';

import '../../domain/models/rol.dart';
import '../auth/requiere_rol.dart';
import 'bodega_solicitudes_screen.dart';

class EntregasScreen extends StatelessWidget {
  const EntregasScreen({super.key});

  @override
  Widget build(BuildContext context) => const RequiereRol(
    roles: {Rol.bodega},
    child: BodegaSolicitudesScreen(devoluciones: false),
  );
}
