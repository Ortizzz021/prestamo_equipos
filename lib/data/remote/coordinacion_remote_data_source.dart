import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/logging/app_logger.dart';
import '../../core/errors/regla_negocio_exception.dart';
import '../../domain/models/estado_solicitud.dart';
import '../../domain/models/franja.dart';
import '../../domain/models/rol.dart';
import '../../domain/models/solicitud.dart';

class CoordinacionRemoteDataSource {
  CoordinacionRemoteDataSource({
    required FirebaseFirestore firestore,
    DateTime Function()? reloj,
  }) : this._internal(firestore, reloj ?? DateTime.now);

  CoordinacionRemoteDataSource._internal(this._firestore, this._reloj);

  final FirebaseFirestore _firestore;
  final DateTime Function() _reloj;

  Stream<List<Solicitud>> observarSolicitudesPendientes() => _firestore
      .collection('solicitudes')
      .where('estado', isEqualTo: EstadoSolicitud.solicitado.valor)
      .orderBy('creadaEn')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((documento) => _aSolicitud(documento.id, documento.data()))
            .toList(),
      );

  Future<void> aprobar(String solicitudId, String coordinadorUid) async {
    await _conConexion(() async {
      final solicitudRef = _firestore
          .collection('solicitudes')
          .doc(solicitudId);
      await _firestore.runTransaction<void>((transaction) async {
        final solicitudSnapshot = await transaction.get(solicitudRef);
        final data = solicitudSnapshot.data();
        if (data == null) {
          throw const ReglaNegocioException(
            'SOLICITUD_NO_ENCONTRADA',
            'La solicitud ya no está disponible.',
          );
        }
        if (data['estado'] != EstadoSolicitud.solicitado.valor) {
          throw const ReglaNegocioException(
            'ESTADO_CAMBIO',
            'La solicitud ya fue atendida por otra persona.',
          );
        }
        if (data['solicitanteUid'] == coordinadorUid) {
          throw const ReglaNegocioException(
            'AUTOAPROBACION',
            'No puedes aprobar tu propia solicitud.',
          );
        }

        final equipoId = data['equipoId'];
        final franjaId = data['franjaId'];
        final fechaClave = data['fechaClave'];
        final slot = data['slot'];
        if (equipoId is! String ||
            franjaId is! String ||
            fechaClave is! String ||
            slot is! String) {
          throw const ReglaNegocioException(
            'SOLICITUD_INVALIDA',
            'La solicitud no contiene una franja válida.',
          );
        }
        final solicitud = _aSolicitud(solicitudId, data);
        if (franjaId != solicitud.franja.idOcupacion(equipoId)) {
          throw const ReglaNegocioException(
            'SOLICITUD_INVALIDA',
            'La franja de la solicitud no coincide con su equipo y horario.',
          );
        }

        final estadoEquipoRef = _firestore
            .collection('equipos_estado')
            .doc(equipoId);
        final franjaRef = _firestore.collection('franjas').doc(franjaId);
        final estadoEquipoSnapshot = await transaction.get(estadoEquipoRef);
        final franjaSnapshot = await transaction.get(franjaRef);

        if (estadoEquipoSnapshot.data()?['bloqueado'] == true) {
          throw const ReglaNegocioException(
            'EQUIPO_BLOQUEADO',
            'El equipo está bloqueado y no se puede aprobar esta solicitud.',
          );
        }
        if (franjaSnapshot.exists) {
          throw const ReglaNegocioException(
            'FRANJA_OCUPADA',
            'Esta franja ya fue ocupada por otra solicitud.',
          );
        }

        final aprobada = solicitud.transicionar(
          destino: EstadoSolicitud.aprobado,
          rol: Rol.coordinador,
          actorUid: coordinadorUid,
          ahora: _reloj(),
        );
        transaction.set(franjaRef, {
          'equipoId': equipoId,
          'fechaClave': fechaClave,
          'slot': slot,
          'solicitudId': solicitudId,
          'ocupadaEn': FieldValue.serverTimestamp(),
        });
        transaction.update(solicitudRef, {
          'estado': EstadoSolicitud.aprobado.valor,
          'aprobadoPor': coordinadorUid,
          'aprobadoEn': FieldValue.serverTimestamp(),
          'version': aprobada.version,
          'actualizadaEn': FieldValue.serverTimestamp(),
        });
      });
    });
  }

  Future<void> rechazar(
    String solicitudId,
    String coordinadorUid,
    String motivo,
  ) async {
    final motivoLimpio = motivo.trim();
    if (motivoLimpio.isEmpty) {
      throw const ReglaNegocioException(
        'MOTIVO_REQUERIDO',
        'Escribe el motivo del rechazo.',
      );
    }
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
        if (data['estado'] != EstadoSolicitud.solicitado.valor) {
          throw const ReglaNegocioException(
            'ESTADO_CAMBIO',
            'Solo se pueden rechazar solicitudes pendientes.',
          );
        }
        final rechazada = _aSolicitud(solicitudId, data).transicionar(
          destino: EstadoSolicitud.rechazado,
          rol: Rol.coordinador,
          actorUid: coordinadorUid,
          ahora: _reloj(),
          observacion: motivoLimpio,
        );
        transaction.update(solicitudRef, {
          'estado': EstadoSolicitud.rechazado.valor,
          'rechazadoPor': coordinadorUid,
          'rechazadoEn': FieldValue.serverTimestamp(),
          'motivoRechazo': motivoLimpio,
          'version': rechazada.version,
          'actualizadaEn': FieldValue.serverTimestamp(),
        });
      });
    });
  }

  Future<void> bloquear({
    required String equipoId,
    required String motivo,
    required String coordinadorUid,
  }) async {
    final motivoLimpio = motivo.trim();
    if (motivoLimpio.isEmpty) {
      throw const ReglaNegocioException(
        'MOTIVO_REQUERIDO',
        'Escribe el motivo del bloqueo.',
      );
    }
    await _guardarBloqueo(
      equipoId: equipoId,
      bloqueado: true,
      motivo: motivoLimpio,
      coordinadorUid: coordinadorUid,
    );
  }

  Future<void> desbloquear({
    required String equipoId,
    required String coordinadorUid,
  }) => _guardarBloqueo(
    equipoId: equipoId,
    bloqueado: false,
    coordinadorUid: coordinadorUid,
  );

  Future<void> _guardarBloqueo({
    required String equipoId,
    required bool bloqueado,
    required String coordinadorUid,
    String? motivo,
  }) async {
    await _conConexion(() async {
      final equipoRef = _firestore.collection('equipos_estado').doc(equipoId);
      await _firestore.runTransaction<void>((transaction) async {
        await transaction.get(equipoRef);
        transaction.set(equipoRef, {
          'bloqueado': bloqueado,
          'actualizadoPor': coordinadorUid,
          'actualizadoEn': FieldValue.serverTimestamp(),
          if (bloqueado) 'motivo': motivo,
          if (!bloqueado) 'motivo': FieldValue.delete(),
        }, SetOptions(merge: true));
      });
    });
  }

  Future<T> _conConexion<T>(Future<T> Function() operacion) async {
    try {
      return await operacion();
    } on FirebaseException catch (error, stack) {
      if (_esErrorDeRed(error.code)) {
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

  Solicitud _aSolicitud(String id, Map<String, dynamic> data) {
    final fecha = _date(data['fecha']);
    final creadaEn = _date(data['creadaEn']);
    final franja = Franja(
      fecha: fecha,
      slot: SlotHorario.desdeCodigo(data['slot'] as String),
    );
    return Solicitud(
      id: data['id'] as String? ?? id,
      solicitanteUid: data['solicitanteUid'] as String? ?? '',
      equipoId: data['equipoId'] as String? ?? '',
      equipoNombre: data['equipoNombre'] as String?,
      franja: franja,
      estado: EstadoSolicitud.desdeValor(data['estado'] as String),
      creadaEn: creadaEn,
      actualizadaEn: _dateNullable(data['actualizadaEn']) ?? creadaEn,
      version: data['version'] is num ? (data['version'] as num).toInt() : 1,
      motivoRechazo: data['motivoRechazo'] as String?,
    );
  }

  DateTime _date(Object? value) {
    final parsed = _dateNullable(value);
    if (parsed != null) return parsed;
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

  static bool _esErrorDeRed(String codigo) => const {
    'unavailable',
    'deadline-exceeded',
    'aborted',
    'cancelled',
    'network-request-failed',
    'unknown',
  }.contains(codigo);
}
