import 'package:cloud_firestore/cloud_firestore.dart';

class DateParser {
  DateParser._();

  /// Convierte de forma segura cualquier tipo de fecha proveniente de Firestore
  /// (Timestamp, String ISO-8601, int milisegundos o DateTime) a [DateTime].
  static DateTime? parse(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Convierte de forma segura garantizando un valor no nulo con fallback.
  static DateTime parseWithFallback(dynamic value, [DateTime? fallback]) {
    return parse(value) ?? fallback ?? DateTime.now();
  }
}
