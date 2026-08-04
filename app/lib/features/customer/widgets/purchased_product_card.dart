import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/activity.dart';

class GroupedSales {
  const GroupedSales({
    required this.date,
    required this.saleType,
    required this.sales,
  });

  final DateTime date;
  final String saleType;
  final List<SaleActivity> sales;
}

class PurchaseSummaryCard extends StatelessWidget {
  const PurchaseSummaryCard({
    super.key,
    required this.groupedSale,
  });

  final GroupedSales groupedSale;

  void _showFinancialsSheet(BuildContext context, AppColors colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).padding.bottom + 88.0 + AppSpacing.lg,
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colors.muted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Financial Summary',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.mutedFg),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Purchases on ${dateFull(groupedSale.date)}',
                style: AppTypography.bodySmall.copyWith(color: colors.mutedFg),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: groupedSale.sales.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final sale = entry.value;
                      final isLend = sale.saleType.toUpperCase() == 'LEND';
                      final isCredit = sale.saleType.toUpperCase() == 'CREDIT';
                      final badgeColor = isLend ? Colors.orange : (isCredit ? colors.danger : colors.success);
                      
                      final lend = isLend ? _LendDetails.parse(sale.note ?? '') : null;
                      final itemsTotal = isLend
                          ? lend!.principal
                          : sale.items.fold<int>(0, (sum, item) => sum + item.quantity * item.unitPrice);
                      final creditCharge = isLend
                          ? lend!.charge
                          : (sale.total - itemsTotal).clamp(0, 9999999);
                      final timeStr = DateFormat('hh:mm a').format(sale.at);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (idx > 0) const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                timeStr,
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  sale.saleType.toUpperCase(),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: badgeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Products list or Lend principal amount
                          if (isLend)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Cash Loan / Lend',
                                      style: AppTypography.bodyMedium.copyWith(color: colors.foreground.withValues(alpha: 0.8)),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    rupees(lend!.principal),
                                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...sale.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.productName} (x${item.quantity})',
                                        style: AppTypography.bodyMedium.copyWith(color: colors.foreground.withValues(alpha: 0.8)),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      rupees(item.unitPrice * item.quantity),
                                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          const SizedBox(height: 12),
                          // Elevated Financial Card
                          Card(
                            elevation: 4,
                            shadowColor: colors.border.withValues(alpha: 0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: colors.border.withValues(alpha: 0.5)),
                            ),
                            color: colors.surface,
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(isLend ? 'Principal Amount' : 'Items Total', style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg)),
                                      Text(rupees(itemsTotal), style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  if (creditCharge > 0) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Credit Charge', style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg)),
                                        Text('+ ${rupees(creditCharge)}', style: AppTypography.bodyMedium.copyWith(color: colors.warning, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(isLend ? 'Lend Total' : 'Grand Total', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                      Text(rupees(sale.total), style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: isLend ? Colors.orange : colors.primary)),
                                    ],
                                  ),
                                  if (!isLend) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Down Payment', style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg)),
                                        Text('- ${rupees(sale.advance)}', style: AppTypography.bodyMedium.copyWith(color: colors.success, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                  if (isCredit || isLend) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Financed Outstanding', style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg)),
                                        Text('+ ${rupees(sale.creditAdded)}', style: AppTypography.bodyMedium.copyWith(color: isLend ? Colors.orange : colors.danger, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLend = groupedSale.saleType.toUpperCase() == 'LEND';
    final isCredit = groupedSale.saleType.toUpperCase() == 'CREDIT';
    final badgeColor = isLend ? Colors.orange : (isCredit ? colors.danger : colors.success);

    return GestureDetector(
      onTap: () => _showFinancialsSheet(context, colors),
      child: Container(
        width: 220,
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
            // Header: Date and Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 10, color: colors.mutedFg),
                    const SizedBox(width: 4),
                    Text(
                      dateShort(groupedSale.date),
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.mutedFg,
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
                    groupedSale.saleType.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // X & Y Grid Timeline Graph UI
            Expanded(
              child: SizedBox(
                height: 96,
                child: Row(
                  children: [
                    // Y Axis Labels
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0), // align with axis
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildYAxisLabel('READY', colors.success),
                          _buildYAxisLabel('CREDIT', colors.danger),
                          _buildYAxisLabel('LEND', Colors.orange),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Graph Area
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Grid lines: Horizontal
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(height: 0.5, color: colors.border.withValues(alpha: 0.2)),
                              Container(height: 0.5, color: colors.border.withValues(alpha: 0.2)),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0), // match bottom offset
                                child: Container(height: 0.5, color: colors.border.withValues(alpha: 0.2)),
                              ),
                            ],
                          ),
                          // Grid lines: Vertical
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(width: 0.5, color: colors.border.withValues(alpha: 0.15)),
                                Container(width: 0.5, color: colors.border.withValues(alpha: 0.15)),
                                Container(width: 0.5, color: colors.border.withValues(alpha: 0.15)),
                              ],
                            ),
                          ),
                          // Y-Axis line
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 16,
                            child: Container(width: 1.2, color: colors.border.withValues(alpha: 0.5)),
                          ),
                          // X-Axis line
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 16,
                            child: Container(height: 1.2, color: colors.border.withValues(alpha: 0.5)),
                          ),
                          // Nodes & timeline labels
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: groupedSale.sales.map((sale) {
                                final type = sale.saleType.toUpperCase();
                                final double nodeVal; // 1.0 for READY, 0.5 for CREDIT, 0.0 for LEND
                                final Color nodeColor;
                                if (type == 'LEND') {
                                  nodeVal = 0.0;
                                  nodeColor = Colors.orange;
                                } else if (type == 'CREDIT') {
                                  nodeVal = 0.5;
                                  nodeColor = colors.danger;
                                } else {
                                  nodeVal = 1.0;
                                  nodeColor = colors.success;
                                }
                                final timeStr = DateFormat('hh:mm a').format(sale.at);
                                return Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final totalHeight = constraints.maxHeight;
                                      final double topOffset = (1.0 - nodeVal) * totalHeight;
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.center,
                                        children: [
                                          // Trace Line to X-Axis
                                          Positioned(
                                            top: topOffset,
                                            bottom: 0,
                                            child: Container(
                                              width: 0.8,
                                              color: nodeColor.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          // Node Circle
                                          Positioned(
                                            top: topOffset - 4, // center the circle
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: colors.surface,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: nodeColor, width: 2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: nodeColor.withValues(alpha: 0.2),
                                                    blurRadius: 3,
                                                    spreadRadius: 0.5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Time Label (X-axis ticks)
                                          Positioned(
                                            bottom: -14,
                                            child: Text(
                                              timeStr,
                                              style: AppTypography.labelSmall.copyWith(
                                                color: colors.mutedFg,
                                                fontSize: 7,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Divider(height: 12),
            
            // Footer: Tap to view financials summary info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tap for details',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.primary,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  rupees(groupedSale.sales.fold<int>(0, (sum, sale) => sum + sale.total)),
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYAxisLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontSize: 6.5,
          fontWeight: FontWeight.bold,
        ),
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
