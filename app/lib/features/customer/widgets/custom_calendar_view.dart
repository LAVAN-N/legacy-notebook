import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/activity.dart';

class CustomCalendarView extends StatefulWidget {
  const CustomCalendarView({
    super.key,
    required this.activitiesByDate,
    required this.onDateTapped,
  });

  final Map<DateTime, List<Activity>> activitiesByDate;
  final Function(DateTime, List<Activity>) onDateTapped;

  @override
  State<CustomCalendarView> createState() => _CustomCalendarViewState();
}

class _CustomCalendarViewState extends State<CustomCalendarView> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;

    // Get number of days in month
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    // Find first weekday of the month (1 = Monday, 7 = Sunday)
    final firstDayOffset = DateTime(year, month, 1).weekday - 1; // 0-based offset for GridView starting on Monday

    final List<DateTime?> calendarDays = List.generate(
      firstDayOffset + daysInMonth,
      (index) {
        if (index < firstDayOffset) {
          return null;
        } else {
          return DateTime(year, month, index - firstDayOffset + 1);
        }
      },
    );

    final monthName = DateFormat('MMMM yyyy').format(_focusedMonth);

    return Column(
      children: [
        // Calendar Header (Month Name and Navigation)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              monthName,
              style: AppTypography.bodyLarge.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                  color: colors.primary,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                  color: colors.primary,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Weekday labels
        GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          crossAxisCount: 7,
          physics: const NeverScrollableScrollPhysics(),
          children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
            return Center(
              child: Text(
                day,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),

        // Day cells
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: calendarDays.length,
          itemBuilder: (context, index) {
            final day = calendarDays[index];
            if (day == null) {
              return const SizedBox.shrink();
            }

            final dateOnly = DateTime(day.year, day.month, day.day);
            final dayActivities = widget.activitiesByDate[dateOnly] ?? [];
            final hasActivities = dayActivities.isNotEmpty;

            final isToday = DateUtils.isSameDay(day, DateTime.now());

            return InkWell(
              onTap: () {
                widget.onDateTapped(day, dayActivities);
              },
              borderRadius: BorderRadius.circular(100),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isToday
                        ? colors.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday
                        ? Border.all(color: colors.primary, width: 1.5)
                        : hasActivities
                            ? Border.all(color: colors.primary.withValues(alpha: 0.3), width: 1)
                            : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isToday
                              ? colors.primary
                              : hasActivities
                                  ? colors.foreground
                                  : colors.mutedFg,
                          fontWeight: (hasActivities || isToday)
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (hasActivities)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
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
    );
  }
}
