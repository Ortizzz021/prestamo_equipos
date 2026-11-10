import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:prestamo_equipos/core/errors/api_exception.dart';
import 'package:prestamo_equipos/core/preferences/preferencias_service.dart';
import 'package:prestamo_equipos/data/remote/dto/equipo_dto.dart';
import 'package:prestamo_equipos/data/remote/equipo_api_service.dart';
import 'package:prestamo_equipos/data/repositories/equipo_repository.dart';
import 'package:prestamo_equipos/features/catalogo/catalogo_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_equipo_repository.dart';

class _ApiContadora implements EquipoApiService {
  int llamadas = 0;
  final bloqueo = Completer<void>();

  @override
  Duration get timeout => const Duration(seconds: 1);

  @override
  Future<List<EquipoDto>> obtenerEquipos() async {
    llamadas++;
    await bloqueo.future;
    return const [
      EquipoDto(id: 'b', nombre: 'Zeta', categoria: 'X', descripcion: '', imagen: ''),
      EquipoDto(id: 'a', nombre: 'alfa', categoria: 'X', descripcion: '', imagen: ''),
    ];
  }

  @override
  void cerrar() {}
}

void main() {
  late FakeEquipoRepository repo;

  CatalogoController crear() => CatalogoController(
        repository: repo,
        preferencias: PreferenciasService(),
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = FakeEquipoRepository();
  });

  test('carga los equipos y pasa a estado datos', () async {
    final c = crear();
    expect(c.estado, EstadoCatalogo.cargando);
    await c.cargar();

    expect(c.estado, EstadoCatalogo.datos);
    expect(c.equiposFiltrados, hasLength(3));
    expect(c.categorias, ['Portátiles', 'Proyectores', 'Tablets']);
  });

  test('una lista vacía deja el estado vacío', () async {
    repo.equipos = [];
    final c = crear();
    await c.cargar();
    expect(c.estado, EstadoCatalogo.vacio);
  });

  test('un error muestra el mensaje y reintentar recupera los datos', () async {
    repo.errorSiguiente = const SinConexionException();
    final c = crear();
    await c.cargar();

    expect(c.estado, EstadoCatalogo.error);
    expect(c.mensajeError, contains('Sin conexión'));

    await c.reintentar();
    expect(c.estado, EstadoCatalogo.datos);
    expect(c.mensajeError, isNull);
    expect(repo.llamadas, 2);
  });

  test('si falla una recarga se conservan los datos anteriores', () async {
    final c = crear();
    await c.cargar();
    repo.errorSiguiente = const TiempoAgotadoException();
    await c.cargar();

    expect(c.estado, EstadoCatalogo.datos);
    expect(c.equiposFiltrados, isNotEmpty);
    expect(c.mensajeError, isNotNull);
  });

  test('no repite la petición mientras otra está en curso', () async {
    repo.bloqueo = Completer<void>();
    final c = crear();
    final primera = c.cargar();
    await c.cargar();
    repo.bloqueo!.complete();
    await primera;

    expect(repo.llamadas, 1);
  });

  test('el filtro por categoría se guarda en SharedPreferences', () async {
    final c = crear();
    await c.cargar();
    await c.seleccionarCategoria('Proyectores');

    expect(c.equiposFiltrados.map((e) => e.id), ['eq-2']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('catalogo.categoria'), 'Proyectores');

    await c.seleccionarCategoria(null);
    expect(prefs.getString('catalogo.categoria'), isNull);
    expect(c.equiposFiltrados, hasLength(3));
  });

  test('restaura la categoría guardada al volver a abrir el catálogo', () async {
    SharedPreferences.setMockInitialValues({'catalogo.categoria': 'Tablets'});
    final c = crear();
    await c.cargar();

    expect(c.categoriaSeleccionada, 'Tablets');
    expect(c.equiposFiltrados.map((e) => e.id), ['eq-3']);
  });

  test('ignora una categoría guardada que ya no existe', () async {
    SharedPreferences.setMockInitialValues({'catalogo.categoria': 'Drones'});
    final c = crear();
    await c.cargar();

    expect(c.categoriaSeleccionada, isNull);
    expect(c.equiposFiltrados, hasLength(3));
  });

  test('no notifica después de dispose', () async {
    repo.bloqueo = Completer<void>();
    final c = crear();
    final carga = c.cargar();
    c.dispose();
    repo.bloqueo!.complete();
    await expectLater(carga, completes);
  });

  group('EquipoRepository', () {
    test('ordena por nombre y comparte una consulta en curso', () async {
      final api = _ApiContadora();
      final repository = EquipoRepository(api: api);

      final a = repository.obtenerEquipos();
      final b = repository.obtenerEquipos();
      api.bloqueo.complete();
      final resultado = await a;
      await b;

      expect(api.llamadas, 1);
      expect(resultado.map((e) => e.nombre), ['alfa', 'Zeta']);
    });
  });
}
