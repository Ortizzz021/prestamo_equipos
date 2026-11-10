import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/regla_negocio_exception.dart';
import '../../core/utils/fechas.dart';
import '../../data/repositories/disponibilidad_repository.dart';
import '../../data/repositories/solicitud_repository.dart';
import '../../data/sync/sync_service.dart';
import '../../domain/models/equipo.dart';
import '../../domain/models/franja.dart';
import '../auth/auth_controller.dart';

class SolicitarPrestamoScreen extends StatefulWidget {
  const SolicitarPrestamoScreen({
    super.key,
    required this.equipo,
    this.reloj = DateTime.now,
  });

  final Equipo equipo;
  final DateTime Function() reloj;

  static Route<bool> ruta(Equipo equipo) => MaterialPageRoute<bool>(
    builder: (_) => SolicitarPrestamoScreen(equipo: equipo),
  );

  static const int diasDisponibles = 14;

  @override
  State<SolicitarPrestamoScreen> createState() =>
      _SolicitarPrestamoScreenState();
}

class _SolicitarPrestamoScreenState extends State<SolicitarPrestamoScreen> {
  late final List<DateTime> _dias;
  late DateTime _diaSeleccionado;
  Franja? _franja;
  bool _guardando = false;
  String? _error;
  DisponibilidadRepository? _disponibilidad;
  Set<SlotHorario> _slotsOcupados = {};
  bool _cargandoOcupacion = false;
  bool _falloVerificacion = false;
  int _consultaOcupacion = 0;
  bool _dependenciasLeidas = false;

  @override
  void initState() {
    super.initState();
    final ahora = widget.reloj();
    _dias = Fechas.proximosDias(
      ahora,
      SolicitarPrestamoScreen.diasDisponibles,
    ).where((d) => Franja.disponiblesDelDia(d, ahora).isNotEmpty).toList();
    _diaSeleccionado = _dias.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dependenciasLeidas) return;
    _dependenciasLeidas = true;
    _disponibilidad = Provider.of<DisponibilidadRepository?>(
      context,
      listen: false,
    );
    _consultarOcupacion(_diaSeleccionado);
  }

  List<Franja> get _franjasDelDia =>
      Franja.disponiblesDelDia(_diaSeleccionado, widget.reloj());

  void _seleccionarDia(DateTime dia) {
    setState(() {
      _diaSeleccionado = dia;
      _franja = null;
      _error = null;
    });
    _consultarOcupacion(dia);
  }

  Future<void> _consultarOcupacion(DateTime dia) async {
    final disponibilidad = _disponibilidad;
    if (disponibilidad == null) return;
    final consulta = ++_consultaOcupacion;
    setState(() {
      _cargandoOcupacion = true;
      _falloVerificacion = false;
      _slotsOcupados = {};
      _franja = null;
    });
    try {
      final ocupados = await disponibilidad.slotsOcupados(widget.equipo.id, dia);
      if (!mounted || consulta != _consultaOcupacion) return;
      setState(() => _slotsOcupados = ocupados);
    } catch (_) {
      if (!mounted || consulta != _consultaOcupacion) return;
      setState(() {
        _falloVerificacion = true;
        _slotsOcupados = {};
      });
    } finally {
      if (mounted && consulta == _consultaOcupacion) {
        setState(() => _cargandoOcupacion = false);
      }
    }
  }

  Future<void> _guardar() async {
    final franja = _franja;
    final uid = context.read<AuthController>().perfil?.uid;
    if (_guardando || franja == null) return;
    if (uid == null) {
      setState(() => _error = 'Tu sesión expiró. Vuelve a iniciar sesión.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    final sync = context.read<SyncService>();
    try {
      await context.read<SolicitudRepository>().crearSolicitud(
        ownerUid: uid,
        equipo: widget.equipo,
        franja: franja,
      );
      unawaited(sync.sincronizar(uid).then((_) {}, onError: (Object _) {}));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud guardada. Queda pendiente de sincronizar.'),
        ),
      );
      Navigator.of(context).pop(true);
    } on ReglaNegocioException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.mensaje);
    } catch (_) {
      if (!mounted) return;
      setState(
        () =>
            _error = 'No fue posible guardar la solicitud. Inténtalo de nuevo.',
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final franjas = _franjasDelDia;

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar préstamo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.equipo.nombre, style: textos.titleLarge),
          Text(widget.equipo.categoria, style: textos.bodySmall),
          const SizedBox(height: 24),
          Text('1. Elige el día', style: textos.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _dias.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _ChipDia(
                dia: _dias[i],
                seleccionado: _dias[i] == _diaSeleccionado,
                onTap: _guardando ? null : () => _seleccionarDia(_dias[i]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('2. Elige la franja', style: textos.titleMedium),
          const SizedBox(height: 8),
          if (_falloVerificacion)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'No se pudo verificar la ocupación; el coordinador la confirmará',
                key: Key('franjas_sin_verificar'),
              ),
            ),
          if (_cargandoOcupacion)
            const LinearProgressIndicator(key: Key('franjas_cargando')),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in franjas)
                ChoiceChip(
                  key: Key('franja_${f.slot.codigo}'),
                  avatar: _slotsOcupados.contains(f.slot)
                      ? const Icon(Icons.event_busy, size: 18)
                      : null,
                  label: Text(
                    _slotsOcupados.contains(f.slot)
                        ? '${f.slot.etiqueta} · Ocupada'
                        : f.slot.etiqueta,
                  ),
                  selected: !_slotsOcupados.contains(f.slot) && _franja == f,
                  onSelected: _guardando ||
                          _cargandoOcupacion ||
                          _slotsOcupados.contains(f.slot)
                      ? null
                      : (_) => setState(() {
                          _franja = f;
                          _error = null;
                        }),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (_franja != null)
            Text(
              'Préstamo para el ${Fechas.completa(_franja!.fecha)}, '
              'de ${_franja!.slot.etiqueta}.',
              style: textos.bodyMedium,
            ),
          const SizedBox(height: 8),
          Text(
            'La solicitud se guarda en el dispositivo y queda en estado '
            'Solicitado. El coordinador decide si se aprueba.',
            style: textos.bodySmall,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton(
              key: const Key('solicitar_guardar'),
              onPressed: _franja == null || _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text('Enviar solicitud'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipDia extends StatelessWidget {
  const _ChipDia({
    required this.dia,
    required this.seleccionado,
    required this.onTap,
  });

  final DateTime dia;
  final bool seleccionado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final fondo = seleccionado
        ? colores.primary
        : colores.surfaceContainerHighest;
    final texto = seleccionado ? colores.onPrimary : colores.onSurface;

    return Material(
      color: fondo,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Fechas.diaCorto(dia),
                style: TextStyle(color: texto, fontSize: 12),
              ),
              Text(
                '${dia.day}',
                style: TextStyle(
                  color: texto,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Fechas.mesCorto(dia),
                style: TextStyle(color: texto, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
