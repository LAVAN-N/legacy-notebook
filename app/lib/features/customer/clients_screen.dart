import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/error_state.dart';
import '../../core/router/routes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/avatar.dart';
import '../../data/models/weekday.dart';
import '../../data/models/place.dart';
import '../../data/models/area.dart';
import '../../data/providers.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String? _selectedWeekday;
  String? _selectedPlace;
  String? _selectedArea;
  bool _isFabVisible = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final customersAsync = ref.watch(customersStreamProvider);
    final salesAsync = ref.watch(salesStreamProvider);
    final collectionsAsync = ref.watch(collectionsStreamProvider);
    final weekdaysAsync = ref.watch(weekdaysStreamProvider);
    final placesAsync = ref.watch(placesStreamProvider);
    final areasAsync = ref.watch(areasStreamProvider);

    if (customersAsync.isLoading ||
        salesAsync.isLoading ||
        collectionsAsync.isLoading) {
      return AppScaffold(
        blendHeader: true,
        title: Text('Clients',
            style: AppTypography.headlineMedium
                .copyWith(color: colors.foreground)),
        body: const SkeletonList(),
      );
    }

    if (customersAsync.hasError || salesAsync.hasError || collectionsAsync.hasError) {
      final error = customersAsync.error ?? salesAsync.error ?? collectionsAsync.error;
      return AppScaffold(
        blendHeader: true,
        title: Text('Clients',
            style: AppTypography.headlineMedium
                .copyWith(color: colors.foreground)),
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

    final allCustomers = customersAsync.value ?? [];
    final allSales = salesAsync.value ?? [];
    final allCollections = collectionsAsync.value ?? [];
    final allWeekdays = (weekdaysAsync.value ?? []).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final allPlaces = (placesAsync.value ?? []).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final allAreas = (areasAsync.value ?? []).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    // Helper to calculate total, lend, and sale outstanding
    int getOutstanding(String customerId) {
      final customerSales = allSales.where((s) => s.customerId == customerId);
      final customerCollections = allCollections.where((col) =>
          col.customerId == customerId &&
          (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT'));
      final totalFinanced =
          customerSales.fold<int>(0, (sum, s) => sum + s.financedAmount);
      final totalCollected =
          customerCollections.fold<int>(0, (sum, col) => sum + col.amount.round());
      return totalFinanced - totalCollected;
    }

    int getLendOutstanding(String customerId) {
      final customerSales = allSales.where((s) => s.customerId == customerId);
      final customerCollections = allCollections.where((col) =>
          col.customerId == customerId &&
          (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT'));

      final totalLendFinanced = customerSales
          .where((s) => s.saleType.toUpperCase() == 'LEND')
          .fold<int>(0, (sum, s) => sum + s.financedAmount);

      final totalLendCollected = customerCollections
          .where((c) => c.reason != null && c.reason!.startsWith('COLLECTION_TARGET:target=LEND'))
          .fold<int>(0, (sum, c) => sum + c.amount.round());

      return totalLendFinanced - totalLendCollected;
    }

    int getSaleOutstanding(String customerId) {
      final customerSales = allSales.where((s) => s.customerId == customerId);
      final customerCollections = allCollections.where((col) =>
          col.customerId == customerId &&
          (col.status == 'PAYMENT' || col.status == 'PARTIAL_PAYMENT'));

      final totalSaleFinanced = customerSales
          .where((s) => s.saleType.toUpperCase() != 'LEND')
          .fold<int>(0, (sum, s) => sum + s.financedAmount);

      final totalSaleCollected = customerCollections
          .where((c) => c.reason == null || !c.reason!.startsWith('COLLECTION_TARGET:target=LEND'))
          .fold<int>(0, (sum, c) => sum + c.amount.round());

      return totalSaleFinanced - totalSaleCollected;
    }

    int getDisplayOutstanding(String customerId) {
      if (_selectedStatus == 'Outstanding') {
        return getSaleOutstanding(customerId);
      } else if (_selectedStatus == 'Lend') {
        return getLendOutstanding(customerId);
      } else if (_selectedStatus == 'Settled') {
        return 0;
      } else {
        return getOutstanding(customerId);
      }
    }

    // Filter logic
    final filtered = allCustomers.where((c) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = c.name.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          c.address.toLowerCase().contains(q);

      if (!matchesSearch) {
        return false;
      }

      // Status filter
      final totalOut = getOutstanding(c.id);
      final saleOut = getSaleOutstanding(c.id);
      final lendOut = getLendOutstanding(c.id);

      if (_selectedStatus == 'Outstanding' && saleOut <= 0) {
        return false;
      }
      if (_selectedStatus == 'Lend' && lendOut <= 0) {
        return false;
      }
      if (_selectedStatus == 'Settled' && totalOut > 0) {
        return false;
      }

      // Weekday filter
      if (_selectedWeekday != null && c.weekdayId != _selectedWeekday) {
        return false;
      }

      // Place filter
      if (_selectedPlace != null && c.placeId != _selectedPlace) {
        return false;
      }

      // Area filter
      if (_selectedArea != null && c.areaId != _selectedArea) {
        return false;
      }

      return true;
    }).toList();

    // Sort: Keep outstandings on top (descending by amount), settled at the bottom
    filtered.sort((a, b) {
      final outA = getDisplayOutstanding(a.id);
      final outB = getDisplayOutstanding(b.id);
      return outB.compareTo(outA);
    });

    // Dynamic stats based on filtered results
    int totalOutstanding = 0;
    for (final c in filtered) {
      final out = getDisplayOutstanding(c.id);
      if (out > 0) {
        totalOutstanding += out;
      }
    }

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final rawSafeAreaBottom = MediaQueryData.fromView(View.of(context)).padding.bottom;
    final statusOptions = ['All', 'Outstanding', 'Lend', 'Settled'];

    return AppScaffold(
      blendHeader: true,
      title: Text(
        'Clients',
        style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
      ),
      floatingActionButton: IgnorePointer(
        ignoring: !_isFabVisible,
        child: AnimatedScale(
          scale: _isFabVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: isKeyboardOpen ? 16.0 : 88.0 + rawSafeAreaBottom,
            ),
            child: Opacity(
              opacity: 0.85,
              child: FloatingActionButton(
                heroTag: 'clients_fab',
                onPressed: () => context.push(Routes.newClient),
                shape: const CircleBorder(),
                backgroundColor: colors.primary,
                foregroundColor: colors.primaryFg,
                child: const Icon(Icons.person_add_alt_1_rounded),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Clients',
                          style: AppTypography.labelMedium
                              .copyWith(color: colors.mutedFg),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${filtered.length}',
                          style: AppTypography.currencyMedium
                              .copyWith(color: colors.foreground),
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
                      color: (_selectedStatus == 'Lend' ? Colors.orange : (_selectedStatus == 'Settled' ? colors.success : colors.danger)).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: (_selectedStatus == 'Lend' ? Colors.orange : (_selectedStatus == 'Settled' ? colors.success : colors.danger)).withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _selectedStatus == 'Lend' ? Icons.handshake_outlined : (_selectedStatus == 'Outstanding' ? Icons.shopping_bag_outlined : (_selectedStatus == 'Settled' ? Icons.check_circle_outline : Icons.error_outline_rounded)),
                              color: _selectedStatus == 'Lend' ? Colors.orange : (_selectedStatus == 'Settled' ? colors.success : colors.danger),
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _selectedStatus == 'Lend' ? 'Lend Outstanding' : (_selectedStatus == 'Outstanding' ? 'Sale Outstanding' : (_selectedStatus == 'Settled' ? 'Settled Clients' : 'Outstanding')),
                              style: AppTypography.labelMedium
                                  .copyWith(color: colors.mutedFg),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _selectedStatus == 'Settled' ? '${filtered.length}' : rupees(totalOutstanding),
                          style: AppTypography.currencyMedium
                              .copyWith(color: _selectedStatus == 'Lend' ? Colors.orange : (_selectedStatus == 'Settled' ? colors.success : colors.danger)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or address...',
                prefixIcon: Icon(Icons.search, color: colors.mutedFg),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, color: colors.mutedFg),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.filter_list_rounded,
                        color: _selectedWeekday != null ||
                                _selectedPlace != null ||
                                _selectedArea != null ||
                                _selectedStatus != 'All'
                            ? colors.primary
                            : colors.mutedFg,
                      ),
                      onPressed: () => _showFiltersSheet(
                          context,
                          allWeekdays,
                          allPlaces,
                          allAreas),
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

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: statusOptions.map((status) {
                final isSelected = _selectedStatus == status;
                Color chipColor;
                if (status == 'Lend') {
                  chipColor = Colors.orange;
                } else if (status == 'Outstanding') {
                  chipColor = colors.danger;
                } else if (status == 'Settled') {
                  chipColor = colors.success;
                } else {
                  chipColor = colors.primary;
                }
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedStatus = status);
                    },
                    backgroundColor: colors.surface,
                    selectedColor: chipColor.withValues(alpha: 0.15),
                    checkmarkColor: chipColor,
                    side: BorderSide(
                      color: isSelected ? chipColor : colors.border,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? chipColor : colors.mutedFg,
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
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.reverse) {
                  if (_isFabVisible) setState(() => _isFabVisible = false);
                } else if (notification.direction == ScrollDirection.forward) {
                  if (!_isFabVisible) setState(() => _isFabVisible = true);
                }
                return false;
              },
              child: filtered.isEmpty
                ? SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: AppSpacing.md,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded,
                                size: 56, color: colors.mutedFg),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No clients found',
                              style: AppTypography.bodyLarge.copyWith(
                                color: colors.foreground,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Try adjusting your search or filters.',
                              style: AppTypography.bodySmall
                                  .copyWith(color: colors.mutedFg),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            OutlinedButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _selectedStatus = 'All';
                                  _selectedWeekday = null;
                                  _selectedPlace = null;
                                  _selectedArea = null;
                                });
                              },
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      16.0 + 88.0 + rawSafeAreaBottom,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      final displayOutstanding = getDisplayOutstanding(c.id);

                      // Calculate dynamic status label and colors
                      final totalOut = getOutstanding(c.id);
                      final lendOut = getLendOutstanding(c.id);
                      final saleOut = getSaleOutstanding(c.id);

                      String cardLabel;
                      Color cardColor;

                      if (_selectedStatus == 'Outstanding') {
                        cardLabel = 'Sale Pending';
                        cardColor = colors.danger;
                      } else if (_selectedStatus == 'Lend') {
                        cardLabel = 'Lend Pending';
                        cardColor = Colors.orange;
                      } else if (_selectedStatus == 'Settled') {
                        cardLabel = 'Settled';
                        cardColor = colors.success;
                      } else {
                        if (totalOut <= 0) {
                          cardLabel = 'Settled';
                          cardColor = colors.success;
                        } else {
                          if (saleOut > 0 && lendOut > 0) {
                            if (saleOut >= lendOut) {
                              cardLabel = 'Sale Pending';
                              cardColor = colors.danger;
                            } else {
                              cardLabel = 'Lend Pending';
                              cardColor = Colors.orange;
                            }
                          } else if (lendOut > 0) {
                            cardLabel = 'Lend Pending';
                            cardColor = Colors.orange;
                          } else {
                            cardLabel = 'Sale Pending';
                            cardColor = colors.danger;
                          }
                        }
                      }

                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        color: colors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: colors.border),
                        ),
                        child: InkWell(
                          onTap: () {
                            context.push(
                              '${Routes.customer(
                                c.weekdayId,
                                c.placeId,
                                c.areaId,
                                c.id,
                              )}?source=clients',
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Avatar(
                                      name: c.name,
                                      profileUrl: c.profileUrl,
                                      size: 48,
                                    ),
                                    if (displayOutstanding > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: cardColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: colors.surface,
                                                width: 2),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style:
                                            AppTypography.labelLarge.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: colors.foreground,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c.customerCode,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: colors.mutedFg,
                                        ),
                                      ),
                                      if (c.phone.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.phone_rounded,
                                                size: 12,
                                                color: colors.mutedFg),
                                            const SizedBox(width: 4),
                                            Text(
                                              c.phone,
                                              style: AppTypography.labelSmall
                                                  .copyWith(
                                                color: colors.mutedFg,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      rupees(displayOutstanding),
                                      style:
                                          AppTypography.currencySmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: displayOutstanding > 0 ? cardColor : colors.mutedFg,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: cardColor.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        cardLabel,
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          color: cardColor,
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
                    },
                  ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  void _showFiltersSheet(
    BuildContext context,
    List<Weekday> allWeekdays,
    List<Place> allPlaces,
    List<Area> allAreas,
  ) {
    final colors = context.colors;
    final statusOptions = ['All', 'Outstanding', 'Lend', 'Settled'];

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Dynamically calculate available places and areas based on current selections
            final visiblePlaces = _selectedWeekday == null
                ? allPlaces
                : allPlaces.where((p) => p.weekdayId == _selectedWeekday).toList();

            final visibleAreas = _selectedPlace != null
                ? allAreas.where((a) => a.placeId == _selectedPlace).toList()
                : (_selectedWeekday != null
                    ? () {
                        final pIds = visiblePlaces.map((p) => p.id).toSet();
                        return allAreas.where((a) => pIds.contains(a.placeId)).toList();
                      }()
                    : allAreas);

            return SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Clients',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedStatus = 'All';
                              _selectedWeekday = null;
                              _selectedPlace = null;
                              _selectedArea = null;
                            });
                            setModalState(() {});
                            context.pop();
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: AppSpacing.xs),

                    // Status Filter
                    Text(
                      'Status',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: statusOptions.map((status) {
                          final isSelected = _selectedStatus == status;
                          Color chipColor;
                          if (status == 'Lend') {
                            chipColor = Colors.orange;
                          } else if (status == 'Outstanding') {
                            chipColor = colors.danger;
                          } else if (status == 'Settled') {
                            chipColor = colors.success;
                          } else {
                            chipColor = colors.primary;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(status),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedStatus = status);
                                  setModalState(() {});
                                }
                              },
                              backgroundColor: colors.surface,
                              selectedColor:
                                  chipColor.withValues(alpha: 0.15),
                              checkmarkColor: chipColor,
                              side: BorderSide(
                                color: isSelected ? chipColor : colors.border,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected ? chipColor : colors.mutedFg,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Time-Picker Styled Route Filter (Weekday : Place : Area)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Route Filter',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                        if (_selectedWeekday != null || _selectedPlace != null || _selectedArea != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedWeekday = null;
                                _selectedPlace = null;
                                _selectedArea = null;
                              });
                              setModalState(() {});
                            },
                            child: Text(
                              'Clear route',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Header row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'WEEKDAY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: colors.mutedFg.withValues(alpha: 0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'PLACE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: colors.mutedFg.withValues(alpha: 0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AREA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: colors.mutedFg.withValues(alpha: 0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Time-Picker Style Wheels Container
                    Container(
                      height: 132,
                      decoration: BoxDecoration(
                        color: colors.muted.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                      ),
                      child: Stack(
                        children: [
                          // Central Selection Lens / Highlight Bar
                          Positioned(
                            top: 44,
                            left: 6,
                            right: 6,
                            height: 44,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: colors.primary.withValues(alpha: 0.25),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.foreground.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Subtle vertical separator dots between the 3 columns
                          Positioned(
                            top: 44 + 18,
                            left: 0,
                            right: 0,
                            child: Row(
                              children: [
                                const Spacer(flex: 1),
                                Container(
                                  width: 3,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colors.mutedFg.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const Spacer(flex: 1),
                                Container(
                                  width: 3,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colors.mutedFg.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const Spacer(flex: 1),
                              ],
                            ),
                          ),

                          // ShaderMask for fading top and bottom edges
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black,
                                  Colors.black,
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.22, 0.78, 1.0],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.dstIn,
                            child: Row(
                              children: [
                                // Column 1: Weekday
                                Expanded(
                                  child: _ScrollWheelColumn(
                                    items: [
                                      const _WheelItem(id: null, name: 'Any'),
                                      ...allWeekdays.map((w) => _WheelItem(id: w.id, name: w.name)),
                                    ],
                                    selectedIndex: _selectedWeekday == null
                                        ? 0
                                        : (allWeekdays.indexWhere((w) => w.id == _selectedWeekday) + 1).clamp(0, allWeekdays.length),
                                    onSelectedIndexChanged: (index) {
                                      final weekdayItems = [
                                        const _WheelItem(id: null, name: 'Any'),
                                        ...allWeekdays.map((w) => _WheelItem(id: w.id, name: w.name)),
                                      ];
                                      final wId = weekdayItems[index].id;
                                      setState(() {
                                        _selectedWeekday = wId;
                                        if (_selectedPlace != null && wId != null) {
                                          final currentPlace = allPlaces.firstWhere(
                                            (p) => p.id == _selectedPlace,
                                            orElse: () => const Place(id: '', weekdayId: '', name: ''),
                                          );
                                          if (currentPlace.weekdayId != wId) {
                                            _selectedPlace = null;
                                            _selectedArea = null;
                                          }
                                        }
                                      });
                                      setModalState(() {});
                                    },
                                    colors: colors,
                                  ),
                                ),

                                // Column 2: Place (dynamically loaded/filtered by Weekday)
                                Expanded(
                                  child: _ScrollWheelColumn(
                                    items: [
                                      const _WheelItem(id: null, name: 'Any'),
                                      ...visiblePlaces.map((p) => _WheelItem(id: p.id, name: p.name)),
                                    ],
                                    selectedIndex: _selectedPlace == null
                                        ? 0
                                        : (visiblePlaces.indexWhere((p) => p.id == _selectedPlace) + 1).clamp(0, visiblePlaces.length),
                                    onSelectedIndexChanged: (index) {
                                      final placeItems = [
                                        const _WheelItem(id: null, name: 'Any'),
                                        ...visiblePlaces.map((p) => _WheelItem(id: p.id, name: p.name)),
                                      ];
                                      final pId = placeItems[index].id;
                                      setState(() {
                                        _selectedPlace = pId;
                                        if (pId != null) {
                                          final selectedP = visiblePlaces.firstWhere(
                                            (p) => p.id == pId,
                                            orElse: () => const Place(id: '', weekdayId: '', name: ''),
                                          );
                                          if (selectedP.weekdayId.isNotEmpty) {
                                            _selectedWeekday = selectedP.weekdayId;
                                          }
                                        }
                                        if (_selectedArea != null && pId != null) {
                                          final currentArea = allAreas.firstWhere(
                                            (a) => a.id == _selectedArea,
                                            orElse: () => const Area(id: '', placeId: '', name: ''),
                                          );
                                          if (currentArea.placeId != pId) {
                                            _selectedArea = null;
                                          }
                                        }
                                      });
                                      setModalState(() {});
                                    },
                                    colors: colors,
                                  ),
                                ),

                                // Column 3: Area (dynamically loaded/filtered by Place/Weekday)
                                Expanded(
                                  child: _ScrollWheelColumn(
                                    items: [
                                      const _WheelItem(id: null, name: 'Any'),
                                      ...visibleAreas.map((a) => _WheelItem(id: a.id, name: a.name)),
                                    ],
                                    selectedIndex: _selectedArea == null
                                        ? 0
                                        : (visibleAreas.indexWhere((a) => a.id == _selectedArea) + 1).clamp(0, visibleAreas.length),
                                    onSelectedIndexChanged: (index) {
                                      final areaItems = [
                                        const _WheelItem(id: null, name: 'Any'),
                                        ...visibleAreas.map((a) => _WheelItem(id: a.id, name: a.name)),
                                      ];
                                      final aId = areaItems[index].id;
                                      setState(() {
                                        _selectedArea = aId;
                                        if (aId != null) {
                                          final selectedA = visibleAreas.firstWhere(
                                            (a) => a.id == aId,
                                            orElse: () => const Area(id: '', placeId: '', name: ''),
                                          );
                                          _selectedPlace = selectedA.placeId;
                                          final parentPlace = allPlaces.firstWhere(
                                            (p) => p.id == selectedA.placeId,
                                            orElse: () => const Place(id: '', weekdayId: '', name: ''),
                                          );
                                          if (parentPlace.weekdayId.isNotEmpty) {
                                            _selectedWeekday = parentPlace.weekdayId;
                                          }
                                        }
                                      });
                                      setModalState(() {});
                                    },
                                    colors: colors,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ScrollWheelColumn extends StatefulWidget {
  final List<_WheelItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelectedIndexChanged;
  final AppColors colors;

  const _ScrollWheelColumn({
    required this.items,
    required this.selectedIndex,
    required this.onSelectedIndexChanged,
    required this.colors,
  });

  @override
  State<_ScrollWheelColumn> createState() => _ScrollWheelColumnState();
}

class _ScrollWheelColumnState extends State<_ScrollWheelColumn> {
  late FixedExtentScrollController _controller;
  int _lastReportedIndex = -1;

  @override
  void initState() {
    super.initState();
    final initial = widget.selectedIndex.clamp(0, widget.items.isEmpty ? 0 : widget.items.length - 1);
    _lastReportedIndex = initial;
    _controller = FixedExtentScrollController(initialItem: initial);
  }

  @override
  void didUpdateWidget(covariant _ScrollWheelColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex || widget.items.length != oldWidget.items.length) {
      final target = widget.selectedIndex.clamp(0, widget.items.isEmpty ? 0 : widget.items.length - 1);
      _lastReportedIndex = target;
      if (_controller.hasClients && _controller.selectedItem != target) {
        _controller.jumpToItem(target);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double itemHeight = 44.0;

    if (widget.items.isEmpty) {
      return Center(
        child: Text(
          '—',
          style: TextStyle(fontSize: 13, color: widget.colors.mutedFg),
        ),
      );
    }

    return ListWheelScrollView.useDelegate(
      controller: _controller,
      itemExtent: itemHeight,
      physics: const FixedExtentScrollPhysics(),
      perspective: 0.0001,
      diameterRatio: 50.0,
      overAndUnderCenterOpacity: 0.4,
      onSelectedItemChanged: (index) {
        if (index >= 0 && index < widget.items.length && index != _lastReportedIndex) {
          _lastReportedIndex = index;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onSelectedIndexChanged(index);
            }
          });
        }
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: widget.items.length,
        builder: (context, index) {
          final item = widget.items[index];
          final isSelected = widget.selectedIndex == index;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _controller.animateToItem(
                index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: isSelected ? 13.5 : 12.0,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? widget.colors.primary : widget.colors.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WheelItem {
  final String? id;
  final String name;

  const _WheelItem({
    required this.id,
    required this.name,
  });
}
