import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/estado_solicitud.dart';
import '../../domain/models/franja.dart';

class SolicitudRemota {
  const SolicitudRemota({
    required this.id,
    required this.solicitanteUid,
    required this.equipoId,
    required this.equipoNombre,
    required this.fecha,
    required this.slot,
    required this.estado,
    required this.version,
    required this.creadaEn,
    required this.actualizadaEn,
    this.observacionEntrega,
    this.observacionDevolucion,
    this.motivoRechazo,
  });

  final String id;
  final String solicitanteUid;
  final String equipoId;
  final String equipoNombre;
  final DateTime fecha;
  final SlotHorario slot;
  final EstadoSolicitud estado;
  final int version;
  final DateTime creadaEn;
  final DateTime actualizadaEn;
  final String? observacionEntrega;
  final String? observacionDevolucion;
  final String? motivoRechazo;

  static SolicitudRemota? desdeFirestore(String id, Map<String, dynamic> data) {
    try {
      final fecha = _fecha(data['fecha']);
      final creadaEn = _fecha(data['creadaEn']) ?? fecha;
      final solicitante = data['solicitanteUid'];
      final equipoId = data['equipoId'];
      final slot = data['slot'];
      final estado = data['estado'];
      if (fecha == null ||
          creadaEn == null ||
          solicitante is! String ||
          equipoId is! String ||
          slot is! String ||
          estado is! String) {
        return null;
      }
      final version = data['version'];
      return SolicitudRemota(
        id: id,
        solicitanteUid: solicitante,
        equipoId: equipoId,
        equipoNombre: data['equipoNombre'] is String
            ? data['equipoNombre'] as String
            : equipoId,
        fecha: DateTime(fecha.year, fecha.month, fecha.day),
        slot: SlotHorario.desdeCodigo(slot),
        estado: EstadoSolicitud.desdeValor(estado),
        version: version is num ? version.toInt() : 1,
        creadaEn: creadaEn,
        actualizadaEn: _fecha(data['actualizadaEn']) ?? creadaEn,
        observacionEntrega: _texto(data['observacionEntrega']),
        observacionDevolucion: _texto(data['observacionDevolucion']),
        motivoRechazo: _texto(data['motivoRechazo']),
      );
    } on ArgumentError {
      return null;
    }
  }

  static DateTime? _fecha(Object? valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    return null;
  }

  static String? _texto(Object? valor) =>
      valor is String && valor.trim().isNotEmpty ? valor : null;
}

abstract interface class SolicitudSeguimientoRemoteDataSource {
  Stream<List<SolicitudRemota>> observarDelSolicitante(String solicitanteUid);
}

class FirestoreSolicitudSeguimiento
    implements SolicitudSeguimientoRemoteDataSource {
  FirestoreSolicitudSeguimiento({required this.firestore});

  final FirebaseFirestore firestore;

  @override
  Stream<List<SolicitudRemota>> observarDelSolicitante(String solicitanteUid) {
    return firestore
        .collection('solicitudes')
        .where('solicitanteUid', isEqualTo: solicitanteUid)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              ?SolicitudRemota.desdeFirestore(doc.id, doc.data()),
          ],
        );
  }
}
