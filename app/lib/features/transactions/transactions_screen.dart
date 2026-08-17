import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/error_state.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/customer.dart';
import '../../data/providers.dart';
import 'models/transaction_item.dart';
import 'widgets/transaction_card.dart';
import 'widgets/custom_date_range_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = GoRouterState.of(context).uri;
    final q = uri.queryParameters['q'] ?? '';
    if (_searchController.text != q) {
      _searchController.text = q;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilters({String? kind, String? range, String? q}) {
    final uri = GoRouterState.of(context).uri;
    final newParams = Map<String, String>.from(uri.queryParameters);

    if (kind != null) newParams['kind'] = kind;
    if (range != null) newParams['range'] = range;
    if (q != null) newParams['q'] = q;

    if (newParams['kind'] == 'All') newParams.remove('kind');
    if (newParams['range'] == 'Today') newParams.remove('range');
    if (newParams['q'] == '') newParams.remove('q');

    final newUri = uri.replace(queryParameters: newParams);
    context.go(newUri.toString());
  }

  void _showFiltersSheet(BuildContext context, String currentRange) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        String tempRange = currentRange;
        DateTime? tempStartDate = _selectedDateRange?.start;
        DateTime? tempEndDate = _selectedDateRange?.end;

        final now = DateTime.now();
        if (tempStartDate == null) {
          if (tempRange == 'Today') {
            tempStartDate = DateTime(now.year, now.month, now.day);
            tempEndDate = tempStartDate;
          } else if (tempRange == 'This week') {
            tempStartDate = now.subtract(Duration(days: now.weekday - 1));
            tempEndDate = DateTime(now.year, now.month, now.day);
          } else if (tempRange == 'This month') {
            tempStartDate = DateTime(now.year, now.month, 1);
            tempEndDate = DateTime(now.year, now.month, DateUtils.getDaysInMonth(now.year, now.month));
          }
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            final colors = context.colors;
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: AppSpacing.md,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.border.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Sheet Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Transactions',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedDateRange = null;
                            });
                            _updateFilters(range: 'Today', kind: 'All');
                            context.pop();
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    Divider(height: 1, color: colors.border.withValues(alpha: 0.6)),
                    const SizedBox(height: AppSpacing.sm),

                    // Quick Date Range Presets
                    Text(
                      'Quick Presets',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: ['Today', 'This week', 'This month'].map((range) {
                        final isSelected = tempRange == range;
                        return FilterChip(
                          label: Text(range),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                tempRange = range;
                                if (range == 'Today') {
                                  tempStartDate = DateTime(now.year, now.month, now.day);
                                  tempEndDate = tempStartDate;
                                } else if (range == 'This week') {
                                  tempStartDate = now.subtract(Duration(days: now.weekday - 1));
                                  tempEndDate = DateTime(now.year, now.month, now.day);
                                } else if (range == 'This month') {
                                  tempStartDate = DateTime(now.year, now.month, 1);
                                  tempEndDate = DateTime(now.year, now.month, DateUtils.getDaysInMonth(now.year, now.month));
                                }
                              });
                            }
                          },
                          backgroundColor: colors.surface,
                          selectedColor: colors.primary.withValues(alpha: 0.15),
                          checkmarkColor: colors.primary,
                          side: BorderSide(
                            color: isSelected ? colors.primary : colors.border,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? colors.primary : colors.foreground,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Embedded Interactive Date Range Picker
                    CustomDateRangePicker(
                      startDate: tempStartDate,
                      endDate: tempEndDate,
                      onRangeChanged: (start, end) {
                        setModalState(() {
                          tempStartDate = start;
                          tempEndDate = end;
                          tempRange = 'Custom...';
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Bottom Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: colors.foreground),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: () {
                              if (tempRange == 'Today' || tempRange == 'This week' || tempRange == 'This month') {
                                setState(() {
                                  _selectedDateRange = null;
                                });
                                _updateFilters(range: tempRange);
                              } else if (tempStartDate != null) {
                                final start = tempStartDate!;
                                final end = tempEndDate ?? tempStartDate!;
                                setState(() {
                                  _selectedDateRange = DateTimeRange(start: start, end: end);
                                });
                                _updateFilters(range: 'Custom...');
                              }
                              context.pop();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.primaryFg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rawSafeAreaBottom = MediaQueryData.fromView(View.of(context)).padding.bottom;
    final uri = GoRouterState.of(context).uri;
    final kindParam = uri.queryParameters['kind'] ?? 'All';
    final rangeParam = uri.queryParameters['range'] ?? 'Today';

    final customersAsync = ref.watch(customersStreamProvider);
    final salesAsync = ref.watch(salesStreamProvider);
    final collectionsAsync = ref.watch(collectionsStreamProvider);

    if (customersAsync.isLoading ||
        salesAsync.isLoading ||
        collectionsAsync.isLoading) {
      return AppScaffold(
        blendHeader: true,
        title: Text(
          'Transactions',
          style:
              AppTypography.headlineMedium.copyWith(color: colors.foreground),
        ),
        body: const SkeletonList(),
      );
    }

    if (customersAsync.hasError || salesAsync.hasError || collectionsAsync.hasError) {
      final error = customersAsync.error ?? salesAsync.error ?? collectionsAsync.error;
      return AppScaffold(
        blendHeader: true,
        title: Text(
          'Transactions',
          style:
              AppTypography.headlineMedium.copyWith(color: colors.foreground),
        ),
        body: ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(customersStreamProvider);
            ref.invalidate(salesStreamProvider);
            ref.invalidate(collectionsStreamProvider);
          },
        ),
      );
    }

    final customers = customersAsync.value ?? [];
    final sales = salesAsync.value ?? [];
    final collections = collectionsAsync.value ?? [];

    String getCustomerName(String id) {
      final c = customers.firstWhere((c) => c.id == id,
          orElse: () => Customer(
                id: id,
                customerCode: 'Unknown',
                name: 'Unknown Client',
                phone: '',
                address: '',
                weekdayId: '',
                placeId: '',
                areaId: '',
                status: 'ACTIVE',
              ));
      return c.name;
    }

    Customer? getCustomer(String id) {
      try {
        return customers.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    }

    final List<TransactionItem> allItems = [];

    for (final s in sales) {
      final isLend = s.saleType == 'LEND' || (s.remarks != null && s.remarks!.startsWith('LEND_DETAILS:'));
      final formattedRemarks = isLend
          ? LendDetails.parse(s.remarks ?? '').toSimpleInfo()
          : (s.remarks ?? '');

      allItems.add(TransactionItem(
        id: s.id,
        customerId: s.customerId,
        customerName: getCustomerName(s.customerId),
        customer: getCustomer(s.customerId),
        date: s.saleDatetime,
        type: 'SALE',
        status: isLend ? 'LEND' : s.saleType,
        amount: s.totalAmount,
        subtitle: isLend
            ? 'Cash Loan / Lend'
            : (s.saleType == 'CREDIT'
                ? 'Credit Sale · Financed ₹${s.financedAmount}'
                : 'Ready Sale'),
        remarks: formattedRemarks,
      ));
    }

    for (final c in collections) {
      final col = CollectionDetails.parse(c.reason);
      final isLend = col.target == 'LEND';
      allItems.add(TransactionItem(
        id: c.id,
        customerId: c.customerId,
        customerName: getCustomerName(c.customerId),
        customer: getCustomer(c.customerId),
        date: c.visitDatetime,
        type: 'COLLECTION',
        status: isLend ? 'LEND_COLLECTION' : c.status,
        amount: c.amount.round(),
        subtitle: isLend
            ? (c.status == 'PAYMENT'
                ? 'Loan Repayment'
                : (c.status == 'PARTIAL_PAYMENT'
                    ? 'Loan Partial Repayment'
                    : 'Loan Carry Forward'))
            : (c.status == 'PAYMENT'
                ? 'Full Payment'
                : (c.status == 'PARTIAL_PAYMENT'
                    ? 'Partial Payment'
                    : 'Carry Forward')),
        remarks: col.note,
      ));
    }

    allItems.sort((a, b) => b.date.compareTo(a.date));

    // Filter by search query
    var filtered = allItems;
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((item) {
        return item.customerName.toLowerCase().contains(query) ||
            item.subtitle.toLowerCase().contains(query) ||
            item.remarks.toLowerCase().contains(query) ||
            item.amount.toString().contains(query);
      }).toList();
    }

    if (kindParam == 'Payments') {
      filtered = filtered
          .where((item) =>
              item.type == 'COLLECTION' &&
              (item.status == 'PAYMENT' || item.status == 'PARTIAL_PAYMENT' || item.status == 'LEND_COLLECTION'))
          .toList();
    } else if (kindParam == 'Lends') {
      filtered = filtered
          .where((item) =>
              item.status == 'LEND' || item.status == 'LEND_COLLECTION')
          .toList();
    } else if (kindParam == 'Partial') {
      filtered = filtered
          .where((item) =>
              item.type == 'COLLECTION' && item.status == 'PARTIAL_PAYMENT')
          .toList();
    } else if (kindParam == 'Carry-forward') {
      filtered = filtered
          .where((item) =>
              item.type == 'COLLECTION' && item.status == 'CARRY_FORWARD')
          .toList();
    } else if (kindParam == 'Sales') {
      filtered = filtered.where((item) => item.type == 'SALE' && item.status != 'LEND').toList();
    }

    // Filter by date range
    final now = DateTime.now();
    if (rangeParam == 'Today') {
      filtered = filtered.where((item) => isToday(item.date)).toList();
    } else if (rangeParam == 'This week') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfDay =
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      filtered =
          filtered.where((item) => item.date.isAfter(startOfDay)).toList();
    } else if (rangeParam == 'This month') {
      filtered = filtered
          .where((item) =>
              item.date.year == now.year && item.date.month == now.month)
          .toList();
    } else if (rangeParam == 'Custom...' && _selectedDateRange != null) {
      filtered = filtered
          .where((item) =>
              item.date.isAfter(_selectedDateRange!.start
                  .subtract(const Duration(days: 1))) &&
              item.date.isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1))))
          .toList();
    }

    final totalSales = filtered
        .where((item) => item.type == 'SALE')
        .fold<int>(0, (sum, item) => sum + item.amount);

    final totalCollected = filtered
        .where((item) =>
            item.type == 'COLLECTION' && item.status != 'CARRY_FORWARD')
        .fold<int>(0, (sum, item) => sum + item.amount);

    return AppScaffold(
      blendHeader: true,
      title: Text(
        'Transactions',
        style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
      ),
      body: Column(
        children: [
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: colors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up_rounded,
                                color: colors.primary, size: 20),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Sales',
                              style: AppTypography.labelMedium
                                  .copyWith(color: colors.mutedFg),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          rupees(totalSales),
                          style: AppTypography.currencyMedium
                              .copyWith(color: colors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: colors.success.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                color: colors.success, size: 20),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Collected',
                              style: AppTypography.labelMedium
                                  .copyWith(color: colors.mutedFg),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          rupees(totalCollected),
                          style: AppTypography.currencyMedium
                              .copyWith(color: colors.success),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search customer, note, or product...',
                prefixIcon: Icon(Icons.search, color: colors.mutedFg),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, color: colors.mutedFg),
                        onPressed: () {
                          _searchController.clear();
                          _updateFilters(q: '');
                          setState(() {});
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.filter_list_rounded,
                        color:
                            rangeParam != 'Today' || _selectedDateRange != null
                                ? colors.primary
                                : colors.mutedFg,
                      ),
                      onPressed: () => _showFiltersSheet(context, rangeParam),
                    ),
                  ],
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: ['All', 'Sales', 'Payments', 'Lends', 'Partial', 'Carry-forward']
                  .map((kind) {
                final isSelected = kindParam == kind;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(kind),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _updateFilters(kind: kind);
                    },
                    backgroundColor: colors.surface,
                    selectedColor: colors.primary.withValues(alpha: 0.15),
                    checkmarkColor: colors.primary,
                    side: BorderSide(
                      color: isSelected ? colors.primary : colors.border,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? colors.primary : colors.mutedFg,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // List or Empty State
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(salesStreamProvider);
                ref.invalidate(collectionsStreamProvider);
                ref.invalidate(customersStreamProvider);
                try {
                  await ref.read(salesStreamProvider.future);
                } catch (_) {}
              },
              color: colors.primary,
              child: filtered.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: ClampingScrollPhysics()),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: AppSpacing.md,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 56, color: colors.mutedFg),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No transactions match these filters.',
                              style: AppTypography.bodyLarge.copyWith(
                                  color: colors.foreground,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Try cleaning up search or active filters.',
                              style: AppTypography.bodySmall
                                  .copyWith(color: colors.mutedFg),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            OutlinedButton(
                              onPressed: () {
                                _searchController.clear();
                                _selectedDateRange = null;
                                _updateFilters(
                                    kind: 'All', range: 'Today', q: '');
                              },
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics()),
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      88.0 + rawSafeAreaBottom,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return TransactionCard(
                        item: filtered[index],
                        colors: colors,
                      );
                    },
                  ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
