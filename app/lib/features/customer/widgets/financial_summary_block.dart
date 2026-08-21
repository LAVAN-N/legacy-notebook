import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/outstanding.dart';
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

class FinancialSummaryBlock extends StatefulWidget {
  const FinancialSummaryBlock({
    super.key,
    required this.outstanding,
    required this.groupedSales,
    required this.customer,
  });

  final Outstanding outstanding;
  final List<GroupedSales> groupedSales;
  final Customer customer;

  @override
  State<FinancialSummaryBlock> createState() => _FinancialSummaryBlockState();
}

class _FinancialSummaryBlockState extends State<FinancialSummaryBlock> {
  late int _selectedYear;
  late int _selectedMonth;
  late final ScrollController _monthScrollController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;

    // Months list is ordered ascending: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] (Jan to Dec)
    // Current month index is (now.month - 1).
    // Each month item slot height is exactly 35.0 (30 height + 5 bottom margin).
    // Total container height is 170.0 (5 * 35.0 - 5.0 = 170.0).
    final initialIndex = now.month - 1;
    final initialOffset = initialIndex * 35.0;
    _monthScrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    super.dispose();
  }

  Widget _buildLegendItem(Color color, String label, AppColors colors, {Color? borderColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: borderColor != null ? Border.all(color: borderColor, width: 0.75) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colors.foreground,
            fontSize: 7.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabel(String text, AppColors colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: colors.mutedFg,
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFinancialsSheet(BuildContext context, GroupedSales grouped, AppColors colors) {
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
                'Purchases on ${dateFull(grouped.date)}',
                style: AppTypography.bodySmall.copyWith(color: colors.mutedFg),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: grouped.sales.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final sale = entry.value;
                      final isLend = sale.saleType.toUpperCase() == 'LEND';
                      final isCredit = sale.saleType.toUpperCase() == 'CREDIT';
                      final badgeColor = isLend ? Colors.orange : (isCredit ? colors.danger : colors.success);
                      final lend = isLend ? _LendDetails.parse(sale.note ?? '') : null;
                      
                      final itemsTotal = sale.items.fold<int>(0, (sum, item) => sum + item.quantity * item.unitPrice);
                      final returnedTotal = sale.items.where((it) => it.status == 'returned').fold<int>(0, (sum, it) => sum + it.quantity * it.unitPrice);
                      final creditCharge = (sale.total - itemsTotal).clamp(0, 9999999);
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
                          // Content / Items list
                          if (isLend) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.handshake_outlined, size: 16, color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Cash Loan / Lend',
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: colors.foreground,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    rupees((lend != null && lend.principal > 0) ? lend.principal : sale.total),
                                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            if (lend != null && lend.note.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Text(
                                  '"${lend.note}"',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: colors.mutedFg,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ] else ...[
                            // Products list
                            ...sale.items.map((item) {
                              final isReturned = item.status == 'returned';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.productName} (x${item.quantity})',
                                              style: AppTypography.bodyMedium.copyWith(
                                                color: isReturned ? colors.mutedFg : colors.foreground.withValues(alpha: 0.8),
                                                decoration: isReturned ? TextDecoration.lineThrough : null,
                                                decorationColor: isReturned ? colors.danger : null,
                                                decorationThickness: 2.0,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isReturned) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFDE047).withValues(alpha: 0.25),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: const Color(0xFFFDE047), width: 0.8),
                                              ),
                                              child: Text(
                                                'Returned',
                                                style: AppTypography.labelSmall.copyWith(
                                                  color: const Color(0xFF854D0E),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      rupees(item.unitPrice * item.quantity),
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isReturned ? colors.mutedFg : null,
                                        decoration: isReturned ? TextDecoration.lineThrough : null,
                                        decorationColor: isReturned ? colors.danger : null,
                                        decorationThickness: 2.0,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
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
                                  if (isLend) ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Principal Amount', style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg)),
                                        Text(rupees((lend != null && lend.principal > 0) ? lend.principal : sale.total), style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    if ((lend?.charge ?? 0) > 0) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Surcharge Interest', style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg)),
                                          Text('+ ${rupees(lend!.charge)}', style: AppTypography.bodyMedium.copyWith(color: Colors.orange, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ],
                                    const Divider(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total Loan Amount', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                        Text(rupees(sale.total), style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.orange)),
                                      ],
                                    ),
                                    if (sale.advance > 0) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Upfront Payment', style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg)),
                                          Text('- ${rupees(sale.advance)}', style: AppTypography.bodyMedium.copyWith(color: colors.success, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Financed Outstanding', style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg)),
                                        Text('+ ${rupees(sale.creditAdded)}', style: AppTypography.bodyMedium.copyWith(color: colors.danger, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ] else ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Items Total', style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg)),
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
                                        Text('Grand Total', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                        Text(rupees(itemsTotal + creditCharge), style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: colors.primary)),
                                      ],
                                    ),
                                    if (returnedTotal > 0) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                margin: const EdgeInsets.only(right: 6),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFDE047),
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                              Text('Returned Product Deduction', style: AppTypography.bodyMedium.copyWith(color: const Color(0xFF854D0E), fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                          Text('- ${rupees(returnedTotal)}', style: AppTypography.bodyMedium.copyWith(color: const Color(0xFF854D0E), fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Net Sale Total', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                          Text(rupees((itemsTotal + creditCharge - returnedTotal).clamp(0, 9999999)), style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: colors.primary)),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Down Payment', style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg)),
                                        Text('- ${rupees(sale.advance)}', style: AppTypography.bodyMedium.copyWith(color: colors.success, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    if (isCredit) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Financed Outstanding', style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg)),
                                          Text('+ ${rupees(sale.creditAdded)}', style: AppTypography.bodyMedium.copyWith(color: colors.danger, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
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
                        amount: widget.outstanding.totalFinanced,
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
                        amount: widget.outstanding.totalCollected,
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AmountText(
                  amount: widget.outstanding.outstandingAmount,
                  style: AppTypography.currencyLarge.copyWith(
                    color: widget.outstanding.outstandingAmount > 0 ? colors.danger : colors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RETURNED CREDIT',
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.success,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AmountText(
                  amount: widget.customer.credit,
                  style: AppTypography.currencyLarge.copyWith(
                    color: colors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '  • Product Sale Outstanding',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.mutedFg,
                  ),
                ),
                AmountText(
                  amount: widget.outstanding.saleOutstanding,
                  style: AppTypography.currencySmall.copyWith(
                    color: widget.outstanding.saleOutstanding > 0 ? colors.danger : colors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '  • Cash Loan / Lend Outstanding',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.mutedFg,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                AmountText(
                  amount: widget.outstanding.lendOutstanding,
                  style: AppTypography.currencySmall.copyWith(
                    color: widget.outstanding.lendOutstanding > 0 ? Colors.orange : colors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            
            // Purchase Summary Title
            Text(
              'Purchase Summary',
              style: AppTypography.titleSmall.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            if (widget.groupedSales.isEmpty)
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
              Builder(
                builder: (context) {
                  final currentYear = DateTime.now().year;
                  final yearsSet = <int>{currentYear, _selectedYear};
                  for (final g in widget.groupedSales) {
                    yearsSet.add(g.date.year);
                  }
                  for (int i = 0; i < 5; i++) {
                    yearsSet.add(currentYear - i);
                  }
                  final years = yearsSet.toList()..sort((a, b) => b.compareTo(a));

                  final salesMap = {
                    for (var g in widget.groupedSales)
                      DateTime(g.date.year, g.date.month, g.date.day): g
                  };

                  // Calendar math for grid columns
                  final firstOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
                  final startMonday = firstOfMonth.subtract(Duration(days: firstOfMonth.weekday - 1));
                  final lastOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0);
                  final totalDaysSpan = lastOfMonth.difference(startMonday).inDays + 1;
                  final numWeeks = (totalDaysSpan / 7.0).ceil();

                  // Filtered sales of selected month/year
                  final monthEvents = widget.groupedSales.where((g) {
                    return g.date.year == _selectedYear && g.date.month == _selectedMonth;
                  }).toList();
                  monthEvents.sort((a, b) => b.date.compareTo(a.date)); // Newest first

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column: Scrollable 12 Months with 5 displayed at a time
                          SizedBox(
                            width: 52,
                            height: 170,
                            child: ListView.builder(
                              controller: _monthScrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: 12,
                              itemBuilder: (context, index) {
                                final month = index + 1; // 1 to 12 (Jan to Dec)
                                final monthName = DateFormat('MMM').format(DateTime(_selectedYear, month, 1));
                                final isSelected = month == _selectedMonth;
                                final isLast = index == 11;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: isLast ? 0 : 5.0),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedMonth = month),
                                    child: Container(
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected ? colors.primary.withValues(alpha: 0.15) : colors.surface,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected ? colors.primary : colors.border.withValues(alpha: 0.8),
                                          width: isSelected ? 1.5 : 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        monthName,
                                        style: AppTypography.labelSmall.copyWith(
                                          color: isSelected ? colors.primary : colors.foreground,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 8.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Right Column: Main area (Dropdown, Grid)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Year Dropdown alignment row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Activity Calendar',
                                      style: AppTypography.labelSmall.copyWith(color: colors.mutedFg, fontSize: 8),
                                    ),
                                    // Year Filter Dropdown
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: colors.surface,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: colors.border.withValues(alpha: 0.4)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _selectedYear,
                                          isDense: true,
                                          icon: Icon(Icons.arrow_drop_down, color: colors.primary, size: 14),
                                          style: AppTypography.labelSmall.copyWith(
                                            color: colors.foreground,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 8.5,
                                          ),
                                          dropdownColor: colors.surface,
                                          onChanged: (year) {
                                            if (year != null) {
                                              setState(() {
                                                _selectedYear = year;
                                                final targetMonth = year == DateTime.now().year ? DateTime.now().month : 1;
                                                _selectedMonth = targetMonth;
                                                final targetIndex = targetMonth - 1;
                                                if (_monthScrollController.hasClients) {
                                                  _monthScrollController.jumpTo(targetIndex * 35.0);
                                                }
                                              });
                                            }
                                          },
                                          items: years.map((year) {
                                            return DropdownMenuItem<int>(
                                              value: year,
                                              child: Text('$year'),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // GitHub Blank Contribution Grid (Mon-Sun rows)
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(color: colors.border.withValues(alpha: 0.9), width: 1.2),
                                  ),
                                  child: Row(
                                    children: [
                                      // Y-Axis Weekday Labels
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildWeekdayLabel('Mon', colors),
                                          const SizedBox(height: 16),
                                          _buildWeekdayLabel('Wed', colors),
                                          const SizedBox(height: 16),
                                          _buildWeekdayLabel('Fri', colors),
                                          const SizedBox(height: 16),
                                          _buildWeekdayLabel('Sun', colors),
                                        ],
                                      ),
                                      const SizedBox(width: 8),

                                      // Weeks Grid Columns
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          physics: const BouncingScrollPhysics(),
                                          child: Row(
                                            children: List.generate(numWeeks, (weekIdx) {
                                              final columnMonday = startMonday.add(Duration(days: weekIdx * 7));
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                                child: Column(
                                                  children: List.generate(7, (dayIdx) {
                                                    final cellDate = columnMonday.add(Duration(days: dayIdx));
                                                    final isCurrentMonth = cellDate.month == _selectedMonth;
                                                    
                                                    if (!isCurrentMonth) {
                                                      // Render transparent placeholder outside selected month dates
                                                      return Container(width: 12, height: 12, margin: const EdgeInsets.all(2));
                                                    }

                                                    final daySales = salesMap[cellDate];
                                                    final hasSales = daySales != null;

                                                    Widget cellContent;
                                                    if (!hasSales) {
                                                      cellContent = Container(
                                                        width: 12,
                                                        height: 12,
                                                        margin: const EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                          color: colors.muted.withValues(alpha: 0.6),
                                                          borderRadius: BorderRadius.circular(2),
                                                          border: Border.all(
                                                            color: colors.border.withValues(alpha: 0.8),
                                                            width: 0.75,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      final hasReady = daySales.sales.any((s) => s.saleType.toUpperCase() == 'READY' && s.items.any((it) => it.status != 'returned'));
                                                      final hasCredit = daySales.sales.any((s) => s.saleType.toUpperCase() == 'CREDIT' && s.items.any((it) => it.status != 'returned'));
                                                      final hasLend = daySales.sales.any((s) => s.saleType.toUpperCase() == 'LEND');
                                                      final hasReturned = daySales.sales.any((s) => s.items.any((it) => it.status == 'returned'));

                                                      final List<Color> activeColors = [];
                                                      if (hasReady) activeColors.add(colors.success);
                                                      if (hasCredit) activeColors.add(colors.danger);
                                                      if (hasLend) activeColors.add(Colors.orange);
                                                      if (hasReturned) activeColors.add(const Color(0xFFFDE047));

                                                      if (activeColors.isEmpty) {
                                                        activeColors.add(colors.success);
                                                      }

                                                      cellContent = Container(
                                                        width: 12,
                                                        height: 12,
                                                        margin: const EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(2),
                                                        ),
                                                        clipBehavior: Clip.antiAlias,
                                                        child: Row(
                                                          children: activeColors
                                                              .map((c) => Expanded(child: Container(color: c)))
                                                              .toList(),
                                                        ),
                                                      );
                                                    }

                                                    return GestureDetector(
                                                      onTap: () {
                                                        if (hasSales) {
                                                          _showFinancialsSheet(context, daySales, colors);
                                                        }
                                                      },
                                                      child: cellContent,
                                                    );
                                                  }),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Grid Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(colors.success, 'Ready Sale', colors),
                          const SizedBox(width: 8),
                          _buildLegendItem(colors.danger, 'Credit Sale', colors),
                          const SizedBox(width: 8),
                          _buildLegendItem(Colors.orange, 'Lend', colors),
                          const SizedBox(width: 8),
                          _buildLegendItem(const Color(0xFFFDE047), 'Return', colors),
                          const SizedBox(width: 8),
                          _buildLegendItem(
                            colors.muted.withValues(alpha: 0.6),
                            'No Sale',
                            colors,
                            borderColor: colors.border.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Section Title: Events chips list
                      Text(
                        'Monthly Events (${monthEvents.length})',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.bold,
                          fontSize: 8.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (monthEvents.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.surface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: colors.border.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            'No sales recorded in this month.',
                            style: AppTypography.bodySmall.copyWith(color: colors.mutedFg),
                          ),
                        )
                      else
                        // Event record cards: outlined, bold date, and single hr line between date and badges
                        ...monthEvents.map((grouped) {
                          final hasReady = grouped.sales.any((s) => s.saleType.toUpperCase() == 'READY' && s.items.any((it) => it.status != 'returned'));
                          final hasCredit = grouped.sales.any((s) => s.saleType.toUpperCase() == 'CREDIT' && s.items.any((it) => it.status != 'returned'));
                          final hasLend = grouped.sales.any((s) => s.saleType.toUpperCase() == 'LEND');
                          final hasReturned = grouped.sales.any((s) => s.items.any((it) => it.status == 'returned'));

                          return GestureDetector(
                            onTap: () => _showFinancialsSheet(context, grouped, colors),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colors.border.withValues(alpha: 0.7), width: 1.0),
                              ),
                              child: Row(
                                children: [
                                  // Bold Date Text
                                  Text(
                                    DateFormat('dd MMM').format(grouped.date),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: colors.foreground,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Single HR line between date and badges only
                                  Container(
                                    height: 12,
                                    width: 1,
                                    color: colors.border.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 8),

                                  // Type badges with color (side-by-side, no dividers between badges)
                                  if (hasReady)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: colors.success.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: colors.success.withValues(alpha: 0.5), width: 0.75),
                                      ),
                                      child: Text(
                                        'Ready',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: colors.success,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (hasCredit) ...[
                                    if (hasReady) const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: colors.danger.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: colors.danger.withValues(alpha: 0.5), width: 0.75),
                                      ),
                                      child: Text(
                                        'Credit',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: colors.danger,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (hasLend) ...[
                                    if (hasReady || hasCredit) const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 0.75),
                                      ),
                                      child: Text(
                                        'Lend',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: Colors.orange,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (hasReturned) ...[
                                    if (hasReady || hasCredit || hasLend) const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFDE047).withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFFFDE047), width: 0.8),
                                      ),
                                      child: Text(
                                        'Return',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: const Color(0xFF854D0E),
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],

                                  const Spacer(),

                                  // Total sum amount
                                  Text(
                                    rupees(grouped.sales.fold<int>(0, (sum, s) => sum + s.total)),
                                    style: AppTypography.labelMedium.copyWith(
                                      color: colors.foreground,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  );
                },
              ),
          ],
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
