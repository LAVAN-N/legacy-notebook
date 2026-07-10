import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legacy_notebook/core/constants/app_spacing.dart';
import 'package:legacy_notebook/shared/models/weekday_model.dart';
import 'package:legacy_notebook/shared/providers/mock_providers.dart';
import 'package:legacy_notebook/shared/widgets/states/empty_state.dart';
import 'package:legacy_notebook/shared/widgets/states/error_state.dart';
import 'package:legacy_notebook/shared/widgets/states/loading_state.dart';

extension _ColorExtension on Color {
  Color withOpacityValue(double opacity) {
    return withValues(alpha: opacity);
  }
}

/// Weekdays screen - shows all 7 weekdays with stats and selection
class WeekdaysScreen extends ConsumerWidget {
  const WeekdaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekdaysAsync = ref.watch(mockWeekdaysProvider);
    final todayId = ref.watch(todayWeekdayIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Weekday'),
        elevation: 0,
      ),
      body: weekdaysAsync.when(
        loading: () => const Center(
          child: LoadingState(itemCount: 6, isVertical: true),
        ),
        error: (err, stack) => Center(
          child: ErrorState(
            headline: 'Failed to load weekdays',
            message: err.toString(),
            onRetryPressed: () => ref.refresh(mockWeekdaysProvider),
          ),
        ),
        data: (weekdays) {
          if (weekdays.isEmpty) {
            return const Center(
              child: EmptyState(
                headline: 'No weekdays available',
                subtext: 'Check back later for available routes.',
                icon: Icons.calendar_today_outlined,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 400));
              return ref.refresh(mockWeekdaysProvider.future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Routes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: weekdays.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final weekday = weekdays[index];
                      final isToday = weekday.id == todayId;
                      return _buildWeekdayCard(
                        context,
                        weekday,
                        isToday,
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

  Widget _buildWeekdayCard(
    BuildContext context,
    WeekdayModel weekday,
    bool isToday,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to places screen with selected weekday
        context.push('/routes/weekdays/${weekday.id}/places');
      },
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: !isToday
              ? Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                )
              : null,
          boxShadow: [
            if (isToday)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacityValue(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacityValue(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context.push('/routes/weekdays/${weekday.id}/places');
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header: Day name + Today badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weekday.day,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isToday ? Colors.white : null,
                                  ),
                            ),
                            Text(
                              weekday.dayShort,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isToday
                                        ? Colors.white.withOpacityValue(0.7)
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacityValue(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Today',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),
                  // Stats
                  Column(
                    children: [
                      _buildStat(
                        context,
                        icon: Icons.location_on_outlined,
                        label: 'Places',
                        value: weekday.placeCount.toString(),
                        isToday: isToday,
                      ),
                      const SizedBox(height: 8),
                      _buildStat(
                        context,
                        icon: Icons.map_outlined,
                        label: 'Areas',
                        value: weekday.areaCount.toString(),
                        isToday: isToday,
                      ),
                      const SizedBox(height: 8),
                      _buildStat(
                        context,
                        icon: Icons.people_outlined,
                        label: 'Customers',
                        value: weekday.customerCount.toString(),
                        isToday: isToday,
                      ),
                    ],
                  ),
                  // Amount bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expected',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isToday
                                      ? Colors.white.withOpacityValue(0.7)
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            '₹${_formatAmount(weekday.expectedAmount)}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isToday ? Colors.white : null,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: weekday.progressPercentage / 100,
                          minHeight: 4,
                          backgroundColor: isToday
                              ? Colors.white.withOpacityValue(0.2)
                              : Theme.of(context).colorScheme.surfaceContainer,
                          valueColor: AlwaysStoppedAnimation(
                            isToday
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Collected',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isToday
                                      ? Colors.white.withOpacityValue(0.7)
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            '₹${_formatAmount(weekday.collectedAmount)}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isToday ? Colors.white : null,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isToday,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isToday
              ? Colors.white.withOpacityValue(0.7)
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isToday
                      ? Colors.white.withOpacityValue(0.7)
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isToday ? Colors.white : null,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }
}
