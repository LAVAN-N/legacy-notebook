import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.amount,
    this.style,
    this.useSemanticLabel = true,
  });

  final int amount;
  final TextStyle? style;
  final bool useSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? AppTypography.currencyMedium;
    final formatted = rupees(amount);

    if (!useSemanticLabel) {
      return Text(formatted, style: textStyle);
    }

    return Semantics(
      label: '$amount rupees',
      child: Text(
        formatted,
        style: textStyle,
      ),
    );
  }
}
