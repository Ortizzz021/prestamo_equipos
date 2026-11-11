import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:prestamo_equipos/data/remote/solicitud_remote_data_source.dart';
import 'package:prestamo_equipos/data/remote/solicitud_seguimiento_remote_data_source.dart';
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
  SolicitudSeguimientoRemoteDataSource? get seguimiento => null;

  @override
  String? Function()? get uidActual => null;

  @override
  Stream<void> get conexionRecuperada => const Stream.empty();

  final List<String> escuchas = [];

  @override
  StreamSubscription<void> escucharCambiosRemotos(String ownerUid) {
    escuchas.add(ownerUid);
    return const Stream<void>.empty().listen(null);
  }

  @override
  Future<T> ejecutarExclusivo<T>(
    String solicitudId,
    Future<T> Function() operacion,
  ) => operacion();

  @override
  Future<ResumenSync> sincronizar(String ownerUid) async {
    sincronizaciones.add(ownerUid);
    return resumen;
  }
}
