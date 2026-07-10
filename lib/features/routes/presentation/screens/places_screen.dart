import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legacy_notebook/app/providers/navigation_provider.dart';
import 'package:legacy_notebook/core/constants/app_spacing.dart';
import 'package:legacy_notebook/shared/models/place_model.dart';
import 'package:legacy_notebook/shared/providers/mock_providers.dart';
import 'package:legacy_notebook/shared/widgets/states/empty_state.dart';
import 'package:legacy_notebook/shared/widgets/states/error_state.dart';
import 'package:legacy_notebook/shared/widgets/states/loading_state.dart';

extension _ColorExtension on Color {
  Color withOpacityValue(double opacity) {
    return withValues(alpha: opacity);
  }
}

/// Places screen - shows all places for a selected weekday
class PlacesScreen extends ConsumerWidget {
  final String weekdayId;

  const PlacesScreen({required this.weekdayId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the selected weekday and update navigation state
    ref.read(navigationPathProvider.notifier).selectWeekday(weekdayId);

    final placesAsync = ref.watch(mockPlacesByWeekdayProvider(weekdayId));
    final weekdaysAsync = ref.watch(mockWeekdaysProvider);

    // Get the weekday name for the app bar
    final weekdayName = weekdaysAsync.whenData((weekdays) {
      try {
        return weekdays.firstWhere((w) => w.id == weekdayId).day;
      } catch (e) {
        return 'Places';
      }
    }).value ?? 'Places';

    return Scaffold(
      appBar: AppBar(
        title: Text('$weekdayName - Places'),
        elevation: 0,
      ),
      body: placesAsync.when(
        loading: () => const Center(
          child: LoadingState(itemCount: 5, isVertical: true),
        ),
        error: (err, stack) => Center(
          child: ErrorState(
            headline: 'Failed to load places',
            message: err.toString(),
            onRetryPressed: () => ref.refresh(mockPlacesByWeekdayProvider(weekdayId)),
          ),
        ),
        data: (places) {
          if (places.isEmpty) {
            return const Center(
              child: EmptyState(
                headline: 'No places scheduled',
                subtext: 'This weekday has no routes assigned.',
                icon: Icons.location_on_outlined,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 400));
              return ref.refresh(mockPlacesByWeekdayProvider(weekdayId).future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: places.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final place = places[index];
                return _buildPlaceCard(context, place);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, PlaceModel place) {
    return GestureDetector(
      onTap: () {
        // Navigate to areas screen with full path
        context.push('/routes/weekdays/$weekdayId/places/${place.id}/areas');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
          boxShadow: [
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
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              context.push('/routes/weekdays/$weekdayId/places/${place.id}/areas');
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Place name + Status badge + Distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${place.distance.toStringAsFixed(1)} km',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _buildStatusBadge(context, place.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Stats row: Areas, Customers
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatColumn(
                          context,
                          icon: Icons.map_outlined,
                          label: 'Areas',
                          value: place.areaCount.toString(),
                        ),
                      ),
                      Expanded(
                        child: _buildStatColumn(
                          context,
                          icon: Icons.people_outlined,
                          label: 'Customers',
                          value: place.customerCount.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

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
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            '₹${_formatAmount(place.expectedAmount)}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: place.progressPercentage / 100,
                          minHeight: 6,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                          valueColor: AlwaysStoppedAnimation(
                            _getProgressColor(context, place.status),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Collected',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            '₹${_formatAmount(place.collectedAmount)}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pending: ₹${_formatAmount(place.pendingAmount)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildStatColumn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final (bgColor, textColor, label) = switch (status) {
      'done' => (
        Theme.of(context).colorScheme.primary.withOpacityValue(0.2),
        Theme.of(context).colorScheme.primary,
        'Done',
      ),
      'in_progress' => (
        Theme.of(context).colorScheme.tertiary.withOpacityValue(0.2),
        Theme.of(context).colorScheme.tertiary,
        'In Progress',
      ),
      _ => (
        Theme.of(context).colorScheme.outline.withOpacityValue(0.2),
        Theme.of(context).colorScheme.onSurfaceVariant,
        'Pending',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Color _getProgressColor(BuildContext context, String status) {
    return switch (status) {
      'done' => Theme.of(context).colorScheme.primary,
      'in_progress' => Theme.of(context).colorScheme.tertiary,
      _ => Theme.of(context).colorScheme.outline,
    };
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
