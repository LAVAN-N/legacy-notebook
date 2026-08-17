import 'dart:developer' as developer;
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
import '../transactions/widgets/transaction_card.dart';

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
    developer.log('initState()', name: 'DashboardScreen');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    developer.log('didChangeDependencies()', name: 'DashboardScreen');
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
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
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
    developer.log('build() - state: ${dashboardState.runtimeType}', name: 'DashboardScreen');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _onWillPop();
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
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
              developer.log('showing loading state', name: 'DashboardScreen');
              return const _LoadingState();
            },
            error: (err, stack) {
              developer.log('showing error state: $err', name: 'DashboardScreen', error: err, stackTrace: stack);
              return ErrorState(
                message: err.toString(),
                onRetry: () => ref.read(dashboardControllerProvider.notifier).refresh(),
              );
            },
            data: (data) {
              developer.log('showing data state with ${data.todayPlaces.length} places', name: 'DashboardScreen');
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics()),
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
                      if (data.recentTransactions.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          alignment: Alignment.center,
                          child: Text(
                            'No transactions recorded yet.',
                            style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: data.recentTransactions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            return TransactionCard(
                              item: data.recentTransactions[index],
                              colors: colors,
                              source: 'dashboard',
                            );
                          },
                        ),
                      // Bottom padding to avoid floating nav overlap
                      const SizedBox(height: AppSpacing.lg),
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
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            LoadingSkeleton(width: double.infinity, height: 48),
            SizedBox(height: 16),
            LoadingSkeleton(width: double.infinity, height: 260, borderRadius: 24),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: LoadingSkeleton(width: double.infinity, height: 100)),
                SizedBox(width: 16),
                Expanded(child: LoadingSkeleton(width: double.infinity, height: 100)),
              ],
            ),
            SizedBox(height: 24),
            SkeletonList(itemCount: 3),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
