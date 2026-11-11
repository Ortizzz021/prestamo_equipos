import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../data/sync/sync_service.dart';

class SincronizadorAutomatico extends StatefulWidget {
  const SincronizadorAutomatico({
    super.key,
    required this.ownerUid,
    required this.child,
  });

  final String ownerUid;
  final Widget child;

  @override
  State<SincronizadorAutomatico> createState() =>
      _SincronizadorAutomaticoState();
}

class _SincronizadorAutomaticoState extends State<SincronizadorAutomatico>
    with WidgetsBindingObserver {
  late final SyncService _sync;
  StreamSubscription<void>? _conexion;
  StreamSubscription<void>? _remotos;

  @override
  void initState() {
    super.initState();
    _sync = context.read<SyncService>();
    WidgetsBinding.instance.addObserver(this);
    _conexion = _sync.conexionRecuperada.listen(
      (_) => _sincronizar(),
      onError: (Object _) {},
    );
    _remotos = _sync.escucharCambiosRemotos(widget.ownerUid);
    _sincronizar();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sincronizar();
  }

  void _sincronizar() {
    unawaited(
      _sync.sincronizar(widget.ownerUid).then((_) {}, onError: (Object _) {}),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _conexion?.cancel();
    _remotos?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
