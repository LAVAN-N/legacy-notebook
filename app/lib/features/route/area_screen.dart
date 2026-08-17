import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/tag_chip.dart';
import '../../core/utils/formatters.dart';
import '../../core/router/routes.dart';
import '../../data/providers.dart';
import 'controllers/route_controller.dart';

class AreaScreen extends ConsumerStatefulWidget {
  const AreaScreen({
    super.key,
    required this.areaId,
    this.weekday = 'Monday',
    this.placeId = '',
  });

  final String areaId;
  final String weekday;
  final String placeId;

  @override
  ConsumerState<AreaScreen> createState() => _AreaScreenState();
}

class _AreaScreenState extends ConsumerState<AreaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  TagType _determineTagType(CustomerProgress item) {
    if (item.isVisitedToday) {
      if (item.lastCollectionStatus == 'PAYMENT') {
        return TagType.done;
      }
      if (item.lastCollectionStatus == 'PARTIAL_PAYMENT') {
        return TagType.partial;
      }
      return TagType.carryForward;
    }
    return item.outstanding.outstandingAmount > 0
        ? TagType.pending
        : TagType.noOutstanding;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final customersState = ref.watch(areaCustomersProvider(widget.areaId));
    final areasAsync = ref.watch(areasStreamProvider);

    String title = 'Area';
    try {
      final allAreas = areasAsync.value ?? [];
      title = allAreas.firstWhere((a) => a.id == widget.areaId).name;
    } catch (_) {}

    final statusOptions = ['All', 'Outstanding', 'Lend', 'Settled'];

    return AppScaffold(
      blendHeader: true,
      title: Text(
        title,
        style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
      ),
      body: customersState.when(
        loading: () => const _LoadingState(),
        error: (err, stack) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(areaCustomersProvider(widget.areaId)),
        ),
        data: (customers) {
          // Compute display outstanding based on status
          int getDisplayOutstanding(CustomerProgress cp) {
            if (_selectedStatus == 'Outstanding') {
              return cp.outstanding.saleOutstanding;
            } else if (_selectedStatus == 'Lend') {
              return cp.outstanding.lendOutstanding;
            } else if (_selectedStatus == 'Settled') {
              return 0;
            } else {
              return cp.outstanding.outstandingAmount;
            }
          }

          // Filtering
          final filtered = customers.where((cp) {
            final q = _searchQuery.toLowerCase();
            final matchesSearch = cp.customer.name.toLowerCase().contains(q) ||
                cp.customer.customerCode.toLowerCase().contains(q) ||
                cp.customer.phone.contains(q) ||
                cp.customer.address.toLowerCase().contains(q);

            if (!matchesSearch) return false;

            // Status filter
            final totalOut = cp.outstanding.outstandingAmount;
            final saleOut = cp.outstanding.saleOutstanding;
            final lendOut = cp.outstanding.lendOutstanding;

            if (_selectedStatus == 'Outstanding' && saleOut <= 0) {
              return false;
            }
            if (_selectedStatus == 'Lend' && lendOut <= 0) {
              return false;
            }
            if (_selectedStatus == 'Settled' && totalOut > 0) {
              return false;
            }

            return true;
          }).toList();

          // Calculate summary stats
          int totalOutstanding = 0;
          for (final cp in filtered) {
            final out = getDisplayOutstanding(cp);
            if (out > 0) {
              totalOutstanding += out;
            }
          }

          final isFilteringActive =
              _searchQuery.isNotEmpty || _selectedStatus != 'All';

          return Column(
            children: [
              // Stats Row (Total Clients & Outstanding Summary)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
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
                          color: (_selectedStatus == 'Lend'
                                  ? Colors.orange
                                  : (_selectedStatus == 'Settled'
                                      ? colors.success
                                      : colors.danger))
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (_selectedStatus == 'Lend'
                                    ? Colors.orange
                                    : (_selectedStatus == 'Settled'
                                        ? colors.success
                                        : colors.danger))
                                .withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _selectedStatus == 'Lend'
                                      ? Icons.handshake_outlined
                                      : (_selectedStatus == 'Outstanding'
                                          ? Icons.shopping_bag_outlined
                                          : (_selectedStatus == 'Settled'
                                              ? Icons.check_circle_outline
                                              : Icons.error_outline_rounded)),
                                  color: _selectedStatus == 'Lend'
                                      ? Colors.orange
                                      : (_selectedStatus == 'Settled'
                                          ? colors.success
                                          : colors.danger),
                                  size: 16,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    _selectedStatus == 'Lend'
                                        ? 'Lend Outstanding'
                                        : (_selectedStatus == 'Outstanding'
                                            ? 'Sale Outstanding'
                                            : (_selectedStatus == 'Settled'
                                                ? 'Settled Clients'
                                                : 'Outstanding')),
                                    style: AppTypography.labelMedium
                                        .copyWith(color: colors.mutedFg),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _selectedStatus == 'Settled'
                                  ? '${filtered.length}'
                                  : rupees(totalOutstanding),
                              style: AppTypography.currencyMedium.copyWith(
                                color: _selectedStatus == 'Lend'
                                    ? Colors.orange
                                    : (_selectedStatus == 'Settled'
                                        ? colors.success
                                        : colors.danger),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar with clear button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, or code...',
                    prefixIcon: Icon(Icons.search, color: colors.mutedFg),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: colors.mutedFg),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
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

              // Status Filter Chips
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

              // Clients List / Empty State
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.refresh(areaCustomersProvider(widget.areaId).future),
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
                                      });
                                    },
                                    child: const Text('Clear filters'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : (!isFilteringActive
                          // Reorderable list when in default view
                          ? ReorderableListView.builder(
                              buildDefaultDragHandles: false,
                              physics: const AlwaysScrollableScrollPhysics(
                                  parent: ClampingScrollPhysics()),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              itemCount: filtered.length,
                              onReorderItem: (oldIdx, newIdx) {
                                final list = List<CustomerProgress>.from(filtered);
                                final item = list.removeAt(oldIdx);
                                list.insert(newIdx, item);
                                ref
                                    .read(areaCustomersProvider(widget.areaId).notifier)
                                    .reorderSequence(list);
                              },
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                return _buildClientCard(
                                  context,
                                  item,
                                  getDisplayOutstanding(item),
                                  colors,
                                );
                              },
                            )
                          // Standard list view when search/filters are active
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                  parent: ClampingScrollPhysics()),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                return _buildClientCard(
                                  context,
                                  item,
                                  getDisplayOutstanding(item),
                                  colors,
                                );
                              },
                            )),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClientCard(
    BuildContext context,
    CustomerProgress item,
    int displayOutstanding,
    AppColors colors,
  ) {
    final c = item.customer;
    final totalOut = item.outstanding.outstandingAmount;
    final lendOut = item.outstanding.lendOutstanding;
    final saleOut = item.outstanding.saleOutstanding;

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

    final tagType = _determineTagType(item);

    return Card(
      key: ValueKey(c.id),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(
        onTap: () {
          context.go(Routes.customer(
            widget.weekday,
            widget.placeId.isNotEmpty ? widget.placeId : c.placeId,
            widget.areaId.isNotEmpty ? widget.areaId : c.areaId,
            c.id,
          ));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Avatar with Outstanding indicator dot
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
                          border: Border.all(color: colors.surface, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),

              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.name,
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.foreground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isVisitedToday) ...[
                          const SizedBox(width: 6),
                          TagChip(type: tagType),
                        ],
                      ],
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
                              size: 12, color: colors.mutedFg),
                          const SizedBox(width: 4),
                          Text(
                            c.phone,
                            style: AppTypography.labelSmall.copyWith(
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

              // Outstanding Amount & Status Capsule
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rupees(displayOutstanding),
                    style: AppTypography.currencySmall.copyWith(
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
                      style: AppTypography.labelSmall.copyWith(
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
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          LoadingSkeleton(width: double.infinity, height: 48),
          SizedBox(height: 16),
          SkeletonList(itemCount: 5),
        ],
      ),
    );
  }
}
