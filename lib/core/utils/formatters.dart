import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _compact = NumberFormat.compact();
  static final _pct = NumberFormat('+##0.00;-##0.00');

  static String currency(double value, {String symbol = '\$', int decimalDigits = 2}) {
    return NumberFormat.currency(symbol: symbol, decimalDigits: decimalDigits).format(value);
  }
  static String compact(double value) => _compact.format(value);
  static String percent(double value) => '${_pct.format(value)}%';
  static String co2(double value) => '${value.toStringAsFixed(1)} ';
}
