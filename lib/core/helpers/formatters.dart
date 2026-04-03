import 'package:intl/intl.dart';

class Formatters {
  static final _money = NumberFormat.currency(symbol: '€', decimalDigits: 2);

  static String money(num value) => _money.format(value);
  static String date(DateTime value) => DateFormat('dd/MM/yyyy').format(value);
}
