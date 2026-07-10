import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Formats and displays a rupee amount with proper formatting and styling.
class AmountDisplay extends StatelessWidget {
  final int amount;
  final TextStyle? style;
  final Color? color;
  final bool compact;
  final bool showZeroAsEmpty;

  const AmountDisplay({
    required this.amount,
    this.style,
    this.color,
    this.compact = false,
    this.showZeroAsEmpty = false,
    super.key,
  });

  /// Format amount in Indian numbering system (e.g., 1,24,500).
  static String formatAmount(int amount) {
    if (amount == 0) return '0';

    String text = amount.toString();
    StringBuffer buffer = StringBuffer();
    int count = 0;

    for (int i = text.length - 1; i >= 0; i--) {
      if (count > 0 && count % 2 == 0 && text[i] != '-') {
        buffer.write(',');
      }
      buffer.write(text[i]);
      count++;
    }

    String formatted = buffer.toString().split('').reversed.join();
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    if (showZeroAsEmpty && amount == 0) {
      return Text(
        '—',
        style: style ?? Theme.of(context).textTheme.titleMedium,
      );
    }

    final formattedAmount = formatAmount(amount);
    final displayText = compact ? formattedAmount : '₹ $formattedAmount';

    return Text(
      displayText,
      style: (style ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
            color: color ?? AppColors.amountNormal,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
    );
  }
}
