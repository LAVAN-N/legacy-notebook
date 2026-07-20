import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/place.dart';

class TodaysPlacesList extends StatelessWidget {
  const TodaysPlacesList({
    super.key,
    required this.places,
    required this.onTapPlace,
  });

  final List<Place> places;
  final ValueChanged<Place> onTapPlace;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (places.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.home_work_outlined, size: 48, color: colors.mutedFg.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No Places Today',
              style: AppTypography.titleSmall.copyWith(color: colors.foreground),
            ),
            const SizedBox(height: 4),
            Text(
              'Enjoy your rest day!',
              style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: places.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final place = places[index];

        return Card(
          child: InkWell(
            onTap: () => onTapPlace(place),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.pin_drop_outlined, color: colors.primary, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to view collection areas',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.mutedFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colors.mutedFg, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
