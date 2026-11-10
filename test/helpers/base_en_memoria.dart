import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:prestamo_equipos/data/local/app_database.dart';

AppDatabase baseEnMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);
