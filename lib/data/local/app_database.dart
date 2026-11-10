import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('SolicitudRow')
@TableIndex(name: 'idx_solicitudes_owner', columns: {#ownerUid})
class Solicitudes extends Table {
  TextColumn get id => text()();
  TextColumn get ownerUid => text()();
  TextColumn get equipoId => text()();
  TextColumn get equipoNombre => text()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get slot => text()();
  TextColumn get estado => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get estadoSync => text()();
  TextColumn get ultimoError => text().nullable()();
  TextColumn get observacionEntrega => text().nullable()();
  TextColumn get observacionDevolucion => text().nullable()();
  TextColumn get motivoRechazo => text().nullable()();
  DateTimeColumn get creadaEn => dateTime()();
  DateTimeColumn get actualizadaEn => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Solicitudes])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _abrirConexion());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _abrirConexion() => driftDatabase(
        name: 'prestamo_equipos',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );

  Stream<List<SolicitudRow>> observarSolicitudesDe(String ownerUid) {
    return (select(solicitudes)
          ..where((s) => s.ownerUid.equals(ownerUid))
          ..orderBy([
            (s) => OrderingTerm.desc(s.creadaEn),
          ]))
        .watch();
  }

  Future<List<SolicitudRow>> solicitudesActivasDe({
    required String ownerUid,
    required String equipoId,
    required DateTime fecha,
    required String slot,
    required List<String> estadosActivos,
  }) {
    return (select(solicitudes)
          ..where(
            (s) =>
                s.ownerUid.equals(ownerUid) &
                s.equipoId.equals(equipoId) &
                s.fecha.equals(fecha) &
                s.slot.equals(slot) &
                s.estado.isIn(estadosActivos),
          ))
        .get();
  }

  Future<SolicitudRow?> buscarSolicitud(String id) {
    return (select(solicitudes)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<void> guardarSolicitud(SolicitudesCompanion fila) {
    return into(solicitudes).insertOnConflictUpdate(fila);
  }
}
