/// Equipo del catálogo. Los datos descriptivos vienen del endpoint HTTP; la
/// disponibilidad operativa (bloqueo, franjas ocupadas) vive en Firestore y
/// no se deduce de este modelo.
class Equipo {
  const Equipo({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.imagenUrl,
  });

  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final String imagenUrl;

  @override
  bool operator ==(Object other) => other is Equipo && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Equipo($id, $nombre)';
}
