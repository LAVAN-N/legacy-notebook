import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/error_state.dart';
import '../../core/utils/formatters.dart';
import '../../core/router/routes.dart';
import 'controllers/dashboard_controller.dart';
import 'widgets/hero_outstanding_card.dart';
import 'widgets/weekday_scroller.dart';
import 'widgets/todays_places_list.dart';
import 'widgets/quick_actions_row.dart';
import '../customer/widgets/timeline_entry_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final dashboardState = ref.watch(dashboardControllerProvider);

    return AppScaffold(
      title: Text(
        greeting(),
        style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
        color: colors.primary,
        child: dashboardState.when(
          loading: () => const _LoadingState(),
          error: (err, stack) => ErrorState(
            message: err.toString(),
            onRetry: () => ref.read(dashboardControllerProvider.notifier).refresh(),
          ),
          data: (data) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekday selection bar
                  WeekdayScroller(
                    selectedDay: data.weekdayName,
                    onTapDay: (day) {
                      context.go(Routes.weekday(day));
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Hero collection widget
                  HeroOutstandingCard(
                    expectedAmount: data.expectedAmount,
                    collectedAmount: data.collectedAmount,
                    pendingVisits: data.pendingVisitsCount,
                    weekday: data.weekdayName,
                    onTapStart: () {
                      if (data.todayPlaces.isNotEmpty) {
                        context.go(Routes.place(data.todayPlaces.first.id));
                      } else {
                        context.go(Routes.weekday(data.weekdayName));
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Total Dues',
                          value: data.totalOutstanding,
                          subValue: 'Across all clients',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: StatCard(
                          label: 'Dues Collected',
                          value: data.collectedAmount,
                          subValue: 'Today\'s total',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Quick Action Tiles
                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: AppSpacing.sm),
                  const QuickActionsRow(),
                  const SizedBox(height: AppSpacing.lg),

                  // Places List
                  SectionHeader(
                    title: 'Route Locations',
                    actionLabel: 'View All',
                    onActionTap: () {
                      context.go(Routes.weekday(data.weekdayName));
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TodaysPlacesList(
                    places: data.todayPlaces,
                    onTapPlace: (place) {
                      context.go(Routes.place(place.id));
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Recent Activities Timeline
                  const SectionHeader(title: 'Recent Transactions'),
                  const SizedBox(height: AppSpacing.sm),
                  if (data.recentActivities.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      alignment: Alignment.center,
                      child: Text(
                        'No transactions recorded yet.',
                        style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg),
                      ),
                    )
                  else
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.recentActivities.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final act = data.recentActivities[index];
                          // Map activity back to customer name mapping for UI context display
                          final customerName = act.when(
                            payment: (_, __, ___, ____, _____) => 'Lakshmi Priya',
                            partialPayment: (_, __, ___, ____, _____) => 'Lakshmi Priya',
                            carryForward: (_, __, ___, ____) => 'Lakshmi Priya',
                            sale: (_, __, ___, ____, _____, ______, _______, ________, _________) => 'Lakshmi Priya',
                          );

                          return TimelineEntryTile(
                            activity: act,
                            customTitle: '$customerName · ${act.when(
                              payment: (_, __, ___, ____, _____) => 'Payment',
                              partialPayment: (_, __, ___, ____, _____) => 'Partial Payment',
                              carryForward: (_, __, ___, ____) => 'Carry Forward',
                              sale: (_, __, ___, ____, _____, ______, _______, ________, _________) => 'New Sale',
                            )}',
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const LoadingSkeleton(width: double.infinity, height: 48),
            const SizedBox(height: 16),
            const LoadingSkeleton(width: double.infinity, height: 260, borderRadius: 24),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: LoadingSkeleton(width: double.infinity, height: 100)),
                SizedBox(width: 16),
                Expanded(child: LoadingSkeleton(width: double.infinity, height: 100)),
              ],
            ),
            const SizedBox(height: 24),
            const SkeletonList(itemCount: 3),
          ],
        ),
      ),
    );
  }
}
