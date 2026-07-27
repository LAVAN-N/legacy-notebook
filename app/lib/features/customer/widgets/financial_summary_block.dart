import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../data/models/outstanding.dart';
import 'purchased_product_card.dart';

class FinancialSummaryBlock extends StatelessWidget {
  const FinancialSummaryBlock({
    super.key,
    required this.outstanding,
    required this.groupedSales,
  });

  final Outstanding outstanding;
  final List<GroupedSales> groupedSales;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Running Balance Summary',
              style: AppTypography.titleSmall.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Purchases',
                        style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                      ),
                      const SizedBox(height: 4),
                      AmountText(
                        amount: outstanding.totalFinanced,
                        style: AppTypography.currencyMedium.copyWith(
                          color: colors.foreground,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: colors.border,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Collected',
                        style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                      ),
                      const SizedBox(height: 4),
                      AmountText(
                        amount: outstanding.totalCollected,
                        style: AppTypography.currencyMedium.copyWith(
                          color: colors.success,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NET OUTSTANDING',
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.mutedFg,
                    letterSpacing: 0.5,
                  ),
                ),
                AmountText(
                  amount: outstanding.outstandingAmount,
                  style: AppTypography.currencyLarge.copyWith(
                    color: outstanding.outstandingAmount > 0 ? colors.danger : colors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Purchase Summary',
              style: AppTypography.titleSmall.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (groupedSales.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.border.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'No purchases recorded yet.',
                  style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg),
                ),
              )
            else
              SizedBox(
                height: 165,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: groupedSales.length,
                  itemBuilder: (context, index) {
                    final grouped = groupedSales[index];
                    return PurchaseSummaryCard(groupedSale: grouped);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
