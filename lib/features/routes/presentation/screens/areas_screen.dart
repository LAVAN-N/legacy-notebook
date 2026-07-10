import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legacy_notebook/core/constants/app_spacing.dart';
import 'package:legacy_notebook/shared/models/area_model.dart';
import 'package:legacy_notebook/shared/providers/mock_providers.dart';
import 'package:legacy_notebook/shared/widgets/states/empty_state.dart';
import 'package:legacy_notebook/shared/widgets/states/error_state.dart';
import 'package:legacy_notebook/shared/widgets/states/loading_state.dart';

extension _ColorExtension on Color {
  Color withOpacityValue(double opacity) {
    return withValues(alpha: opacity);
  }
}

/// Areas screen - shows all areas for a selected place
class AreasScreen extends ConsumerWidget {
  final String weekdayId;
  final String placeId;

  const AreasScreen({
    required this.weekdayId,
    required this.placeId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(mockAreasByPlaceProvider(placeId));
    final placesAsync = ref.watch(mockPlacesProvider);

    // Get the place name for the app bar
    final placeName = placesAsync.whenData((places) {
      try {
        return places.firstWhere((p) => p.id == placeId).name;
      } catch (e) {
        return 'Areas';
      }
    }).value ?? 'Areas';

    return Scaffold(
      appBar: AppBar(
        title: Text('$placeName - Areas'),
        elevation: 0,
      ),
      body: areasAsync.when(
        loading: () => const Center(
          child: LoadingState(itemCount: 5, isVertical: true),
        ),
        error: (err, stack) => Center(
          child: ErrorState(
            headline: 'Failed to load areas',
            message: err.toString(),
            onRetryPressed: () => ref.refresh(mockAreasByPlaceProvider(placeId)),
          ),
        ),
        data: (areas) {
          if (areas.isEmpty) {
            return const Center(
              child: EmptyState(
                headline: 'No areas found',
                subtext: 'This place has no areas assigned.',
                icon: Icons.map_outlined,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 400));
              return ref.refresh(mockAreasByPlaceProvider(placeId).future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: areas.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final area = areas[index];
                return _buildSwipeableAreaCard(context, area, weekdayId);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwipeableAreaCard(BuildContext context, AreaModel area, String weekdayId) {
    return Dismissible(
      key: ValueKey(area.id),
      background: _buildSwipeBackground(context, 'View', Icons.visibility, Colors.blue, false),
      secondaryBackground: _buildSwipeBackground(context, 'Collect', Icons.check_circle, Colors.green, true),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // View customers
          context.push('/routes/weekdays/$weekdayId/places/$placeId/areas/${area.id}/customers');
        } else if (direction == DismissDirection.endToStart) {
          // Collect area - show feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Collection mode for area...'),
              duration: const Duration(milliseconds: 800),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: _buildAreaCard(context, area, weekdayId),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, String label, IconData icon, Color color, bool isSecondary) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaCard(BuildContext context, AreaModel area, String weekdayId) {
    return GestureDetector(
      onTap: () {
        // Navigate to customers screen with full path
        context.push('/routes/weekdays/$weekdayId/places/$placeId/areas/${area.id}/customers');
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
              context.push('/routes/weekdays/$weekdayId/places/$placeId/areas/${area.id}/customers');
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Area name + Status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          area.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _buildStatusBadge(context, area.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Customers stat
                  Row(
                    children: [
                      Icon(
                        Icons.people_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Customers',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      Text(
                        area.customerCount.toString(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
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
                            '₹${_formatAmount(area.expectedAmount)}',
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
                          value: area.progressPercentage / 100,
                          minHeight: 6,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                          valueColor: AlwaysStoppedAnimation(
                            _getProgressColor(context, area.status),
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
                            '₹${_formatAmount(area.collectedAmount)}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pending: ₹${_formatAmount(area.pendingAmount)}',
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
