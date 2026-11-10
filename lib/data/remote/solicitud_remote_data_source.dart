import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/estado_solicitud.dart';
import '../../domain/models/solicitud.dart';

sealed class ResultadoEnvio {
  const ResultadoEnvio();
}

class EnvioConfirmado extends ResultadoEnvio {
  const EnvioConfirmado(this.estadoRemoto);

  final EstadoSolicitud estadoRemoto;
}

class EnvioFalloTemporal extends ResultadoEnvio {
  const EnvioFalloTemporal(this.motivo);

  final String motivo;
}

class EnvioRechazado extends ResultadoEnvio {
  const EnvioRechazado(this.motivo);

  final String motivo;
}

abstract interface class SolicitudRemoteDataSource {
  Future<ResultadoEnvio> enviarNueva(
    Solicitud solicitud, {
    required String equipoNombre,
  });
}

class FirestoreSolicitudRemote implements SolicitudRemoteDataSource {
  FirestoreSolicitudRemote({
    required this.firestore,
    this.timeout = const Duration(seconds: 15),
  });

  final FirebaseFirestore firestore;
  final Duration timeout;

  static const String coleccion = 'solicitudes';

  static const _codigosTemporales = {
    'unavailable',
    'deadline-exceeded',
    'aborted',
    'resource-exhausted',
    'internal',
    'unknown',
    'cancelled',
  };

  @override
  Future<ResultadoEnvio> enviarNueva(
    Solicitud solicitud, {
    required String equipoNombre,
  }) async {
    final ref = firestore.collection(coleccion).doc(solicitud.id);
    try {
      return await firestore
          .runTransaction<ResultadoEnvio>((tx) async {
            final actual = await tx.get(ref);

            if (actual.exists) {
              final datos = actual.data() ?? const <String, dynamic>{};
              if (datos['solicitanteUid'] != solicitud.solicitanteUid) {
                return const EnvioRechazado(
                  'Conflicto: el identificador de la solicitud ya pertenece a otro usuario.',
                );
              }
              final estado = datos['estado'];
              return EnvioConfirmado(
                estado is String
                    ? EstadoSolicitud.desdeValor(estado)
                    : EstadoSolicitud.solicitado,
              );
            }

            if (solicitud.estado != EstadoSolicitud.solicitado) {
              return const EnvioRechazado(
                'La solicitud no existe en el servidor y no puede crearse en este estado.',
              );
            }

            tx.set(ref, aMapa(solicitud, equipoNombre: equipoNombre));
            return const EnvioConfirmado(EstadoSolicitud.solicitado);
          })
          .timeout(timeout);
    } on TimeoutException {
      return const EnvioFalloTemporal(
        'El servidor no respondió a tiempo. Se reintentará más tarde.',
      );
    } on FirebaseException catch (e) {
      return clasificarError(e.code);
    } catch (_) {
      return const EnvioFalloTemporal(
        'No fue posible sincronizar. Se reintentará más tarde.',
      );
    }
  }

  static ResultadoEnvio clasificarError(String codigo) {
    if (_codigosTemporales.contains(codigo)) {
      return const EnvioFalloTemporal(
        'Sin conexión con el servidor. Se reintentará automáticamente.',
      );
    }
    return switch (codigo) {
      'permission-denied' || 'unauthenticated' => const EnvioRechazado(
        'El servidor rechazó la solicitud por permisos. Revisa tu sesión.',
      ),
      'invalid-argument' || 'failed-precondition' => const EnvioRechazado(
        'El servidor rechazó la solicitud por datos inválidos.',
      ),
      _ => EnvioRechazado('El servidor rechazó la solicitud ($codigo).'),
    };
  }

  static Map<String, dynamic> aMapa(
    Solicitud s, {
    required String equipoNombre,
  }) => {
    'id': s.id,
    'solicitanteUid': s.solicitanteUid,
    'equipoId': s.equipoId,
    'equipoNombre': equipoNombre,
    'fecha': Timestamp.fromDate(s.franja.fecha),
    'fechaClave': s.franja.fechaClave,
    'slot': s.franja.slot.codigo,
    'franjaId': s.franja.idOcupacion(s.equipoId),
    'estado': s.estado.valor,
    'version': s.version,
    'creadaEn': Timestamp.fromDate(s.creadaEn),
    'actualizadaEn': FieldValue.serverTimestamp(),
  };
}
