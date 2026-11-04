import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // La inicialización de Firebase y Crashlytics se agrega en el commit de
  // configuración de Firebase.
  runApp(const PrestamoEquiposApp());
}
