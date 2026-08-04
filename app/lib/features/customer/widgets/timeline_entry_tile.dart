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
        final col = _CollectionDetails.parse(note);
        icon = Icons.check_circle_outline;
        iconColor = col.target == 'LEND' ? Colors.orange : colors.success;
        iconBg = iconColor.withValues(alpha: 0.1);
        title = customTitle ?? (col.target == 'LEND' ? 'Loan Repayment' : 'Full Payment');
        subtitle = '${dateShort(at)} · By $collectorName';
        if (col.note.isNotEmpty) {
          subtitle += '\n"${col.note}"';
        }
        trailing = Text(
          '-${rupees(amount)}',
          style: AppTypography.currencySmall.copyWith(color: iconColor),
        );
      },
      partialPayment: (id, at, amount, note, collectorName) {
        final col = _CollectionDetails.parse(note);
        icon = Icons.pie_chart_outline;
        iconColor = col.target == 'LEND' ? Colors.orange : colors.primary;
        iconBg = iconColor.withValues(alpha: 0.1);
        title = customTitle ?? (col.target == 'LEND' ? 'Loan Partial Repayment' : 'Partial Payment');
        subtitle = '${dateShort(at)} · By $collectorName';
        if (col.note.isNotEmpty) {
          subtitle += '\n"${col.note}"';
        }
        trailing = Text(
          '-${rupees(amount)}',
          style: AppTypography.currencySmall.copyWith(color: iconColor),
        );
      },
      carryForward: (id, at, note, collectorName) {
        final col = _CollectionDetails.parse(note);
        icon = Icons.arrow_forward;
        iconColor = col.target == 'LEND' ? Colors.orange : colors.warning;
        iconBg = iconColor.withValues(alpha: 0.1);
        title = customTitle ?? (col.target == 'LEND' ? 'Loan Carry Forward' : 'Carry Forward');
        subtitle = '${dateShort(at)} · By $collectorName';
        if (col.note.isNotEmpty) {
          subtitle += '\n"${col.note}"';
        }
        trailing = Text(
          '₹0',
          style: AppTypography.currencySmall.copyWith(color: colors.mutedFg),
        );
      },
      sale: (id, at, items, total, advance, creditAdded, saleType, collectorName, note) {
        if (saleType.toUpperCase() == 'LEND') {
          final lend = _LendDetails.parse(note ?? '');
          icon = Icons.handshake_outlined;
          iconColor = Colors.orange;
          iconBg = Colors.orange.withValues(alpha: 0.1);
          title = customTitle ?? 'Cash Loan / Lend';
          subtitle = '${dateShort(at)} · By $collectorName';
          subtitle += '\nPrincipal: ${rupees(lend.principal)} · Surcharge: ${rupees(lend.charge)}';
          if (lend.note.isNotEmpty) {
            subtitle += '\n"${lend.note}"';
          }

          trailing = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${rupees(creditAdded)}',
                style: AppTypography.currencySmall.copyWith(
                  color: Colors.orange,
                ),
              ),
            ],
          );
        } else {
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
        }
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

class _LendDetails {
  final int principal;
  final int charge;
  final String note;

  _LendDetails({required this.principal, required this.charge, required this.note});

  factory _LendDetails.parse(String remarks) {
    if (!remarks.startsWith('LEND_DETAILS:')) {
      return _LendDetails(principal: 0, charge: 0, note: remarks);
    }
    try {
      final query = remarks.substring('LEND_DETAILS:'.length);
      final params = Uri.splitQueryString(query);
      return _LendDetails(
        principal: int.parse(params['principal'] ?? '0'),
        charge: int.parse(params['charge'] ?? '0'),
        note: params['note'] ?? '',
      );
    } catch (_) {
      return _LendDetails(principal: 0, charge: 0, note: remarks);
    }
  }
}

class _CollectionDetails {
  final String target;
  final String note;

  _CollectionDetails({required this.target, required this.note});

  factory _CollectionDetails.parse(String? reason) {
    if (reason == null || !reason.startsWith('COLLECTION_TARGET:')) {
      return _CollectionDetails(target: 'SALE', note: reason ?? '');
    }
    try {
      final query = reason.substring('COLLECTION_TARGET:'.length);
      final params = Uri.splitQueryString(query);
      return _CollectionDetails(
        target: params['target'] ?? 'SALE',
        note: params['note'] ?? '',
      );
    } catch (_) {
      return _CollectionDetails(target: 'SALE', note: reason);
    }
  }
}
