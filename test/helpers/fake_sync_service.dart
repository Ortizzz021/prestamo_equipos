import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:prestamo_equipos/data/remote/solicitud_remote_data_source.dart';
import 'package:prestamo_equipos/data/repositories/solicitud_repository.dart';
import 'package:prestamo_equipos/data/sync/sync_service.dart';

class FakeSyncService implements SyncService {
  final List<String> sincronizaciones = [];
  ResumenSync resumen = const ResumenSync();

  @override
  SolicitudRepository get repository => throw UnimplementedError();

  @override
  SolicitudRemoteDataSource get remote => throw UnimplementedError();

  @override
  Stream<List<ConnectivityResult>>? get cambiosConectividad => null;

  @override
  Stream<void> get conexionRecuperada => const Stream.empty();

  @override
  Future<ResumenSync> sincronizar(String ownerUid) async {
    sincronizaciones.add(ownerUid);
    return resumen;
  }
}
