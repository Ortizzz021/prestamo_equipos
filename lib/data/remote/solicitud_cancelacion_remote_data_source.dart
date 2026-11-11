import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/regla_negocio_exception.dart';
import '../../domain/models/estado_solicitud.dart';
import '../../domain/models/franja.dart';
import '../../domain/models/rol.dart';
import '../../domain/models/solicitud.dart';

class SolicitudCancelacionRemoteDataSource {
  SolicitudCancelacionRemoteDataSource({
    required FirebaseFirestore firestore,
    DateTime Function()? reloj,
  }) : this._internal(firestore, reloj ?? DateTime.now);

  SolicitudCancelacionRemoteDataSource._internal(this._firestore, this._reloj);

  final FirebaseFirestore _firestore;
  final DateTime Function() _reloj;

  Future<bool> existeRemota(String solicitudId) async {
    try {
      final snapshot = await _firestore
          .collection('solicitudes')
          .doc(solicitudId)
          .get(const GetOptions(source: Source.server));
      return snapshot.exists;
    } on FirebaseException catch (error) {
      _lanzarSiSinConexion(error);
    }
  }

  Future<int> cancelar({
    required String solicitudId,
    required String solicitanteUid,
  }) async {
    try {
      final solicitudRef = _firestore
          .collection('solicitudes')
          .doc(solicitudId);
      return await _firestore.runTransaction<int>((transaction) async {
        final snapshot = await transaction.get(solicitudRef);
        final data = snapshot.data();
        if (data == null) {
          throw const ReglaNegocioException(
            'SOLICITUD_NO_ENCONTRADA',
            'La solicitud ya no existe en el servidor.',
          );
        }
        if (data['solicitanteUid'] != solicitanteUid) {
          throw const ReglaNegocioException(
            'NO_ES_DUENO',
            'Solo quien creó la solicitud puede cancelarla.',
          );
        }
        final estadoValor = data['estado'];
        if (estadoValor != EstadoSolicitud.solicitado.valor &&
            estadoValor != EstadoSolicitud.aprobado.valor) {
          final nombreEstado = estadoValor is String
              ? estadoValor
              : 'DESCONOCIDO';
          throw ReglaNegocioException(
            'ESTADO_NO_CANCELABLE',
            'No se puede cancelar: la solicitud está en estado $nombreEstado.',
          );
        }

        final solicitud = _aSolicitud(solicitudId, data);
        final cancelada = solicitud.transicionar(
          destino: EstadoSolicitud.cancelado,
          rol: Rol.solicitante,
          actorUid: solicitanteUid,
          ahora: _reloj(),
        );
        final franjaRef = estadoValor == EstadoSolicitud.aprobado.valor
            ? _firestore.collection('franjas').doc(_franjaId(data, solicitud))
            : null;
        if (franjaRef != null) await transaction.get(franjaRef);
        transaction.update(solicitudRef, {
          'estado': EstadoSolicitud.cancelado.valor,
          'canceladaEn': FieldValue.serverTimestamp(),
          'version': cancelada.version,
          'actualizadaEn': FieldValue.serverTimestamp(),
        });
        if (franjaRef != null) transaction.delete(franjaRef);
        return cancelada.version;
      });
    } on FirebaseException catch (error) {
      _lanzarSiSinConexion(error);
    }
  }

  Solicitud _aSolicitud(String id, Map<String, dynamic> data) {
    final fecha = _date(data['fecha']);
    final creadaEn = _date(data['creadaEn']);
    return Solicitud(
      id: data['id'] as String? ?? id,
      solicitanteUid: data['solicitanteUid'] as String? ?? '',
      equipoId: data['equipoId'] as String? ?? '',
      equipoNombre: data['equipoNombre'] as String?,
      franja: Franja(
        fecha: fecha,
        slot: SlotHorario.desdeCodigo(data['slot'] as String),
      ),
      estado: EstadoSolicitud.desdeValor(data['estado'] as String),
      creadaEn: creadaEn,
      actualizadaEn: _dateNullable(data['actualizadaEn']) ?? creadaEn,
      version: data['version'] is num ? (data['version'] as num).toInt() : 1,
    );
  }

  String _franjaId(Map<String, dynamic> data, Solicitud solicitud) {
    final franjaId = data['franjaId'];
    if (franjaId is String && franjaId.isNotEmpty) return franjaId;
    return solicitud.franja.idOcupacion(solicitud.equipoId);
  }

  DateTime _date(Object? value) {
    final date = _dateNullable(value);
    if (date != null) return date;
    throw const ReglaNegocioException(
      'SOLICITUD_INVALIDA',
      'La solicitud tiene una fecha inválida.',
    );
  }

  DateTime? _dateNullable(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Never _lanzarSiSinConexion(FirebaseException error) {
    if (const {
      'unavailable',
      'deadline-exceeded',
      'aborted',
      'cancelled',
      'network-request-failed',
      'unknown',
    }.contains(error.code)) {
      throw const ReglaNegocioException(
        'SIN_CONEXION',
        'Para cancelar una solicitud ya enviada necesitas conexión.',
      );
    }
    throw error;
  }
}
