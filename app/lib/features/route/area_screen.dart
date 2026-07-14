import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/tag_chip.dart';
import '../../core/widgets/amount_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/router/routes.dart';
import '../../core/router/navigation_shell.dart';
import '../../data/repositories/route_repository.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  TagType _determineTagType(CustomerProgress item) {
    if (item.isVisitedToday) {
      if (item.lastCollectionStatus == 'PAYMENT') return TagType.done;
      if (item.lastCollectionStatus == 'PARTIAL_PAYMENT') return TagType.partial;
      return TagType.carryForward;
    }
    return item.outstanding.outstandingAmount > 0 ? TagType.pending : TagType.noOutstanding;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final customersState = ref.watch(areaCustomersProvider(widget.areaId));

    // Get the place ID for the back button and the area details for the title
    final areaData = ref.watch(routeRepositoryProvider).watchAreasByPlace('p-1').map((list) {
      try {
        return list.firstWhere((a) => a.id == widget.areaId);
      } catch (_) {
        return null;
      }
    });

    return StreamBuilder(
      stream: areaData,
      builder: (context, snapshot) {
        final area = snapshot.data;
        final title = area?.name ?? 'Area Customers';
        final backPlaceId = area?.placeId ?? 'p-1';

        return AppScaffold(
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
              if (customers.isEmpty) {
                return EmptyState(
                  title: 'No Customers',
                  message: 'No active clients mapped to this collection area.',
                  action: OutlinedButton(
                    onPressed: () {
                      final target = context.getBackTarget() ?? Routes.dashboard;
                      context.go(target);
                    },
                    child: const Text('Back to Place'),
                  ),
                );
              }

              // Filter based on search query
              final filtered = customers.where((c) {
                final query = _searchQuery.toLowerCase();
                return c.customer.name.toLowerCase().contains(query) ||
                    c.customer.customerCode.toLowerCase().contains(query);
              }).toList();

              return Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by client name or ID...',
                        prefixIcon: Icon(Icons.search, color: colors.mutedFg, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Customer List
                  Expanded(
                    child: filtered.isEmpty
                        ? const EmptyState(
                            title: 'No matches found',
                            message: 'Try checking spellings or inputting another name.',
                            icon: Icons.person_search_outlined,
                          )
                        : ReorderableListView.builder(
                            onReorder: (oldIdx, newIdx) {
                              if (newIdx > oldIdx) newIdx--;
                              final list = List<CustomerProgress>.from(filtered);
                              final item = list.removeAt(oldIdx);
                              list.insert(newIdx, item);
                              ref.read(areaCustomersProvider(widget.areaId).notifier).reorderSequence(list);
                            },
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final tagType = _determineTagType(item);

                              return Card(
                                key: ValueKey(item.customer.id),
                                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: InkWell(
                                  onTap: () => context.go(Routes.customer(widget.weekday, widget.placeId, widget.areaId, item.customer.id)),
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppSpacing.lg),
                                    child: Row(
                                      children: [
                                        // Sequence badge
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: colors.muted,
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            item.customer.sequenceNumber.toString(),
                                            style: AppTypography.labelLarge.copyWith(
                                              color: colors.mutedFg,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.lg),

                                        // Customer details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.customer.name,
                                                      style: AppTypography.titleSmall.copyWith(
                                                        color: colors.foreground,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  TagChip(type: tagType),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    item.customer.customerCode,
                                                    style: AppTypography.labelSmall.copyWith(
                                                      color: colors.mutedFg,
                                                    ),
                                                  ),
                                                  if (item.outstanding.outstandingAmount > 0)
                                                    AmountText(
                                                      amount: item.outstanding.outstandingAmount,
                                                      style: AppTypography.currencySmall.copyWith(
                                                        color: colors.danger,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    )
                                                  else
                                                    Text(
                                                      'Paid Up',
                                                      style: AppTypography.labelSmall.copyWith(
                                                        color: colors.success,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        // Drag handler icon
                                        Icon(Icons.drag_handle, color: colors.mutedFg.withOpacity(0.5), size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
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
