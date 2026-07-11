import 'package:intl/intl.dart';

/// Format an integer rupee amount with ₹ prefix and en_IN grouping.
/// Example: rupees(1200000) → "₹12,00,000"
String rupees(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

/// Format DateTime as short date.
/// Example: dateShort(DateTime(2026, 7, 9)) → "09 Jul"
String dateShort(DateTime date) {
  return DateFormat('dd MMM').format(date);
}

/// Format DateTime as full date with weekday.
/// Example: dateFull(DateTime(2026, 7, 9)) → "Wednesday, 09 Jul"
String dateFull(DateTime date) {
  return DateFormat('EEEE, dd MMM').format(date);
}

/// Format DateTime as date with year.
/// Example: dateWithYear(DateTime(2025, 12, 27)) → "Sat · 27 Dec 2025"
String dateWithYear(DateTime date) {
  return DateFormat('E · dd MMM yyyy').format(date);
}

/// Format DateTime as time.
/// Example: timeShort(DateTime(..., 9, 15)) → "09:15 AM"
String timeShort(DateTime date) {
  return DateFormat('hh:mm a').format(date);
}

/// Relative time from now.
/// Example: relativeTime(now.subtract(Duration(hours: 2))) → "2 h ago"
String relativeTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  if (diff.inDays < 30) return '${diff.inDays ~/ 7} w ago';
  if (diff.inDays < 365) return '${diff.inDays ~/ 30} mo ago';
  return '${diff.inDays ~/ 365} y ago';
}

/// Get time-of-day greeting.
String greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// Get current weekday name.
String currentWeekdayName() {
  return DateFormat('EEEE').format(DateTime.now());
}

/// Check if a date is today.
bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

/// Check if a date is yesterday.
bool isYesterday(DateTime date) {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day;
}

/// Get a friendly day label for timeline grouping.
String dayLabel(DateTime date) {
  if (isToday(date)) return 'Today · ${dateShort(date)}';
  if (isYesterday(date)) return 'Yesterday · ${dateShort(date)}';

  final now = DateTime.now();
  if (date.year != now.year) return dateWithYear(date);

  return '${DateFormat('E').format(date)} · ${dateShort(date)}';
}
