/// Utility class with static helper methods for the application.
class AppUtils {
  /// Format a currency amount in Indian numbering system.
  /// Example: 1234567 -> ₹ 12,34,567
  static String formatIndianCurrency(double amount) {
    final intAmount = amount.toInt();
    final str = intAmount.toString();
    final reversed = str.split('').reversed.toList();
    
    final formatted = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 2 == 0 && i != 2) {
        formatted.add(',');
      } else if (i > 2 && (i - 2) % 3 == 0) {
        formatted.add(',');
      }
      formatted.add(reversed[i]);
    }
    
    return '₹ ${formatted.reversed.join('')}';
  }

  /// Validate if a string is a valid email.
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate if a string is a valid phone number (10 digits).
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'\D'), ''));
  }
}
