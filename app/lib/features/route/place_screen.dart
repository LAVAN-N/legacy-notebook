import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/app_pull_to_refresh.dart';
import '../../core/utils/formatters.dart';
import '../../core/router/routes.dart';
import '../../core/router/navigation_shell.dart';
import '../../data/providers.dart';
import 'controllers/route_controller.dart';


class PlaceScreen extends ConsumerWidget {
  const PlaceScreen({
    super.key,
    required this.placeId,
    this.weekday = 'Monday',
  });

  final String placeId;
  final String weekday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final areasState = ref.watch(placeAreasProvider(placeId));

    final placesAsync = ref.watch(placesStreamProvider);
    final places = placesAsync.value ?? [];
    String title = 'Place';
    try {
      title = places.firstWhere((p) => p.id == placeId).name;
    } catch (_) {}

    return AppScaffold(
      blendHeader: true,
      title: Text(
        title,
        style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
      ),
      body: AppPullToRefresh(
        onRefresh: () => ref.refresh(placeAreasProvider(placeId).future),
        color: colors.primary,
        child: areasState.when(
              loading: () => const _LoadingState(),
              error: (err, stack) => ErrorState(
                message: err.toString(),
                onRetry: () => ref.refresh(placeAreasProvider(placeId)),
              ),
              data: (areas) {
                if (areas.isEmpty) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: EmptyState(
                        title: 'No Areas',
                        message: 'No collection areas configured for this location.',
                        action: OutlinedButton(
                          onPressed: () {
                            final target =
                                context.getBackTarget() ?? Routes.dashboard;
                            context.go(target);
                          },
                          child: const Text('Back to Weekday'),
                        ),
                      ),
                    ),
                  );
                }

                final totalExpected =
                    areas.fold<int>(0, (sum, a) => sum + a.expectedAmount);
                final totalCollected =
                    areas.fold<int>(0, (sum, a) => sum + a.collectedAmount);
                final totalCustomers =
                    areas.fold<int>(0, (sum, a) => sum + a.customerCount);

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Place summary strip
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Areas Total',
                              value: areas.length.toString(),
                              subValue: '$totalCustomers Clients total',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: StatCard(
                              label: 'Actual Collection',
                              value: totalCollected,
                              subValue: 'Expected: ${rupees(totalExpected)}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'Collection Areas',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.foreground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: areas.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = areas[index];
                          final progress = item.expectedAmount > 0
                              ? (item.collectedAmount / item.expectedAmount)
                                  .clamp(0.0, 1.0)
                              : 0.0;
                          final percent = (progress * 100).toInt();

                          return Card(
                            child: InkWell(
                              onTap: () => context.go(
                                  Routes.area(weekday, placeId, item.area.id)),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.area.name,
                                          style:
                                              AppTypography.titleSmall.copyWith(
                                            color: colors.foreground,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '${item.customerCount} Clients',
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            color: colors.mutedFg,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Collected: ${rupees(item.collectedAmount)} / ${rupees(item.expectedAmount)}',
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            color: colors.mutedFg,
                                          ),
                                        ),
                                        Text(
                                          '$percent%',
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            color: colors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.full),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 6,
                                        backgroundColor: colors.muted,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
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
          Row(
            children: [
              Expanded(
                  child: LoadingSkeleton(width: double.infinity, height: 100)),
              SizedBox(width: 16),
              Expanded(
                  child: LoadingSkeleton(width: double.infinity, height: 100)),
            ],
          ),
          SizedBox(height: 24),
          SkeletonList(itemCount: 3),
        ],
      ),
    );
  }
}
