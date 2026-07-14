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
import '../../core/utils/formatters.dart';
import '../../core/router/routes.dart';
import '../../core/router/navigation_shell.dart';
import 'controllers/route_controller.dart';

class WeekdayScreen extends ConsumerWidget {
  const WeekdayScreen({super.key, required this.dayName});

  final String dayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final placesState = ref.watch(weekdayPlacesProvider(dayName));

    return AppScaffold(
      title: Text(
        '$dayName Route',
        style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
      ),
      body: placesState.when(
        loading: () => const _LoadingState(),
        error: (err, stack) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(weekdayPlacesProvider(dayName)),
        ),
        data: (places) {
          if (places.isEmpty) {
            return EmptyState(
              title: 'Rest Day',
              message: 'No collections scheduled for $dayName.',
              icon: Icons.weekend_outlined,
              action: OutlinedButton(
                onPressed: () {
                  final target = context.getBackTarget() ?? Routes.dashboard;
                  context.go(target);
                },
                child: const Text('Back to Home'),
              ),
            );
          }

          // Calculate weekday summary
          final totalExpected = places.fold<int>(0, (sum, p) => sum + p.expectedAmount);
          final totalCollected = places.fold<int>(0, (sum, p) => sum + p.collectedAmount);
          final totalCustomers = places.fold<int>(0, (sum, p) => sum + p.customerCount);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekday summary cards
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Clients Total',
                          value: totalCustomers.toString(),
                          subValue: 'Across ${places.length} locations',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: StatCard(
                          label: 'Collected Today',
                          value: totalCollected,
                          subValue: 'Expected: ${rupees(totalExpected)}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'Route Places',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: places.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = places[index];
                      final progress = item.expectedAmount > 0
                          ? (item.collectedAmount / item.expectedAmount).clamp(0.0, 1.0)
                          : 0.0;
                      final percent = (progress * 100).toInt();

                      return Card(
                        child: InkWell(
                          onTap: () => context.go(Routes.place(dayName, item.place.id)),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.place.name,
                                      style: AppTypography.titleSmall.copyWith(
                                        color: colors.foreground,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${item.customerCount} Clients',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.mutedFg,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Collected: ${rupees(item.collectedAmount)} / ${rupees(item.expectedAmount)}',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.mutedFg,
                                      ),
                                    ),
                                    Text(
                                      '$percent%',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppRadius.full),
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
          Row(
            children: [
              Expanded(child: LoadingSkeleton(width: double.infinity, height: 100)),
              SizedBox(width: 16),
              Expanded(child: LoadingSkeleton(width: double.infinity, height: 100)),
            ],
          ),
          SizedBox(height: 24),
          SkeletonList(itemCount: 4),
        ],
      ),
    );
  }
}
