import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/router/routes.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

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

    final newUri =
        uri.replace(queryParameters: newParams.isEmpty ? null : newParams);
    context.go(newUri.toString());
  }

  void _showFiltersSheet(BuildContext context, String currentRange) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                              setState(() => tempRange = range);
                            }
                          },
                          backgroundColor: colors.surface,
                          selectedColor: colors.primary.withOpacity(0.1),
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
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
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
    final hasActiveFilters = kindParam != 'All' ||
        rangeParam != 'Today' ||
        _searchController.text.isNotEmpty;

    // Dummy logic for empty state demonstration
    final showEmpty = hasActiveFilters &&
        kindParam == 'Carry-forward'; // Just to show empty state

    return AppScaffold(
      title: Text(
        'Transactions',
        style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onSubmitted: (val) => _updateFilters(q: val),
              decoration: InputDecoration(
                hintText: 'Search customer, note, or product...',
                prefixIcon: Icon(Icons.search, color: colors.mutedFg),
                suffixIcon: IconButton(
                  icon: Icon(Icons.tune, color: colors.primary),
                  onPressed: () => _showFiltersSheet(context, rangeParam),
                ),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
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
              children: ['All', 'Payments', 'Partial', 'Carry-forward', 'Sales']
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
                    selectedColor: colors.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? colors.primary : colors.foreground,
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
            child: showEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: colors.mutedFg),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No transactions match these filters.',
                            style: AppTypography.bodyLarge
                                .copyWith(color: colors.foreground),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
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
                    itemCount: 5,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final isSale = index % 3 == 0;
                      final isPartial = index % 3 == 1;
                      final amount = isSale
                          ? '₹14,500'
                          : (isPartial ? '₹2,000' : '₹5,000');

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSale
                              ? colors.primary.withOpacity(0.1)
                              : (isPartial
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1)),
                          child: Icon(
                            isSale ? Icons.shopping_cart : Icons.payments,
                            color: isSale
                                ? colors.primary
                                : (isPartial ? Colors.orange : Colors.green),
                          ),
                        ),
                        title: const Text('Lakshmi Priya',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isSale
                                ? 'Credit sale · 2 items · +₹14,500'
                                : (isPartial
                                    ? 'Partial Payment · North St, Melur'
                                    : 'Payment · North St, Melur')),
                            const SizedBox(height: 4),
                            Text(
                              index == 0 ? '2h ago' : 'Yesterday',
                              style: AppTypography.bodySmall
                                  .copyWith(color: colors.mutedFg),
                            ),
                          ],
                        ),
                        trailing: Text(
                          amount,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                        onTap: () {
                          // Deep link to customer timeline
                        },
                      );
                    },
                  ),
          ),

          // Bottom padding for nav
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
