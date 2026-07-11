import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/utils/formatters.dart';

class HeroOutstandingCard extends StatelessWidget {
  const HeroOutstandingCard({
    super.key,
    required this.expectedAmount,
    required this.collectedAmount,
    required this.pendingVisits,
    required this.onTapStart,
    required this.weekday,
  });

  final int expectedAmount;
  final int collectedAmount;
  final int pendingVisits;
  final VoidCallback onTapStart;
  final String weekday;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = expectedAmount > 0 ? (collectedAmount / expectedAmount).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primary.withRed(30).withGreen(120),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Route",
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.primaryFg.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    weekday,
                    style: AppTypography.displayLarge.copyWith(
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              if (pendingVisits > 0)
                Container(
                  decoration: BoxDecoration(
                    color: colors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '$pendingVisits Pending',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Expected Collection',
            style: AppTypography.labelMedium.copyWith(
              color: colors.primaryFg.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AmountText(
            amount: expectedAmount,
            style: AppTypography.displayLarge.copyWith(
              color: Colors.white,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Collected: ${rupees(collectedAmount)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.primaryFg.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  color: colors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton.icon(
            onPressed: onTapStart,
            icon: const Icon(Icons.navigation_outlined, color: Colors.white),
            label: const Text('START COLLECTION'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
