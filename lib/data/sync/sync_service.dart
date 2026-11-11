import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../remote/solicitud_remote_data_source.dart';
import '../remote/solicitud_seguimiento_remote_data_source.dart';
import '../repositories/solicitud_repository.dart';

class ResumenSync {
  const ResumenSync({
    this.enviadas = 0,
    this.pendientes = 0,
    this.rechazadas = 0,
  });

  final int enviadas;
  final int pendientes;
  final int rechazadas;

  bool get sinCambios => enviadas == 0 && pendientes == 0 && rechazadas == 0;

  String get descripcion {
    if (sinCambios) return 'No hay solicitudes pendientes de sincronizar.';
    final partes = <String>[
      if (enviadas > 0) '$enviadas sincronizada${enviadas == 1 ? '' : 's'}',
      if (pendientes > 0)
        '$pendientes sigue${pendientes == 1 ? '' : 'n'} pendiente${pendientes == 1 ? '' : 's'}',
      if (rechazadas > 0)
        '$rechazadas rechazada${rechazadas == 1 ? '' : 's'} por el servidor',
    ];
    return '${partes.join(', ')}.';
  }
}

class SyncService {
  SyncService({
    required this.repository,
    required this.remote,
    this.cambiosConectividad,
    this.seguimiento,
    this.uidActual,
  });

  final SolicitudRepository repository;
  final SolicitudRemoteDataSource remote;
  final Stream<List<ConnectivityResult>>? cambiosConectividad;
  final SolicitudSeguimientoRemoteDataSource? seguimiento;
  final String? Function()? uidActual;

  final Map<String, Future<ResumenSync>> _enCurso = {};
  final Map<String, Future<void>> _bloqueosPorSolicitud = {};

  Future<T> ejecutarExclusivo<T>(
    String solicitudId,
    Future<T> Function() operacion,
  ) async {
    final anterior = _bloqueosPorSolicitud[solicitudId] ?? Future<void>.value();
    final liberado = Completer<void>();
    _bloqueosPorSolicitud[solicitudId] = liberado.future;
    await anterior;
    try {
      return await operacion();
    } finally {
      liberado.complete();
      if (identical(_bloqueosPorSolicitud[solicitudId], liberado.future)) {
        _bloqueosPorSolicitud.remove(solicitudId);
      }
    }
  }

  Stream<void> get conexionRecuperada {
    final cambios = cambiosConectividad ?? Connectivity().onConnectivityChanged;
    return cambios
        .map((r) => r.any((c) => c != ConnectivityResult.none))
        .distinct()
        .where((conectado) => conectado);
  }

  bool _sesionVigente(String ownerUid) {
    final actual = uidActual?.call();
    return actual == null || actual == ownerUid;
  }

  StreamSubscription<void> escucharCambiosRemotos(String ownerUid) {
    final fuente = seguimiento;
    if (fuente == null) return const Stream<void>.empty().listen(null);
    return fuente
        .observarDelSolicitante(ownerUid)
        .asyncMap((remotas) => _aplicarRemotas(ownerUid, remotas))
        .listen(null, onError: (Object _) {});
  }

  Future<int> _aplicarRemotas(
    String ownerUid,
    List<SolicitudRemota> remotas,
  ) async {
    var aplicadas = 0;
    for (final remota in remotas) {
      if (!_sesionVigente(ownerUid)) break;
      final cambio = await ejecutarExclusivo(
        remota.id,
        () => repository.aplicarRemota(ownerUid: ownerUid, remota: remota),
      );
      if (cambio) aplicadas++;
    }
    return aplicadas;
  }

  Future<ResumenSync> sincronizar(String ownerUid) {
    return _enCurso[ownerUid] ??= _sincronizar(ownerUid).whenComplete(() {
      _enCurso.remove(ownerUid);
    });
  }

  Future<ResumenSync> _sincronizar(String ownerUid) async {
    final pendientes = await repository.pendientesDeEnvio(ownerUid);
    var enviadas = 0;
    var siguenPendientes = 0;
    var rechazadas = 0;

    for (final item in pendientes) {
      final solicitud = item.solicitud;
      if (solicitud.solicitanteUid != ownerUid) continue;
      if (!_sesionVigente(ownerUid)) break;

      await ejecutarExclusivo(solicitud.id, () async {
        if (!await repository.siguePendienteDeEnvio(
          solicitud.id,
          solicitud.version,
        )) {
          return;
        }
        final resultado = await remote.enviarNueva(
          solicitud,
          equipoNombre: item.equipoNombre,
        );

        switch (resultado) {
          case EnvioConfirmado(:final estadoRemoto):
            final confirmada = await repository.confirmarEnvio(
              id: solicitud.id,
              versionEnviada: solicitud.version,
              estadoRemoto: estadoRemoto,
            );
            if (confirmada) {
              enviadas++;
            } else {
              siguenPendientes++;
            }
          case EnvioFalloTemporal(:final motivo):
            await repository.registrarFalloTemporal(
              id: solicitud.id,
              versionEnviada: solicitud.version,
              motivo: motivo,
            );
            siguenPendientes++;
          case EnvioRechazado(:final motivo):
            await repository.registrarRechazo(
              id: solicitud.id,
              versionEnviada: solicitud.version,
              motivo: motivo,
            );
            rechazadas++;
        }
      });
    }

    return ResumenSync(
      enviadas: enviadas,
      pendientes: siguenPendientes,
      rechazadas: rechazadas,
    );
  }
}
