import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _indianNumberFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(int priceInPaisa) {
    final priceInRupees = priceInPaisa / 100;
    return _indianNumberFormat.format(priceInRupees);
  }

  static String formatDirect(double price) {
    return _indianNumberFormat.format(price);
  }

  static String formatCompact(int priceInPaisa) {
    final priceInRupees = priceInPaisa / 100;
    if (priceInRupees >= 100000) {
      return '₹${(priceInRupees / 100000).toStringAsFixed(1)}L';
    } else if (priceInRupees >= 1000) {
      return '₹${(priceInRupees / 1000).toStringAsFixed(1)}K';
    }
    return _indianNumberFormat.format(priceInRupees);
  }
}
