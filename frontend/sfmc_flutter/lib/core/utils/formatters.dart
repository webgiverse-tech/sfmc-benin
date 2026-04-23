import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(num amount, {String symbol = 'FCFA'}) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(amount)} $symbol';
  }

  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern, 'fr_FR').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(dateTime);
  }

  static String formatNumber(num number) {
    return NumberFormat('#,##0.##', 'fr_FR').format(number);
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
