import 'package:flutter/foundation.dart';

import '../../core/errors/api_exception.dart';
import '../../core/preferences/preferencias_service.dart';
import '../../data/repositories/equipo_repository.dart';
import '../../domain/models/equipo.dart';

enum EstadoCatalogo { cargando, datos, vacio, error }

class CatalogoController extends ChangeNotifier {
  CatalogoController({
    required this.repository,
    required this.preferencias,
  });

  final EquipoRepository repository;
  final PreferenciasService preferencias;

  EstadoCatalogo _estado = EstadoCatalogo.cargando;
  List<Equipo> _equipos = const [];
  String? _categoria;
  String? _mensajeError;
  bool _puedeReintentar = true;
  bool _cargando = false;
  bool _disposed = false;

  EstadoCatalogo get estado => _estado;
  String? get categoriaSeleccionada => _categoria;
  String? get mensajeError => _mensajeError;
  bool get puedeReintentar => _puedeReintentar;
  bool get hayDatos => _equipos.isNotEmpty;

  List<String> get categorias {
    final unicas = {for (final e in _equipos) e.categoria}.toList()..sort();
    return unicas;
  }

  List<Equipo> get equiposFiltrados => _categoria == null
      ? _equipos
      : _equipos.where((e) => e.categoria == _categoria).toList();

  Future<void> cargar() async {
    if (_cargando || _disposed) return;
    _cargando = true;
    if (_equipos.isEmpty) {
      _estado = EstadoCatalogo.cargando;
      _notificar();
    }

    final categoriaGuardada = await preferencias.categoriaCatalogo();

    try {
      final equipos = await repository.obtenerEquipos();
      if (_disposed) return;
      _equipos = equipos;
      _mensajeError = null;
      _categoria = equipos.any((e) => e.categoria == categoriaGuardada)
          ? categoriaGuardada
          : null;
      _estado = equipos.isEmpty ? EstadoCatalogo.vacio : EstadoCatalogo.datos;
    } on ApiException catch (error) {
      if (_disposed) return;
      _mensajeError = error.mensaje;
      _puedeReintentar = error.esReintentable;
      _estado = _equipos.isEmpty ? EstadoCatalogo.error : EstadoCatalogo.datos;
    } finally {
      _cargando = false;
      _notificar();
    }
  }

  Future<void> reintentar() {
    _puedeReintentar = true;
    return cargar();
  }

  Future<void> seleccionarCategoria(String? categoria) async {
    if (categoria == _categoria) return;
    _categoria = categoria;
    _notificar();
    await preferencias.guardarCategoriaCatalogo(categoria);
  }

  void descartarError() {
    if (_mensajeError == null) return;
    _mensajeError = null;
    _notificar();
  }

  void _notificar() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
