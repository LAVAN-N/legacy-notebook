import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

class WeekdayScroller extends StatelessWidget {
  const WeekdayScroller({
    super.key,
    required this.selectedDay,
    required this.onTapDay,
  });

  final String selectedDay;
  final ValueChanged<String> onTapDay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: weekdays.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final day = weekdays[index];
          final isSelected = day == selectedDay;

          return Semantics(
            selected: isSelected,
            label: 'Weekday tab $day',
            child: InkWell(
              onTap: () => onTapDay(day),
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.muted,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.center,
                child: Text(
                  day.substring(0, 3), // e.g. Mon, Tue
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? Colors.white : colors.mutedFg,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
