import '../../core/errors/api_exception.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/models/equipo.dart';
import '../remote/equipo_api_service.dart';

class EquipoRepository {
  EquipoRepository({required this.api});

  final EquipoApiService api;
  Future<List<Equipo>>? _consultaEnCurso;

  Future<List<Equipo>> obtenerEquipos() {
    return _consultaEnCurso ??= _consultar().whenComplete(() {
      _consultaEnCurso = null;
    });
  }

  Future<List<Equipo>> _consultar() async {
    try {
      final dtos = await api.obtenerEquipos();
      final equipos = dtos.map((dto) => dto.toDomain()).toList()
        ..sort(
          (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
        );
      return List.unmodifiable(equipos);
    } on ApiException {
      rethrow;
    } catch (error, stack) {
      AppLogger.unexpected(error, stack);
      throw ErrorInesperadoApiException(error);
    }
  }
}
