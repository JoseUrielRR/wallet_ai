import 'package:intl/intl.dart';

/// Formateador estricto para valores monetarios enteros en centavos
class MoneyFormatter {
  MoneyFormatter._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Convierte centavos enteros a formato legible (ej: 150000 -> "$1,500.00")
  static String formatCents(int cents, {String currency = 'MXN'}) {
    final double amount = cents / 100.0;
    return '${_currencyFormat.format(amount)} $currency';
  }

  /// Convierte double a centavos enteros sin perder precisión por IEEE-754
  static int toCents(double amount) {
    return (amount * 100).round();
  }

  /// Convierte centavos enteros a double para widgets que requieren double (ej. progress sliders)
  static double toDouble(int cents) {
    return cents / 100.0;
  }
}
