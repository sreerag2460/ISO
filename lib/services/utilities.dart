import 'package:intl/intl.dart';

String currencyConverter(num number) {
  final formatter = new NumberFormat("#,##0.00", "en_US");

  return formatter.format(number ?? 0).toString();

}