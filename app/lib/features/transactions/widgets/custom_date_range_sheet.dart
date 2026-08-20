import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';

class CustomDateRangePicker extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime? start, DateTime? end) onRangeChanged;

  const CustomDateRangePicker({
    super.key,
    this.startDate,
    this.endDate,
    required this.onRangeChanged,
  });

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  late int _selectedYear;
  late int _selectedMonth; // 1 - 12

  static const List<String> _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (widget.startDate != null) {
      _selectedYear = widget.startDate!.year;
      _selectedMonth = widget.startDate!.month;
    } else {
      _selectedYear = now.year;
      _selectedMonth = now.month;
    }
  }

  @override
  void didUpdateWidget(covariant CustomDateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startDate != null && widget.startDate != oldWidget.startDate) {
      if (_selectedYear != widget.startDate!.year || _selectedMonth != widget.startDate!.month) {
        setState(() {
          _selectedYear = widget.startDate!.year;
          _selectedMonth = widget.startDate!.month;
        });
      }
    }
  }

  void _onDateTapped(DateTime date) {
    if (widget.startDate == null) {
      widget.onRangeChanged(date, null);
    } else if (widget.endDate == null) {
      if (date.isBefore(widget.startDate!)) {
        widget.onRangeChanged(date, widget.startDate);
      } else {
        widget.onRangeChanged(widget.startDate, date);
      }
    } else {
      // Reset to new start date
      widget.onRangeChanged(date, null);
    }
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime date) {
    if (widget.startDate == null || widget.endDate == null) return false;
    return date.isAfter(widget.startDate!) && date.isBefore(widget.endDate!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();

    final daysInMonth = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
    final firstDayOfWeek = DateTime(_selectedYear, _selectedMonth, 1).weekday % 7; // 0 = Sunday
    final hasActiveRange = widget.startDate != null || widget.endDate != null;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.8)),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Range Status & Clear Button (Left) + Direct Scrollable Month & Year Wheels (Right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Date Range',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.foreground,
                          ),
                        ),
                        if (hasActiveRange) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.onRangeChanged(null, null),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.muted.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.close_rounded, size: 12, color: colors.mutedFg),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: colors.mutedFg,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.startDate == null
                          ? 'Select start & end date'
                          : (widget.endDate == null
                              ? '${dateShort(widget.startDate!)} - Select end'
                              : '${dateShort(widget.startDate!)} - ${dateShort(widget.endDate!)} (${widget.endDate!.difference(widget.startDate!).inDays + 1}d)'),
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.startDate != null ? colors.primary : colors.mutedFg,
                        fontWeight: widget.startDate != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Directly Scrollable Month & Year Wheel
              _InlineMonthYearWheel(
                selectedYear: _selectedYear,
                selectedMonth: _selectedMonth,
                onChanged: (year, month) {
                  setState(() {
                    _selectedYear = year;
                    _selectedMonth = month;
                  });
                },
                colors: colors,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Divider(height: 1, color: colors.border.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.xs),

          // Full-Width Calendar Grid
          SizedBox(
            height: 200,
            child: Column(
              children: [
                // Weekdays Header (S, M, T, W, T, F, S)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: _weekdays.map((day) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.mutedFg,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // 6 Weeks Rows
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (weekIndex) {
                      return Row(
                        children: List.generate(7, (dayIndex) {
                          final slotIndex = weekIndex * 7 + dayIndex;
                          final dayNumber = slotIndex - firstDayOfWeek + 1;

                          if (dayNumber < 1 || dayNumber > daysInMonth) {
                            return const Expanded(child: SizedBox(height: 28));
                          }

                          final date = DateTime(_selectedYear, _selectedMonth, dayNumber);
                          final isStart = _isSameDay(widget.startDate, date);
                          final isEnd = _isSameDay(widget.endDate, date);
                          final isInRange = _isInRange(date);
                          final isTodayDate = _isSameDay(now, date);

                          // Range highlight background
                          Decoration? rangeBackground;
                          if (isInRange) {
                            rangeBackground = BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                            );
                          } else if (isStart && widget.endDate != null && !_isSameDay(widget.startDate, widget.endDate)) {
                            rangeBackground = BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                            );
                          } else if (isEnd && widget.startDate != null && !_isSameDay(widget.startDate, widget.endDate)) {
                            rangeBackground = BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                            );
                          }

                          return Expanded(
                            child: Container(
                              height: 28,
                              decoration: rangeBackground,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _onDateTapped(date),
                                child: Center(
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (isStart || isEnd)
                                          ? colors.primary
                                          : Colors.transparent,
                                      border: isTodayDate && !isStart && !isEnd
                                          ? Border.all(color: colors.primary, width: 1.0)
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$dayNumber',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: (isStart || isEnd || isTodayDate)
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: (isStart || isEnd)
                                              ? colors.primaryFg
                                              : (isInRange
                                                  ? colors.primary
                                                  : colors.foreground),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact inline 2-column scroll wheel for Month and Year
class _InlineMonthYearWheel extends StatefulWidget {
  final int selectedYear;
  final int selectedMonth;
  final void Function(int year, int month) onChanged;
  final AppColors colors;

  const _InlineMonthYearWheel({
    required this.selectedYear,
    required this.selectedMonth,
    required this.onChanged,
    required this.colors,
  });

  @override
  State<_InlineMonthYearWheel> createState() => _InlineMonthYearWheelState();
}

class _InlineMonthYearWheelState extends State<_InlineMonthYearWheel> {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  late final List<int> _years;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;
  int _lastReportedMonth = -1;
  int _lastReportedYear = -1;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _years = List.generate(21, (i) => currentYear - 10 + i);

    _lastReportedMonth = widget.selectedMonth;
    _lastReportedYear = widget.selectedYear;

    final monthIndex = (widget.selectedMonth - 1).clamp(0, 11);
    final yearIndex = _years.indexOf(widget.selectedYear).clamp(0, _years.length - 1);

    _monthController = FixedExtentScrollController(initialItem: monthIndex);
    _yearController = FixedExtentScrollController(initialItem: yearIndex >= 0 ? yearIndex : 10);
  }

  @override
  void didUpdateWidget(covariant _InlineMonthYearWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMonth != oldWidget.selectedMonth) {
      final monthIndex = (widget.selectedMonth - 1).clamp(0, 11);
      _lastReportedMonth = widget.selectedMonth;
      if (_monthController.hasClients && _monthController.selectedItem != monthIndex) {
        _monthController.jumpToItem(monthIndex);
      }
    }
    if (widget.selectedYear != oldWidget.selectedYear) {
      final yearIndex = _years.indexOf(widget.selectedYear).clamp(0, _years.length - 1);
      _lastReportedYear = widget.selectedYear;
      if (_yearController.hasClients && _yearController.selectedItem != yearIndex) {
        _yearController.jumpToItem(yearIndex);
      }
    }
  }

  @override
  void dispose() {
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _notifyChange(int year, int month) {
    if (year != _lastReportedYear || month != _lastReportedMonth) {
      _lastReportedYear = year;
      _lastReportedMonth = month;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged(year, month);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double itemHeight = 18.0;
    const double totalHeight = itemHeight * 3; // 54.0px viewport (3 items visible)

    return Container(
      width: 140,
      height: totalHeight,
      decoration: BoxDecoration(
        color: widget.colors.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.colors.border.withValues(alpha: 0.6)),
      ),
      child: Stack(
        children: [
          // Middle Focus Highlight Capsule
          Positioned(
            top: itemHeight,
            left: 3,
            right: 3,
            height: itemHeight,
            child: Container(
              decoration: BoxDecoration(
                color: widget.colors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: widget.colors.primary.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
            ),
          ),

          // Scroll Wheels (Month on left, Year on right)
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [0.0, 0.22, 0.78, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Row(
              children: [
                // Month Scroll Wheel
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: _monthController,
                    itemExtent: itemHeight,
                    physics: const FixedExtentScrollPhysics(),
                    perspective: 0.0001,
                    diameterRatio: 50.0,
                    overAndUnderCenterOpacity: 0.3,
                    onSelectedItemChanged: (index) {
                      if (index >= 0 && index < _months.length) {
                        _notifyChange(_lastReportedYear, index + 1);
                      }
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: _months.length,
                      builder: (context, index) {
                        final isSelected = widget.selectedMonth == index + 1;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _monthController.animateToItem(
                              index,
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Center(
                            child: Text(
                              _months[index],
                              style: TextStyle(
                                fontSize: isSelected ? 12 : 10.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? widget.colors.primary : widget.colors.foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Container(
                  width: 1,
                  height: itemHeight,
                  color: widget.colors.border.withValues(alpha: 0.4),
                ),

                // Year Scroll Wheel
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: _yearController,
                    itemExtent: itemHeight,
                    physics: const FixedExtentScrollPhysics(),
                    perspective: 0.0001,
                    diameterRatio: 50.0,
                    overAndUnderCenterOpacity: 0.3,
                    onSelectedItemChanged: (index) {
                      if (index >= 0 && index < _years.length) {
                        _notifyChange(_years[index], _lastReportedMonth);
                      }
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: _years.length,
                      builder: (context, index) {
                        final year = _years[index];
                        final isSelected = widget.selectedYear == year;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _yearController.animateToItem(
                              index,
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Center(
                            child: Text(
                              '$year',
                              style: TextStyle(
                                fontSize: isSelected ? 12 : 10.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? widget.colors.primary : widget.colors.foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
