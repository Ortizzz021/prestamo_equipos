import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/regla_negocio_exception.dart';
import '../../domain/models/equipo.dart';
import '../../domain/models/estado_solicitud.dart';
import '../../domain/models/franja.dart';
import '../../domain/models/solicitud.dart';
import '../local/app_database.dart';

class MiSolicitud {
  const MiSolicitud({required this.solicitud, required this.equipoNombre});

  final Solicitud solicitud;
  final String equipoNombre;
}

class SolicitudRepository {
  SolicitudRepository({
    required this.db,
    Uuid? uuid,
    DateTime Function()? reloj,
  })  : _uuid = uuid ?? const Uuid(),
        _reloj = reloj ?? DateTime.now;

  final AppDatabase db;
  final Uuid _uuid;
  final DateTime Function() _reloj;

  static final List<String> _estadosActivos = [
    for (final e in EstadoSolicitud.values)
      if (!e.esTerminal) e.valor,
  ];

  Stream<List<MiSolicitud>> observarMisSolicitudes(String ownerUid) {
    return db
        .observarSolicitudesDe(ownerUid)
        .map((filas) => filas.map(_aMiSolicitud).toList());
  }

  Future<List<MiSolicitud>> pendientesDeEnvio(String ownerUid) async {
    final filas = await db.pendientesDe(ownerUid, EstadoSync.pendiente.valor);
    return filas.map(_aMiSolicitud).toList();
  }

  Future<bool> confirmarEnvio({
    required String id,
    required int versionEnviada,
    EstadoSolicitud? estadoRemoto,
  }) async {
    final filas = await db.actualizarSiVersion(
      id: id,
      version: versionEnviada,
      cambios: SolicitudesCompanion(
        estadoSync: Value(EstadoSync.sincronizado.valor),
        ultimoError: const Value(null),
        estado: estadoRemoto == null
            ? const Value.absent()
            : Value(estadoRemoto.valor),
      ),
    );
    return filas > 0;
  }

  Future<void> registrarFalloTemporal({
    required String id,
    required int versionEnviada,
    required String motivo,
  }) {
    return db.actualizarSiVersion(
      id: id,
      version: versionEnviada,
      cambios: SolicitudesCompanion(ultimoError: Value(motivo)),
    );
  }

  Future<void> registrarRechazo({
    required String id,
    required int versionEnviada,
    required String motivo,
  }) {
    return db.actualizarSiVersion(
      id: id,
      version: versionEnviada,
      cambios: SolicitudesCompanion(
        estadoSync: Value(EstadoSync.rechazado.valor),
        ultimoError: Value(motivo),
      ),
    );
  }

  Future<void> volverAIntentar(String id) {
    return db.actualizarSolicitud(
      id,
      SolicitudesCompanion(
        estadoSync: Value(EstadoSync.pendiente.valor),
        ultimoError: const Value(null),
      ),
    );
  }

  Future<bool> descartarRechazada({required String id, required String ownerUid}) async {
    final borradas = await db.eliminarSolicitud(
      id: id,
      ownerUid: ownerUid,
      estadoSync: EstadoSync.rechazado.valor,
    );
    return borradas > 0;
  }

  Future<MiSolicitud> crearSolicitud({
    required String ownerUid,
    required Equipo equipo,
    required Franja franja,
  }) async {
    final ahora = _reloj();
    final solicitud = Solicitud.nueva(
      id: _uuid.v4(),
      solicitanteUid: ownerUid,
      equipoId: equipo.id,
      franja: franja,
      ahora: ahora,
    );

    final duplicadas = await db.solicitudesActivasDe(
      ownerUid: ownerUid,
      equipoId: equipo.id,
      fecha: franja.fecha,
      slot: franja.slot.codigo,
      estadosActivos: _estadosActivos,
    );
    if (duplicadas.isNotEmpty) {
      throw const ReglaNegocioException(
        'SOLICITUD_DUPLICADA',
        'Ya tienes una solicitud activa para este equipo en esa franja.',
      );
    }

    await db.guardarSolicitud(_aFila(solicitud, equipo.nombre));
    return MiSolicitud(solicitud: solicitud, equipoNombre: equipo.nombre);
  }

  SolicitudesCompanion _aFila(Solicitud s, String equipoNombre) {
    return SolicitudesCompanion.insert(
      id: s.id,
      ownerUid: s.solicitanteUid,
      equipoId: s.equipoId,
      equipoNombre: equipoNombre,
      fecha: s.franja.fecha,
      slot: s.franja.slot.codigo,
      estado: s.estado.valor,
      version: Value(s.version),
      estadoSync: s.estadoSync.valor,
      ultimoError: Value(s.ultimoError),
      observacionEntrega: Value(s.observacionEntrega),
      observacionDevolucion: Value(s.observacionDevolucion),
      motivoRechazo: Value(s.motivoRechazo),
      creadaEn: s.creadaEn,
      actualizadaEn: s.actualizadaEn,
    );
  }

  MiSolicitud _aMiSolicitud(SolicitudRow f) {
    return MiSolicitud(
      equipoNombre: f.equipoNombre,
      solicitud: Solicitud(
        id: f.id,
        solicitanteUid: f.ownerUid,
        equipoId: f.equipoId,
        franja: Franja(fecha: f.fecha, slot: SlotHorario.desdeCodigo(f.slot)),
        estado: EstadoSolicitud.desdeValor(f.estado),
        creadaEn: f.creadaEn,
        actualizadaEn: f.actualizadaEn,
        version: f.version,
        estadoSync: EstadoSync.desdeValor(f.estadoSync),
        ultimoError: f.ultimoError,
        observacionEntrega: f.observacionEntrega,
        observacionDevolucion: f.observacionDevolucion,
        motivoRechazo: f.motivoRechazo,
      ),
    );
  }
}
