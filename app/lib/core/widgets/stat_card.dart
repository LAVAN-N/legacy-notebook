import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';
import 'amount_text.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subValue,
    this.icon,
    this.onTap,
  });

  final String label;
  final dynamic value; // String or int
  final String? subValue;
  final Widget? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget valueWidget;
    if (value is int) {
      valueWidget = AmountText(
        amount: value as int,
        style: AppTypography.currencyMedium.copyWith(
          color: colors.foreground,
        ),
      );
    } else {
      valueWidget = Text(
        value.toString(),
        style: AppTypography.headlineMedium.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.mutedFg,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (icon != null) icon!,
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  valueWidget,
                  if (subValue != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subValue!,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.mutedFg,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
