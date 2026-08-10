import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../models/transaction_item.dart';

class TransactionCard extends StatefulWidget {
  final TransactionItem item;
  final AppColors colors;
  final String source;

  const TransactionCard({
    super.key,
    required this.item,
    required this.colors,
    this.source = 'transactions',
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final colors = widget.colors;
    final isSale = item.type == 'SALE';
    final isPartial = item.status == 'PARTIAL_PAYMENT';
    final isCarry = item.status == 'CARRY_FORWARD';

    final isLendSale = item.status == 'LEND';
    final isLendRepayment = item.status == 'LEND_COLLECTION';

    Color statusBg;
    Color statusFg;
    IconData icon;

    if (isLendRepayment) {
      statusBg = colors.success.withValues(alpha: 0.08);
      statusFg = colors.success;
      icon = Icons.check_circle_outline;
    } else if (isLendSale) {
      statusBg = Colors.orange.withValues(alpha: 0.08);
      statusFg = Colors.orange;
      icon = Icons.handshake_outlined;
    } else if (isSale) {
      statusBg = colors.primary.withValues(alpha: 0.08);
      statusFg = colors.primary;
      icon = Icons.shopping_cart_rounded;
    } else if (isCarry) {
      statusBg = colors.danger.withValues(alpha: 0.08);
      statusFg = colors.danger;
      icon = Icons.error_outline_rounded;
    } else if (isPartial) {
      statusBg = colors.warning.withValues(alpha: 0.08);
      statusFg = colors.warning;
      icon = Icons.hourglass_bottom_rounded;
    } else {
      statusBg = colors.success.withValues(alpha: 0.08);
      statusFg = colors.success;
      icon = Icons.payments_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: InkWell(
        onTap: () {
          if (item.customer != null) {
            context.push(
              '${Routes.customer(
                item.customer!.weekdayId,
                item.customer!.placeId,
                item.customer!.areaId,
                item.customer!.id,
              )}?source=${widget.source}',
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: statusFg, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customerName,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.mutedFg,
                      ),
                    ),
                    if (item.remarks.isNotEmpty && _isExpanded) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.muted.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: colors.border.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          item.remarks,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.foreground,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 14, color: colors.mutedFg),
                        const SizedBox(width: 4),
                        Text(
                          relativeTime(item.date),
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.mutedFg,
                          ),
                        ),
                        if (item.remarks.isNotEmpty) ...[
                          const Spacer(),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isExpanded ? 'Hide Note' : 'Show Note',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: colors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isCarry ? 'CF' : rupees(item.amount),
                    style: AppTypography.currencySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCarry
                          ? colors.danger
                          : (isLendRepayment
                              ? colors.success
                              : (isLendSale
                                  ? Colors.orange
                                  : (isSale ? colors.primary : colors.success))),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isLendRepayment
                          ? 'Repayment'
                          : (isLendSale ? 'Lend' : (isCarry ? 'Carry-Fwd' : (isSale ? 'Sale' : 'Payment'))),
                      style: AppTypography.labelSmall.copyWith(
                        color: statusFg,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
