import '../../domain/models/estado_equipo.dart';
import '../../domain/models/franja.dart';
import '../remote/disponibilidad_remote_data_source.dart';

class DisponibilidadRepository {
  const DisponibilidadRepository({required DisponibilidadRemoteDataSource remote})
    : this._internal(remote);

  const DisponibilidadRepository._internal(this._remote);

  final DisponibilidadRemoteDataSource _remote;

  Stream<EstadoEquipo> observarEstadoEquipo(String equipoId) =>
      _remote.observarEstadoEquipo(equipoId);

  Future<Set<SlotHorario>> slotsOcupados(String equipoId, DateTime dia) =>
      _remote.slotsOcupados(equipoId, dia);
}
