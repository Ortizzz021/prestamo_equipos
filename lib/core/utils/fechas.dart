abstract final class Fechas {
  static const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
  static const _meses = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  static String diaCorto(DateTime fecha) => _dias[fecha.weekday - 1];

  static String mesCorto(DateTime fecha) => _meses[fecha.month - 1];

  static String completa(DateTime fecha) =>
      '${diaCorto(fecha)} ${fecha.day} ${mesCorto(fecha)} ${fecha.year}';

  static DateTime soloDia(DateTime fecha) =>
      DateTime(fecha.year, fecha.month, fecha.day);

  static List<DateTime> proximosDias(DateTime desde, int cantidad) => [
        for (var i = 0; i < cantidad; i++)
          DateTime(desde.year, desde.month, desde.day + i),
      ];
}
