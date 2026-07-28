import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/utils/formatters.dart';
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
  });

  final Outstanding outstanding;
  final List<GroupedSales> groupedSales;

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

    // Standard Jan-Dec list index for current month is now.month - 1.
    // Item height is ~36.0. Set initial offset to scroll current month to top.
    final initialOffset = (now.month - 1) * 36.0;
    _monthScrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    super.dispose();
  }

  Widget _buildLegendItem(Color color, String label, AppColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
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
                      final isCredit = sale.saleType.toUpperCase() == 'CREDIT';
                      final badgeColor = isCredit ? colors.danger : colors.success;
                      
                      final itemsTotal = sale.items.fold<int>(0, (sum, item) => sum + item.quantity * item.unitPrice);
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
                          // Products list
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
                                      Text(rupees(sale.total), style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: colors.primary)),
                                    ],
                                  ),
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
                  final years = List.generate(5, (index) => currentYear - index);

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
                          // Left column: Months Vertical Scroll Filter
                          // Left column: Months Vertical Scroll Filter
                          SizedBox(
                            width: 52,
                            height: 172,
                            child: ListView.builder(
                              controller: _monthScrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: 12,
                              itemBuilder: (context, index) {
                                final month = index + 1;
                                final monthName = DateFormat('MMM').format(DateTime(_selectedYear, month, 1));
                                final isSelected = month == _selectedMonth;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedMonth = month),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected ? colors.primary.withValues(alpha: 0.12) : colors.surface,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected ? colors.primary : colors.border.withValues(alpha: 0.3),
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
                                            if (year != null) setState(() => _selectedYear = year);
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
                                    border: Border.all(color: colors.border.withValues(alpha: 0.5)),
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

                                                    Color cellColor = colors.border.withValues(alpha: 0.12);
                                                    if (hasSales) {
                                                      final hasCredit = daySales.sales.any((s) => s.saleType.toUpperCase() == 'CREDIT');
                                                      cellColor = hasCredit ? colors.danger : colors.success;
                                                    }

                                                    return GestureDetector(
                                                      onTap: () {
                                                        if (hasSales) {
                                                          _showFinancialsSheet(context, daySales, colors);
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 12,
                                                        height: 12,
                                                        margin: const EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                          color: cellColor,
                                                          borderRadius: BorderRadius.circular(2),
                                                          border: Border.all(
                                                            color: hasSales ? Colors.transparent : colors.border.withValues(alpha: 0.1),
                                                            width: 0.5,
                                                          ),
                                                        ),
                                                      ),
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
                          const SizedBox(width: 16),
                          _buildLegendItem(colors.danger, 'Credit Sale', colors),
                          const SizedBox(width: 16),
                          _buildLegendItem(colors.border.withValues(alpha: 0.25), 'No Sale', colors),
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
                        // Event chips horizontal/vertical list
                        ...monthEvents.map((grouped) {
                          return GestureDetector(
                            onTap: () => _showFinancialsSheet(context, grouped, colors),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: colors.border.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  // Date Chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colors.border.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      DateFormat('dd MMM').format(grouped.date),
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.foreground,
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Indicator dot
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: grouped.saleType.toUpperCase() == 'CREDIT'
                                          ? colors.danger
                                          : colors.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Items text
                                  Expanded(
                                    child: Text(
                                      grouped.sales.expand((s) => s.items).map((i) => i.productName).join(', '),
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.foreground.withValues(alpha: 0.8),
                                        fontSize: 8,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Total amount
                                  Text(
                                    rupees(grouped.sales.fold<int>(0, (sum, s) => sum + s.total)),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: colors.foreground,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
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
