abstract final class ApiConfig {
  static const String catalogoUrl = String.fromEnvironment(
    'CATALOGO_URL',
    defaultValue:
        'https://raw.githubusercontent.com/Ortizzz021/prestamo_equipos/main/api/equipos.json',
  );

  static const Duration timeout = Duration(seconds: 10);
}
