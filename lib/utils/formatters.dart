import 'package:intl/intl.dart';

class AppFormatters {
  // Indian Rupee Format (e.g. ₹1,25,450.00)
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatCompact(double amount) {
    return _compactCurrency.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
}
