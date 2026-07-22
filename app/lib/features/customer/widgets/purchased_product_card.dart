import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';

class PurchasedProductCard extends StatelessWidget {
  const PurchasedProductCard({
    super.key,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.purchaseDate,
    required this.saleType,
  });

  final String productName;
  final int quantity;
  final int unitPrice;
  final DateTime purchaseDate;
  final String saleType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCredit = saleType.toUpperCase() == 'CREDIT';
    final badgeColor = isCredit ? colors.danger : colors.success;

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.border.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Qty: $quantity',
                    style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                  ),
                  Text(
                    rupees(unitPrice * quantity),
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 10, color: colors.mutedFg),
                      const SizedBox(width: 4),
                      Text(
                        dateShort(purchaseDate),
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.mutedFg,
                          fontWeight: FontWeight.w500,
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
                      saleType.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
