import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legacy_notebook/core/constants/app_spacing.dart';
import 'package:legacy_notebook/shared/models/activity_model.dart';
import 'package:legacy_notebook/shared/models/customer_model.dart';
import 'package:legacy_notebook/shared/providers/mock_providers.dart';
import 'package:legacy_notebook/shared/widgets/buttons/primary_button.dart';
import 'package:legacy_notebook/shared/widgets/cards/dashboard_card.dart';
import 'package:legacy_notebook/shared/widgets/cards/summary_card.dart';
import 'package:legacy_notebook/shared/widgets/display/amount_display.dart';
import 'package:legacy_notebook/shared/widgets/display/progress_bar.dart';
import 'package:legacy_notebook/shared/widgets/states/empty_state.dart';
import 'package:legacy_notebook/shared/widgets/states/error_state.dart';
import 'package:legacy_notebook/shared/widgets/states/loading_state.dart';
import 'package:legacy_notebook/app/routes/app_routes.dart';

/// Dashboard screen - main entry point after login.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                _buildTodaysRouteCard(context, ref),
                const SizedBox(height: AppSpacing.lg),
                _buildWeeklyRouteStrip(context, ref),
                const SizedBox(height: AppSpacing.lg),
                _buildQuickActions(context),
                const SizedBox(height: AppSpacing.lg),
                _buildBusinessSummary(context, ref),
                const SizedBox(height: AppSpacing.lg),
                _buildRecentActivity(context, ref),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(mockUserProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final formattedDate = _formatDate(DateTime.now());

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        child: Icon(
          Icons.shopping_bag,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: userAsync.when(
        data: (user) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, ${user.firstName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        loading: () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
              width: 150,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        error: (err, stack) => const Text('Error'),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Center(
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '3',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Center(
            child: userAsync.when(
              data: (user) => CircleAvatar(
                radius: 20,
                backgroundColor: _getAvatarColor(user.id),
                child: Text(
                  user.avatar,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              loading: () => CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
              ),
              error: (err, stack) => CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysRouteCard(BuildContext context, WidgetRef ref) {
    final todayIdProvider = ref.watch(todayWeekdayIdProvider);
    final placesAsync = ref.watch(mockPlacesByWeekdayProvider(todayIdProvider));

    return placesAsync.when(
      loading: () => DashboardCard(
        child: SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (err, stack) => ErrorState(
        headline: "Couldn't load today's route",
        onRetryPressed: () => ref.refresh(mockPlacesByWeekdayProvider(todayIdProvider)),
      ),
      data: (places) {
        if (places.isEmpty) {
          return EmptyState(
            headline: 'No route today',
            subtext: 'Enjoy the day, or view another weekday below.',
            icon: Icons.calendar_today_outlined,
          );
        }

        final totalExpected =
            places.fold<int>(0, (sum, p) => sum + p.expectedAmount);
        final totalCollected =
            places.fold<int>(0, (sum, p) => sum + p.collectedAmount);
        final totalCustomers =
            places.fold<int>(0, (sum, p) => sum + p.customerCount);
        final totalPlaces = places.length;
        final totalAreas =
            places.fold<int>(0, (sum, p) => sum + p.areaCount);
        final progressPercent =
            totalExpected > 0 ? (totalCollected / totalExpected) : 0.0;
        final pendingCustomers = totalCustomers;

        return DashboardCard(
          onTap: () =>
              context.push(AppRoutes.weekdays),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Route',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Thursday',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '$totalPlaces Places · $totalAreas Areas · $totalCustomers Customers',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AmountDisplay(
                amount: totalExpected,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                'expected today',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ProgressBar(
                progress: progressPercent,
                label: 'Collection Progress',
                collected: totalCollected,
                expected: totalExpected,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '$pendingCustomers pending visits',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Start Collecting',
                  onPressed: () => context.push(AppRoutes.weekdays),
                  icon: Icons.arrow_forward,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyRouteStrip(BuildContext context, WidgetRef ref) {
    final weekdaysAsync = ref.watch(mockWeekdaysProvider);
    final todayId = ref.watch(todayWeekdayIdProvider);

    return weekdaysAsync.when(
      loading: () => const SizedBox(
        height: 60,
        child: LoadingState(itemCount: 7, isVertical: false),
      ),
      error: (err, stack) => const SizedBox.shrink(),
      data: (weekdays) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: weekdays.map((weekday) {
              final isToday = weekday.id == todayId;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () {
                    if (isToday) {
                      context.push(AppRoutes.weekdays);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: !isToday
                          ? Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          weekday.dayShort,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: isToday
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${weekday.customerCount}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: isToday
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _QuickActionTile(
          icon: Icons.payment_outlined,
          label: 'Collect\nPayment',
          onTap: () => context.push(AppRoutes.weekdays),
        ),
        _QuickActionTile(
          icon: Icons.shopping_bag_outlined,
          label: 'New\nSale',
          onTap: () => context.push(AppRoutes.search),
        ),
        _QuickActionTile(
          icon: Icons.search_outlined,
          label: 'Find\nCustomer',
          onTap: () => context.push(AppRoutes.search),
        ),
        _QuickActionTile(
          icon: Icons.inventory_2_outlined,
          label: 'Inventory',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildBusinessSummary(BuildContext context, WidgetRef ref) {
    final todayId = ref.watch(todayWeekdayIdProvider);
    final placesAsync = ref.watch(mockPlacesByWeekdayProvider(todayId));

    return placesAsync.when(
      loading: () => const LoadingState(itemCount: 4),
      error: (err, stack) => const SizedBox.shrink(),
      data: (places) {
        final totalCollected =
            places.fold<int>(0, (sum, p) => sum + p.collectedAmount);
        final totalCustomers =
            places.fold<int>(0, (sum, p) => sum + p.customerCount);

        return GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SummaryCard(
              icon: Icons.trending_up,
              label: 'Today\'s Collection',
              value: AmountDisplay.formatAmount(totalCollected),
              subValue: '₹ ${AmountDisplay.formatAmount(totalCollected)}',
            ),
            SummaryCard(
              icon: Icons.shopping_cart_outlined,
              label: 'Today\'s Sales',
              value: '₹ 0',
              subValue: '0 sales',
            ),
            SummaryCard(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Total Outstanding',
              value: '₹ 68,400',
              subValue: 'Across all customers',
              onTap: () {},
            ),
            SummaryCard(
              icon: Icons.people_outline,
              label: 'Visited Today',
              value: '0 / $totalCustomers',
              subValue: 'Customers',
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);
    final customersAsync = ref.watch(mockCustomersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See all',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        activitiesAsync.when(
          loading: () => const LoadingState(
            itemCount: 5,
            itemHeight: 72,
          ),
          error: (err, stack) => ErrorState(
            headline: "Couldn't load activity",
            onRetryPressed: () => ref.refresh(recentActivitiesProvider),
          ),
          data: (activities) {
            if (activities.isEmpty) {
              return EmptyState(
                headline: 'No activity yet today',
                icon: Icons.history,
              );
            }

            return customersAsync.whenData((customers) {
              final customerMap = {for (var c in customers) c.id: c};

              return Column(
                children: activities.take(5).map((activity) {
                  final customer = customerMap[activity.customerId];
                  if (customer == null) return const SizedBox.shrink();

                  return _ActivityRow(
                    customer: customer,
                    activity: activity,
                    onTap: () {
                      // Navigate to customer details
                      context.push(AppRoutes.customerDetails.replaceAll(
                        ':customerId',
                        customer.id,
                      ).replaceAll(':weekdayId', 'weekday_4').replaceAll(
                            ':placeId',
                            'place_1',
                          ).replaceAll(':areaId', 'area_1'));
                    },
                  );
                }).toList(),
              );
            }).when(
              data: (widget) => widget,
              loading: () => const LoadingState(itemCount: 5, itemHeight: 72),
              error: (err, stack) => const SizedBox.shrink(),
            );
          },
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Customers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_outlined),
          activeIcon: Icon(Icons.receipt),
          label: 'Collections',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          activeIcon: Icon(Icons.more_horiz),
          label: 'More',
        ),
      ],
      currentIndex: 0,
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${days[date.weekday % 7]}, ${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
  }

  Color _getAvatarColor(String id) {
    final colors = [
      const Color(0xFF6200EE),
      const Color(0xFF03DAC6),
      const Color(0xFFFF0266),
      const Color(0xFF1F6FEB),
      const Color(0xFFFFB700),
    ];
    return colors[id.hashCode % colors.length];
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final CustomerModel customer;
  final ActivityModel activity;
  final VoidCallback onTap;

  const _ActivityRow({
    required this.customer,
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getColor(customer.id),
                child: Text(
                  customer.initials,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getActivityColor(activity.type)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            activity.typeLabel,
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: _getActivityColor(activity.type),
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AmountDisplay(
                    amount: activity.amount,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getActivityColor(activity.type),
                        ),
                  ),
                  Text(
                    activity.timeAgo,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Color _getColor(String id) {
    final colors = [
      const Color(0xFF6200EE),
      const Color(0xFF03DAC6),
      const Color(0xFFFF0266),
      const Color(0xFF1F6FEB),
      const Color(0xFFFFB700),
    ];
    return colors[id.hashCode % colors.length];
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
      case 'partial_payment':
        return const Color(0xFF28A745);
      case 'sale':
      case 'advance':
        return const Color(0xFF17A2B8);
      case 'carry_forward':
        return const Color(0xFF6C757D);
      default:
        return const Color(0xFF1C1B1F);
    }
  }
}
