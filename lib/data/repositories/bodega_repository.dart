import '../../domain/models/solicitud.dart';
import '../remote/bodega_remote_data_source.dart';

class BodegaRepository {
  const BodegaRepository({required BodegaRemoteDataSource remote})
    : this._internal(remote);

  const BodegaRepository._internal(this._remote);

  final BodegaRemoteDataSource _remote;

  Stream<List<Solicitud>> observarSolicitudesAprobadas() =>
      _remote.observarSolicitudesAprobadas();

  Stream<List<Solicitud>> observarSolicitudesEntregadas() =>
      _remote.observarSolicitudesEntregadas();

  Future<void> registrarEntrega(
    String solicitudId,
    String bodegaUid,
    String observacion,
  ) => _remote.registrarEntrega(solicitudId, bodegaUid, observacion);

  Future<void> registrarDevolucion(
    String solicitudId,
    String bodegaUid,
    String observacion,
  ) => _remote.registrarDevolucion(solicitudId, bodegaUid, observacion);
}
