import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/router/routes.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/customer.dart';
import '../../data/providers.dart';

class TransactionItem {
  final String id;
  final String customerId;
  final String customerName;
  final Customer? customer;
  final DateTime date;
  final String type; // 'SALE' or 'COLLECTION'
  final String
      status; // 'READY', 'CREDIT', 'PAYMENT', 'PARTIAL_PAYMENT', 'CARRY_FORWARD'
  final int amount;
  final String subtitle;
  final String remarks;

  TransactionItem({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customer,
    required this.date,
    required this.type,
    required this.status,
    required this.amount,
    required this.subtitle,
    required this.remarks,
  });
}

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

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        final colors = context.colors;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primary,
              onPrimary: colors.primaryFg,
              surface: colors.surface,
              onSurface: colors.foreground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _updateFilters(range: 'Custom...');
    }
  }

  void _showFiltersSheet(BuildContext context, String currentRange) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      builder: (BuildContext sheetContext) {
        String tempRange = currentRange;
        return StatefulBuilder(
          builder: (context, setState) {
            final colors = context.colors;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filters',
                      style: AppTypography.headlineMedium
                          .copyWith(color: colors.foreground),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Date range',
                      style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.foreground),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        'Today',
                        'This week',
                        'This month',
                        'Custom...'
                      ].map((range) {
                        final isSelected = tempRange == range;
                        return FilterChip(
                          label: Text(range),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              if (range == 'Custom...') {
                                _selectCustomDateRange(context).then((_) {
                                  if (_selectedDateRange != null) {
                                    setState(() => tempRange = 'Custom...');
                                  }
                                });
                              } else {
                                setState(() => tempRange = range);
                              }
                            }
                          },
                          backgroundColor: colors.surface,
                          selectedColor: colors.primary.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color:
                                isSelected ? colors.primary : colors.foreground,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    if (tempRange == 'Custom...' &&
                        _selectedDateRange != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Selected: ${dateShort(_selectedDateRange!.start)} - ${dateShort(_selectedDateRange!.end)}',
                        style: AppTypography.bodySmall.copyWith(
                            color: colors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              _selectedDateRange = null;
                              _updateFilters(range: 'Today', kind: 'All');
                              context.pop();
                            },
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _updateFilters(range: tempRange);
                              context.pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.primaryFg,
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Apply'),
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
        body: const Center(child: CircularProgressIndicator()),
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
                sequenceNumber: 0,
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
      allItems.add(TransactionItem(
        id: s.id,
        customerId: s.customerId,
        customerName: getCustomerName(s.customerId),
        customer: getCustomer(s.customerId),
        date: s.saleDatetime,
        type: 'SALE',
        status: s.saleType,
        amount: s.totalAmount,
        subtitle: s.saleType == 'CREDIT'
            ? 'Credit Sale · Financed ₹${s.financedAmount}'
            : 'Ready Sale',
        remarks: s.remarks ?? '',
      ));
    }

    for (final c in collections) {
      allItems.add(TransactionItem(
        id: c.id,
        customerId: c.customerId,
        customerName: getCustomerName(c.customerId),
        customer: getCustomer(c.customerId),
        date: c.visitDatetime,
        type: 'COLLECTION',
        status: c.status,
        amount: c.amount,
        subtitle: c.status == 'PAYMENT'
            ? 'Full Payment'
            : (c.status == 'PARTIAL_PAYMENT'
                ? 'Partial Payment'
                : 'Carry Forward'),
        remarks: c.reason ?? '',
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

    // Filter by kind
    if (kindParam == 'Payments') {
      filtered = filtered
          .where((item) =>
              item.type == 'COLLECTION' &&
              (item.status == 'PAYMENT' || item.status == 'PARTIAL_PAYMENT'))
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
      filtered = filtered.where((item) => item.type == 'SALE').toList();
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
              children: ['All', 'Sales', 'Payments', 'Partial', 'Carry-forward']
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
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
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
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return _TransactionCard(
                        item: filtered[index],
                        colors: colors,
                      );
                    },
                  ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatefulWidget {
  final TransactionItem item;
  final AppColors colors;

  const _TransactionCard({
    required this.item,
    required this.colors,
  });

  @override
  State<_TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<_TransactionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final colors = widget.colors;
    final isSale = item.type == 'SALE';
    final isPartial = item.status == 'PARTIAL_PAYMENT';
    final isCarry = item.status == 'CARRY_FORWARD';

    Color statusBg;
    Color statusFg;
    IconData icon;

    if (isSale) {
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
              )}?source=transactions',
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
                            onTap: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
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
                          : (isSale ? colors.primary : colors.success),
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
                      isSale ? 'Sale' : (isCarry ? 'Carry-Fwd' : 'Payment'),
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
