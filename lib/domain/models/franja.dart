import '../../core/errors/regla_negocio_exception.dart';

/// Bloque horario predeterminado del día. Las solicitudes solo pueden usar
/// estos bloques, lo que permite modelar un documento por franja en Firestore.
enum SlotHorario {
  manana1('08-10', 8, 10),
  manana2('10-12', 10, 12),
  tarde1('14-16', 14, 16),
  tarde2('16-18', 16, 18);

  const SlotHorario(this.codigo, this.horaInicio, this.horaFin);

  /// Código estable guardado en Drift/Firestore.
  final String codigo;
  final int horaInicio;
  final int horaFin;

  String get etiqueta =>
      '${_dosDigitos(horaInicio)}:00 - ${_dosDigitos(horaFin)}:00';

  static SlotHorario desdeCodigo(String codigo) {
    for (final slot in SlotHorario.values) {
      if (slot.codigo == codigo) return slot;
    }
    throw ArgumentError.value(codigo, 'codigo', 'Slot horario desconocido');
  }
}

/// Franja de préstamo: un día concreto + un [SlotHorario].
class Franja {
  Franja({required DateTime fecha, required this.slot})
      : fecha = DateTime(fecha.year, fecha.month, fecha.day);

  /// Día de la franja (sin hora).
  final DateTime fecha;
  final SlotHorario slot;

  DateTime get inicio =>
      DateTime(fecha.year, fecha.month, fecha.day, slot.horaInicio);

  DateTime get fin => DateTime(fecha.year, fecha.month, fecha.day, slot.horaFin);

  /// Fecha en formato `yyyyMMdd`, usada en identificadores.
  String get fechaClave =>
      '${fecha.year}${_dosDigitos(fecha.month)}${_dosDigitos(fecha.day)}';

  /// Identificador del documento de ocupación en Firestore
  /// (`franjas/{equipoId}_{yyyyMMdd}_{slot}`). Al ser determinístico, dos
  /// aprobaciones de la misma franja compiten por el mismo documento.
  String idOcupacion(String equipoId) =>
      '${equipoId}_${fechaClave}_${slot.codigo}';

  bool esFutura(DateTime ahora) => inicio.isAfter(ahora);

  /// Valida las reglas de la ficha: la franja debe ser futura y su inicio
  /// anterior al fin. Lanza [ReglaNegocioException] si no se cumplen.
  void validar(DateTime ahora) {
    if (!inicio.isBefore(fin)) {
      throw const ReglaNegocioException(
        'FRANJA_INVALIDA',
        'La hora de inicio debe ser anterior a la hora de fin.',
      );
    }
    if (!esFutura(ahora)) {
      throw const ReglaNegocioException(
        'FRANJA_PASADA',
        'La franja seleccionada ya comenzó o pasó. Elige una franja futura.',
      );
    }
  }

  /// Franjas predeterminadas de [dia] que todavía son futuras respecto a
  /// [ahora]. Sirve para poblar el selector del formulario.
  static List<Franja> disponiblesDelDia(DateTime dia, DateTime ahora) => [
        for (final slot in SlotHorario.values)
          if (Franja(fecha: dia, slot: slot).esFutura(ahora))
            Franja(fecha: dia, slot: slot),
      ];

  @override
  bool operator ==(Object other) =>
      other is Franja && other.fecha == fecha && other.slot == slot;

  @override
  int get hashCode => Object.hash(fecha, slot);

  @override
  String toString() => 'Franja($fechaClave ${slot.codigo})';
}

String _dosDigitos(int n) => n.toString().padLeft(2, '0');
