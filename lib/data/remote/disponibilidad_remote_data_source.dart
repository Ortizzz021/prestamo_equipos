import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/estado_equipo.dart';
import '../../domain/models/franja.dart';

class DisponibilidadRemoteDataSource {
  DisponibilidadRemoteDataSource({required FirebaseFirestore firestore})
    : this._internal(firestore);

  DisponibilidadRemoteDataSource._internal(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<EstadoEquipo> observarEstadoEquipo(String equipoId) async* {
    try {
      await for (final snapshot in _firestore
          .collection('equipos_estado')
          .doc(equipoId)
          .snapshots()) {
        final data = snapshot.data();
        if (data == null) {
          yield const EstadoEquipo();
        } else {
          yield EstadoEquipo(
            bloqueado: data['bloqueado'] == true,
            motivo: data['motivo'] is String ? data['motivo'] as String : null,
          );
        }
      }
    } on FirebaseException catch (error) {
      if (_esErrorDeRed(error.code)) {
        yield const EstadoEquipo.noVerificado();
        return;
      }
      rethrow;
    }
  }

  Future<Set<SlotHorario>> slotsOcupados(String equipoId, DateTime dia) async {
    try {
      final documentos = await Future.wait([
        for (final slot in SlotHorario.values)
          _firestore
              .collection('franjas')
              .doc(Franja(fecha: dia, slot: slot).idOcupacion(equipoId))
              .get(),
      ]);
      return {
        for (var i = 0; i < documentos.length; i++)
          if (documentos[i].exists) SlotHorario.values[i],
      };
    } on FirebaseException catch (error) {
      if (_esErrorDeRed(error.code)) {
        throw DisponibilidadSinConexion(error.code);
      }
      rethrow;
    }
  }

  static bool _esErrorDeRed(String codigo) => const {
    'unavailable',
    'deadline-exceeded',
    'cancelled',
    'network-request-failed',
    'unknown',
  }.contains(codigo);

}

class DisponibilidadSinConexion implements Exception {
  const DisponibilidadSinConexion(this.codigo);

  final String codigo;
}
