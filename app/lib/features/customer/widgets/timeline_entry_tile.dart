import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/activity.dart';

class TimelineEntryTile extends StatelessWidget {
  const TimelineEntryTile({
    super.key,
    required this.activity,
    this.customTitle,
  });

  final Activity activity;
  final String? customTitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    late IconData icon;
    late Color iconColor;
    late Color iconBg;
    late String title;
    late String subtitle;
    Widget? trailing;

    activity.when(
      payment: (id, at, amount, note, collectorName) {
        icon = Icons.check_circle_outline;
        iconColor = colors.success;
        iconBg = colors.success.withValues(alpha: 0.1);
        title = customTitle ?? 'Full Payment';
        subtitle = '${dateShort(at)} · By $collectorName';
        if (note != null && note.isNotEmpty) {
          subtitle += '\n"$note"';
        }
        trailing = Text(
          '-${rupees(amount)}',
          style: AppTypography.currencySmall.copyWith(color: colors.success),
        );
      },
      partialPayment: (id, at, amount, note, collectorName) {
        icon = Icons.pie_chart_outline;
        iconColor = colors.primary;
        iconBg = colors.primary.withValues(alpha: 0.1);
        title = customTitle ?? 'Partial Payment';
        subtitle = '${dateShort(at)} · By $collectorName';
        if (note.isNotEmpty) {
          subtitle += '\n"$note"';
        }
        trailing = Text(
          '-${rupees(amount)}',
          style: AppTypography.currencySmall.copyWith(color: colors.primary),
        );
      },
      carryForward: (id, at, note, collectorName) {
        icon = Icons.arrow_forward;
        iconColor = colors.warning;
        iconBg = colors.warning.withValues(alpha: 0.1);
        title = customTitle ?? 'Carry Forward';
        subtitle = '${dateShort(at)} · By $collectorName';
        if (note.isNotEmpty) {
          subtitle += '\n"$note"';
        }
        trailing = Text(
          '₹0',
          style: AppTypography.currencySmall.copyWith(color: colors.mutedFg),
        );
      },
      sale: (id, at, items, total, advance, creditAdded, saleType, collectorName, note) {
        icon = Icons.shopping_bag_outlined;
        iconColor = colors.primary;
        iconBg = colors.primary.withValues(alpha: 0.1);
        title = customTitle ?? '${saleType == 'CREDIT' ? 'Credit' : 'Ready'} Sale';
        subtitle = '${dateShort(at)} · By $collectorName';

        final itemNames = items.map((i) => '${i.productName} (x${i.quantity})').join(', ');
        subtitle += '\n$itemNames';

        if (note != null && note.isNotEmpty) {
          subtitle += '\n"$note"';
        }

        trailing = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+${rupees(creditAdded)}',
              style: AppTypography.currencySmall.copyWith(
                color: creditAdded > 0 ? colors.danger : colors.foreground,
              ),
            ),
            if (advance > 0)
              Text(
                'Paid: ${rupees(advance)}',
                style: AppTypography.labelSmall.copyWith(color: colors.success, fontSize: 10),
              ),
          ],
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),

          // Core content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.mutedFg,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
