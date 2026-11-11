import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/errors/api_exception.dart';
import '../../core/logging/app_logger.dart';
import 'dto/equipo_dto.dart';

class EquipoApiService {
  EquipoApiService({
    http.Client? client,
    Uri? uri,
    this.timeout = ApiConfig.timeout,
  }) : _client = client ?? http.Client(),
       _uri = uri ?? Uri.parse(ApiConfig.catalogoUrl);

  final http.Client _client;
  final Uri _uri;
  final Duration timeout;

  Future<List<EquipoDto>> obtenerEquipos() async {
    final http.Response respuesta;
    try {
      respuesta = await _client
          .get(_uri, headers: const {'Accept': 'application/json'})
          .timeout(timeout);
    } on TimeoutException catch (error, stack) {
      AppLogger.network(error, stack);
      throw const TiempoAgotadoException();
    } on SocketException catch (error, stack) {
      AppLogger.network(error, stack);
      throw const SinConexionException();
    } on http.ClientException catch (error, stack) {
      AppLogger.network(error, stack);
      throw const SinConexionException();
    } catch (error, stack) {
      AppLogger.unexpected(error, stack);
      throw ErrorInesperadoApiException(error);
    }

    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw RespuestaHttpException(respuesta.statusCode);
    }

    return _parsearLista(respuesta);
  }

  List<EquipoDto> _parsearLista(http.Response respuesta) {
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(respuesta.bodyBytes));
    } on FormatException catch (e) {
      throw FormatoInvalidoException('JSON mal formado: ${e.message}');
    }

    if (json is! List) {
      throw const FormatoInvalidoException('Se esperaba una lista de equipos');
    }

    final equipos = <EquipoDto>[];
    final ids = <String>{};
    for (var i = 0; i < json.length; i++) {
      final item = json[i];
      if (item is! Map<String, dynamic>) {
        throw FormatoInvalidoException('El elemento $i no es un objeto');
      }
      final EquipoDto dto;
      try {
        dto = EquipoDto.fromJson(item);
      } on FormatException catch (e) {
        throw FormatoInvalidoException('Elemento $i: ${e.message}');
      }
      if (!ids.add(dto.id)) {
        throw FormatoInvalidoException('Id de equipo repetido: ${dto.id}');
      }
      equipos.add(dto);
    }
    return equipos;
  }

  void cerrar() => _client.close();
}
