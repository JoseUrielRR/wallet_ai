class DateFormatter {
  DateFormatter._();

  static const List<String> _shortMonths = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  static const List<String> _fullMonths = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  /// Formatea DateTime a fecha corta en español (ej. "15 sep")
  static String formatShort(DateTime date) {
    final month = _shortMonths[date.month - 1];
    return '${date.day} $month';
  }

  /// Formatea DateTime a fecha completa en español (ej. "15 de septiembre, 2026")
  static String formatFull(DateTime date) {
    final month = _fullMonths[date.month - 1];
    return '${date.day} de $month, ${date.year}';
  }

  /// Retorna string ISO yyyy-MM-dd
  static String formatIso(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parsea string ISO yyyy-MM-dd
  static DateTime parseIso(String isoString) {
    return DateTime.parse(isoString);
  }
}
