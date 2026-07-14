import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../core/widgets/theme_toggle_button.dart';
import '../../core/utils/formatters.dart';
import '../../core/router/routes.dart';
import 'controllers/dashboard_controller.dart';
import 'widgets/hero_outstanding_card.dart';
import 'widgets/weekday_scroller.dart';
import 'widgets/todays_places_list.dart';
import 'widgets/quick_actions_row.dart';
import '../customer/widgets/timeline_entry_tile.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    print('[DashboardScreen] initState()');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('[DashboardScreen] didChangeDependencies()');
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    final isSecondBackPress = _lastBackPress != null &&
        now.difference(_lastBackPress!).inSeconds < 2;

    if (isSecondBackPress) {
      // Exit the app on second back press within 2 seconds
      return true;
    }

    // Show snackbar on first back press
    _lastBackPress = now;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dashboardState = ref.watch(dashboardControllerProvider);
    print('[DashboardScreen] build() - state: ${dashboardState.runtimeType}');

    return BackButtonListener(
      onBackButtonPressed: () async {
        final shouldExit = await _onWillPop();
        if (shouldExit && mounted) {
          SystemNavigator.pop();
        }
        return true;
      },
      child: AppScaffold(
        blendHeader: true,
        title: Text(
          greeting(),
          style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
        ),
        appBarActions: const [ThemeToggleButton()],
        body: RefreshIndicator(
          onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
          color: colors.primary,
          child: dashboardState.when(
            loading: () {
              print('[DashboardScreen] showing loading state');
              return const _LoadingState();
            },
            error: (err, stack) {
              print('[DashboardScreen] showing error state: $err');
              return ErrorState(
                message: err.toString(),
                onRetry: () => ref.read(dashboardControllerProvider.notifier).refresh(),
              );
            },
            data: (data) {
              print('[DashboardScreen] showing data state with ${data.todayPlaces.length} places');
              return SingleChildScrollView(
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
                            context.go(Routes.place(data.weekdayName, data.todayPlaces.first.id));
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
                          context.go(Routes.place(data.weekdayName, place.id));
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Recent Activities Timeline
                      SectionHeader(
                        title: 'Recent Transactions',
                        actionLabel: 'View All',
                        onActionTap: () {
                          context.go('/transactions');
                        },
                      ),
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

                              final activityType = act.when(
                                payment: (_, __, ___, ____, _____) => 'Payment',
                                partialPayment: (_, __, ___, ____, _____) => 'Partial Payment',
                                carryForward: (_, __, ___, ____) => 'Carry Forward',
                                sale: (_, __, ___, ____, _____, ______, _______, ________, _________) => 'New Sale',
                              );
                              final title = '$customerName · $activityType';

                              return TimelineEntryTile(
                                activity: act,
                                customTitle: title,
                              );
                            },
                          ),
                        ),
                      // Bottom padding to avoid floating nav overlap
                      const SizedBox(height: 96),
                  ],
                ),
              ),
            );
          },
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
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
