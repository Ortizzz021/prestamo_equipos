import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/logging/app_logger.dart';
import '../../core/errors/regla_negocio_exception.dart';
import '../../domain/models/estado_solicitud.dart';
import '../../domain/models/franja.dart';
import '../../domain/models/rol.dart';
import '../../domain/models/solicitud.dart';

class BodegaRemoteDataSource {
  BodegaRemoteDataSource({
    required FirebaseFirestore firestore,
    DateTime Function()? reloj,
  }) : this._internal(firestore, reloj ?? DateTime.now);

  BodegaRemoteDataSource._internal(this._firestore, this._reloj);

  final FirebaseFirestore _firestore;
  final DateTime Function() _reloj;

  Stream<List<Solicitud>> observarSolicitudesAprobadas() =>
      _observarEstado(EstadoSolicitud.aprobado);

  Stream<List<Solicitud>> observarSolicitudesEntregadas() =>
      _observarEstado(EstadoSolicitud.entregado);

  Future<void> registrarEntrega(
    String solicitudId,
    String bodegaUid,
    String observacion,
  ) async {
    await _conConexion(() async {
      final solicitudRef = _firestore
          .collection('solicitudes')
          .doc(solicitudId);
      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(solicitudRef);
        final data = snapshot.data();
        if (data == null) {
          throw const ReglaNegocioException(
            'SOLICITUD_NO_ENCONTRADA',
            'La solicitud ya no está disponible.',
          );
        }
        if (data['estado'] != EstadoSolicitud.aprobado.valor) {
          throw const ReglaNegocioException(
            'TRANSICION_INVALIDA',
            'Solo se puede registrar la entrega de una solicitud aprobada.',
          );
        }
        final actual = _aSolicitud(solicitudId, data);
        final entregada = actual.transicionar(
          destino: EstadoSolicitud.entregado,
          rol: Rol.bodega,
          actorUid: bodegaUid,
          ahora: _reloj(),
          observacion: observacion,
        );
        transaction.update(solicitudRef, {
          'estado': EstadoSolicitud.entregado.valor,
          'observacionEntrega': entregada.observacionEntrega,
          'entregadoPor': bodegaUid,
          'entregadoEn': FieldValue.serverTimestamp(),
          'version': entregada.version,
          'actualizadaEn': FieldValue.serverTimestamp(),
        });
      });
    });
  }

  Future<void> registrarDevolucion(
    String solicitudId,
    String bodegaUid,
    String observacion,
  ) async {
    await _conConexion(() async {
      final solicitudRef = _firestore
          .collection('solicitudes')
          .doc(solicitudId);
      await _firestore.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(solicitudRef);
        final data = snapshot.data();
        if (data == null) {
          throw const ReglaNegocioException(
            'SOLICITUD_NO_ENCONTRADA',
            'La solicitud ya no está disponible.',
          );
        }
        if (data['estado'] != EstadoSolicitud.entregado.valor) {
          throw const ReglaNegocioException(
            'TRANSICION_INVALIDA',
            'Solo se puede registrar la devolución de un equipo entregado.',
          );
        }
        final actual = _aSolicitud(solicitudId, data);
        final devuelta = actual.transicionar(
          destino: EstadoSolicitud.devuelto,
          rol: Rol.bodega,
          actorUid: bodegaUid,
          ahora: _reloj(),
          observacion: observacion,
        );
        final franjaId = _franjaId(data, actual);
        if (franjaId != actual.franja.idOcupacion(actual.equipoId)) {
          throw const ReglaNegocioException(
            'SOLICITUD_INVALIDA',
            'La franja no coincide con el equipo y el horario de la solicitud.',
          );
        }
        final franjaRef = _firestore.collection('franjas').doc(franjaId);
        await transaction.get(franjaRef);
        transaction.update(solicitudRef, {
          'estado': EstadoSolicitud.devuelto.valor,
          'observacionDevolucion': devuelta.observacionDevolucion,
          'devueltoPor': bodegaUid,
          'devueltoEn': FieldValue.serverTimestamp(),
          'version': devuelta.version,
          'actualizadaEn': FieldValue.serverTimestamp(),
        });
        transaction.delete(franjaRef);
      });
    });
  }

  Stream<List<Solicitud>> _observarEstado(EstadoSolicitud estado) => _firestore
      .collection('solicitudes')
      .where('estado', isEqualTo: estado.valor)
      .orderBy('creadaEn')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => _aSolicitud(doc.id, doc.data()))
            .toList(),
      );

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
      observacionEntrega: data['observacionEntrega'] as String?,
      observacionDevolucion: data['observacionDevolucion'] as String?,
    );
  }

  String _franjaId(Map<String, dynamic> data, Solicitud solicitud) {
    final id = data['franjaId'];
    if (id is String && id.isNotEmpty) return id;
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

  Future<T> _conConexion<T>(Future<T> Function() operacion) async {
    try {
      return await operacion();
    } on FirebaseException catch (error, stack) {
      if (const {
        'unavailable',
        'deadline-exceeded',
        'aborted',
        'cancelled',
        'network-request-failed',
        'unknown',
      }.contains(error.code)) {
        AppLogger.network(error, stack);
        throw const ReglaNegocioException(
          'SIN_CONEXION',
          'Sin conexión. Conéctate a internet e inténtalo de nuevo.',
        );
      }
      AppLogger.unexpected(error, stack);
      rethrow;
    } on ReglaNegocioException catch (error) {
      AppLogger.business(error);
      rethrow;
    } catch (error, stack) {
      AppLogger.unexpected(error, stack);
      rethrow;
    }
  }
}
