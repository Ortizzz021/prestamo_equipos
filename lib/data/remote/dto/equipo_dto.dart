import '../../../domain/models/equipo.dart';

class EquipoDto {
  const EquipoDto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.imagen,
  });

  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final String imagen;

  factory EquipoDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String && id is! int) {
      throw const FormatException('El campo "id" es obligatorio');
    }
    final idTexto = id.toString().trim();
    if (idTexto.isEmpty) {
      throw const FormatException('El campo "id" no puede estar vacío');
    }

    return EquipoDto(
      id: idTexto,
      nombre: _textoObligatorio(json, 'nombre'),
      categoria: _textoObligatorio(json, 'categoria'),
      descripcion: _textoOpcional(json, 'descripcion'),
      imagen: _textoOpcional(json, 'imagen'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'categoria': categoria,
        'descripcion': descripcion,
        'imagen': imagen,
      };

  Equipo toDomain() => Equipo(
        id: id,
        nombre: nombre,
        categoria: categoria,
        descripcion: descripcion,
        imagenUrl: imagen,
      );

  static String _textoObligatorio(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor is! String || valor.trim().isEmpty) {
      throw FormatException('El campo "$campo" es obligatorio');
    }
    return valor.trim();
  }

  static String _textoOpcional(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor == null) return '';
    if (valor is! String) {
      throw FormatException('El campo "$campo" debe ser texto');
    }
    return valor.trim();
  }
}
