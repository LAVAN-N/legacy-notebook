import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../display/amount_display.dart';

/// Progress bar with label and amount.
class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final int collected;
  final int expected;

  const ProgressBar({
    required this.progress,
    required this.label,
    required this.collected,
    required this.expected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentage = (clampedProgress * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: LinearProgressIndicator(
            value: clampedProgress,
            minHeight: AppSpacing.progressBarHeight,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AmountDisplay(amount: collected),
            Text(
              '/ ${AmountDisplay.formatAmount(expected)}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }
}
