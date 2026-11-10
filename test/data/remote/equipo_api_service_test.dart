import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:prestamo_equipos/core/errors/api_exception.dart';
import 'package:prestamo_equipos/data/remote/dto/equipo_dto.dart';
import 'package:prestamo_equipos/data/remote/equipo_api_service.dart';

void main() {
  final uri = Uri.parse('https://api.prueba.com/equipos');

  EquipoApiService servicio(
    Future<http.Response> Function(http.Request) handler, {
    Duration timeout = const Duration(seconds: 2),
  }) =>
      EquipoApiService(client: MockClient(handler), uri: uri, timeout: timeout);

  http.Response json(Object cuerpo, [int status = 200]) => http.Response.bytes(
        utf8.encode(jsonEncode(cuerpo)),
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

  final equipoValido = {
    'id': 'eq-1',
    'nombre': 'Portátil Lenovo',
    'categoria': 'Portátiles',
    'descripcion': 'Core i5, 16 GB',
    'imagen': 'https://img.prueba.com/1.png',
  };

  group('EquipoApiService.obtenerEquipos', () {
    test('respuesta exitosa: convierte el JSON en equipos', () async {
      final api = servicio((req) async {
        expect(req.url, uri);
        expect(req.headers['Accept'], 'application/json');
        return json([
          equipoValido,
          {...equipoValido, 'id': 'eq-2', 'nombre': 'Proyector Epson'},
        ]);
      });

      final equipos = await api.obtenerEquipos();

      expect(equipos, hasLength(2));
      expect(equipos.first.nombre, 'Portátil Lenovo');
      expect(equipos.last.toDomain().id, 'eq-2');
    });

    test('lista vacía: devuelve una lista vacía sin error', () async {
      final api = servicio((_) async => json([]));
      expect(await api.obtenerEquipos(), isEmpty);
    });

    test('código HTTP 500: error reintentable', () async {
      final api = servicio((_) async => http.Response('falló', 500));
      await expectLater(
        api.obtenerEquipos(),
        throwsA(
          isA<RespuestaHttpException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.esReintentable, 'esReintentable', isTrue),
        ),
      );
    });

    test('código HTTP 404: mensaje de catálogo no encontrado', () async {
      final api = servicio((_) async => http.Response('', 404));
      await expectLater(
        api.obtenerEquipos(),
        throwsA(
          isA<RespuestaHttpException>().having(
            (e) => e.mensaje,
            'mensaje',
            'No se encontró el catálogo de equipos.',
          ),
        ),
      );
    });

    test('JSON mal formado: FormatoInvalidoException', () async {
      final api = servicio((_) async => http.Response('{no es json', 200));
      await expectLater(
        api.obtenerEquipos(),
        throwsA(isA<FormatoInvalidoException>()),
      );
    });

    test('la raíz no es una lista: FormatoInvalidoException', () async {
      final api = servicio((_) async => json({'equipos': []}));
      await expectLater(
        api.obtenerEquipos(),
        throwsA(isA<FormatoInvalidoException>()),
      );
    });

    test('elemento sin nombre: FormatoInvalidoException', () async {
      final api = servicio(
        (_) async => json([
          {...equipoValido}..remove('nombre'),
        ]),
      );
      await expectLater(
        api.obtenerEquipos(),
        throwsA(isA<FormatoInvalidoException>()),
      );
    });

    test('ids repetidos: FormatoInvalidoException', () async {
      final api = servicio((_) async => json([equipoValido, equipoValido]));
      await expectLater(
        api.obtenerEquipos(),
        throwsA(isA<FormatoInvalidoException>()),
      );
    });

    test('sin conexión: SinConexionException', () async {
      final api = servicio(
        (_) async => throw http.ClientException('Failed host lookup'),
      );
      await expectLater(
        api.obtenerEquipos(),
        throwsA(isA<SinConexionException>()),
      );
    });

    test('SocketException: SinConexionException', () async {
      final api = servicio((_) async => throw const SocketException('sin red'));
      await expectLater(
        api.obtenerEquipos(),
        throwsA(isA<SinConexionException>()),
      );
    });

    test('el servidor no responde a tiempo: TiempoAgotadoException', () async {
      final api = servicio(
        (_) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 50),
      );
      await expectLater(
        api.obtenerEquipos(),
        throwsA(isA<TiempoAgotadoException>()),
      );
    });

    test('error inesperado: ErrorInesperadoApiException', () async {
      final api = servicio((_) async => throw StateError('algo raro'));
      await expectLater(
        api.obtenerEquipos(),
        throwsA(isA<ErrorInesperadoApiException>()),
      );
    });
  });

  group('EquipoDto', () {
    test('acepta id numérico (formato MockAPI) y campos opcionales nulos', () {
      final dto = EquipoDto.fromJson({
        'id': 7,
        'nombre': ' Cámara ',
        'categoria': 'Cámaras',
        'descripcion': null,
      });
      expect(dto.id, '7');
      expect(dto.nombre, 'Cámara');
      expect(dto.descripcion, '');
      expect(dto.imagen, '');
    });

    test('rechaza categoría vacía', () {
      expect(
        () => EquipoDto.fromJson({...equipoValido, 'categoria': '  '}),
        throwsFormatException,
      );
    });

    test('toJson y fromJson son inversos', () {
      final dto = EquipoDto.fromJson(equipoValido);
      expect(dto.toJson(), equipoValido);
    });
  });

  test('api/equipos.json publicado tiene al menos 8 equipos válidos', () {
    final contenido = File('api/equipos.json').readAsStringSync();
    final lista = jsonDecode(contenido) as List<dynamic>;
    final equipos =
        lista.map((e) => EquipoDto.fromJson(e as Map<String, dynamic>)).toList();

    expect(equipos.length, greaterThanOrEqualTo(8));
    expect(equipos.map((e) => e.id).toSet(), hasLength(equipos.length));
  });
}
