import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasService {
  PreferenciasService({Future<SharedPreferences>? prefs})
      : _prefs = prefs ?? SharedPreferences.getInstance();

  static const String _claveCategoriaCatalogo = 'catalogo.categoria';

  final Future<SharedPreferences> _prefs;

  Future<String?> categoriaCatalogo() async {
    try {
      return (await _prefs).getString(_claveCategoriaCatalogo);
    } catch (_) {
      return null;
    }
  }

  Future<void> guardarCategoriaCatalogo(String? categoria) async {
    try {
      final prefs = await _prefs;
      if (categoria == null) {
        await prefs.remove(_claveCategoriaCatalogo);
      } else {
        await prefs.setString(_claveCategoriaCatalogo, categoria);
      }
    } catch (_) {}
  }
}
