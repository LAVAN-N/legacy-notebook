import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/activity.dart';

class PurchaseSummaryCard extends StatelessWidget {
  const PurchaseSummaryCard({
    super.key,
    required this.sale,
  });

  final SaleActivity sale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCredit = sale.saleType.toUpperCase() == 'CREDIT';
    final badgeColor = isCredit ? colors.danger : colors.success;

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.border.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Date and Sale Type Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: colors.mutedFg),
                  const SizedBox(width: 6),
                  Text(
                    dateShort(sale.at),
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  sale.saleType.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Products list
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: sale.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_right, size: 12, color: colors.mutedFg),
                      Expanded(
                        child: Text(
                          '${item.productName} (x${item.quantity})',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.foreground.withValues(alpha: 0.9),
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          const Divider(height: 12),
          
          // Financial Summary
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: AppTypography.labelSmall.copyWith(color: colors.mutedFg, fontSize: 9),
                  ),
                  Text(
                    rupees(sale.total),
                    style: AppTypography.labelSmall.copyWith(color: colors.foreground, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Down Payment:',
                    style: AppTypography.labelSmall.copyWith(color: colors.mutedFg, fontSize: 9),
                  ),
                  Text(
                    rupees(sale.advance),
                    style: AppTypography.labelSmall.copyWith(color: colors.success, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ],
              ),
              if (isCredit) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Credit Added:',
                      style: AppTypography.labelSmall.copyWith(color: colors.mutedFg, fontSize: 9),
                    ),
                    Text(
                      rupees(sale.creditAdded),
                      style: AppTypography.labelSmall.copyWith(color: colors.danger, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
