import 'dart:async';

import 'package:prestamo_equipos/core/errors/api_exception.dart';
import 'package:prestamo_equipos/data/remote/equipo_api_service.dart';
import 'package:prestamo_equipos/data/repositories/equipo_repository.dart';
import 'package:prestamo_equipos/domain/models/equipo.dart';

class FakeEquipoRepository implements EquipoRepository {
  FakeEquipoRepository({List<Equipo>? equipos})
    : equipos = equipos ?? equiposDePrueba;

  List<Equipo> equipos;
  ApiException? errorSiguiente;
  Completer<void>? bloqueo;
  int llamadas = 0;

  @override
  EquipoApiService get api => throw UnimplementedError();

  @override
  Future<List<Equipo>> obtenerEquipos() async {
    llamadas++;
    if (bloqueo != null) await bloqueo!.future;
    final error = errorSiguiente;
    if (error != null) {
      errorSiguiente = null;
      throw error;
    }
    return equipos;
  }
}

const equiposDePrueba = [
  Equipo(
    id: 'eq-1',
    nombre: 'Portátil Lenovo',
    categoria: 'Portátiles',
    descripcion: 'Core i5',
    imagenUrl: '',
  ),
  Equipo(
    id: 'eq-2',
    nombre: 'Proyector Epson',
    categoria: 'Proyectores',
    descripcion: '3600 lúmenes',
    imagenUrl: '',
  ),
  Equipo(
    id: 'eq-3',
    nombre: 'iPad',
    categoria: 'Tablets',
    descripcion: '',
    imagenUrl: '',
  ),
];
