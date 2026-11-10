import '../../domain/models/solicitud.dart';
import '../remote/coordinacion_remote_data_source.dart';

class CoordinacionRepository {
  const CoordinacionRepository({required CoordinacionRemoteDataSource remote})
    : this._internal(remote);

  const CoordinacionRepository._internal(this._remote);

  final CoordinacionRemoteDataSource _remote;

  Stream<List<Solicitud>> observarSolicitudesPendientes() =>
      _remote.observarSolicitudesPendientes();

  Future<void> aprobar(String solicitudId, String coordinadorUid) =>
      _remote.aprobar(solicitudId, coordinadorUid);

  Future<void> rechazar(
    String solicitudId,
    String coordinadorUid,
    String motivo,
  ) => _remote.rechazar(solicitudId, coordinadorUid, motivo);

  Future<void> bloquear({
    required String equipoId,
    required String motivo,
    required String coordinadorUid,
  }) => _remote.bloquear(
    equipoId: equipoId,
    motivo: motivo,
    coordinadorUid: coordinadorUid,
  );

  Future<void> desbloquear({
    required String equipoId,
    required String coordinadorUid,
  }) => _remote.desbloquear(
    equipoId: equipoId,
    coordinadorUid: coordinadorUid,
  );
}
