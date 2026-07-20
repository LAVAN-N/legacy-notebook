import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';

enum TagType {
  pending,
  inProgress,
  done,
  partial,
  carryForward,
  noOutstanding,
}

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.type,
    this.customLabel,
    this.icon,
  });

  final TagType type;
  final String? customLabel;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color bg;
    Color fg;
    String label;
    Widget typeIcon;

    switch (type) {
      case TagType.pending:
        bg = colors.muted;
        fg = colors.mutedFg;
        label = 'Pending';
        typeIcon = Icon(Icons.hourglass_empty, size: 14, color: fg);
        break;
      case TagType.inProgress:
        bg = colors.warning.withValues(alpha: 0.12);
        fg = colors.warning;
        label = 'In Progress';
        typeIcon = Icon(Icons.play_circle_outline, size: 14, color: fg);
        break;
      case TagType.done:
        bg = colors.success.withValues(alpha: 0.12);
        fg = colors.success;
        label = 'Collected';
        typeIcon = Icon(Icons.check_circle_outline, size: 14, color: fg);
        break;
      case TagType.partial:
        bg = colors.primary.withValues(alpha: 0.12);
        fg = colors.primary;
        label = 'Partial';
        typeIcon = Icon(Icons.pie_chart_outline, size: 14, color: fg);
        break;
      case TagType.carryForward:
        bg = colors.background;
        fg = colors.mutedFg;
        label = 'Carry Fwd';
        typeIcon = Icon(Icons.arrow_forward, size: 14, color: fg);
        break;
      case TagType.noOutstanding:
        bg = colors.muted;
        fg = colors.mutedFg;
        label = 'No Dues';
        typeIcon = Icon(Icons.done_all, size: 14, color: fg);
        break;
    }

    final finalLabel = customLabel ?? label;
    final finalIcon = icon ?? typeIcon;

    return Semantics(
      label: 'Status chip: $finalLabel',
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: type == TagType.carryForward
              ? Border.all(color: fg)
              : null, // Let carryForward stand out via outline/borders
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            finalIcon,
            const SizedBox(width: 4),
            Text(
              finalLabel,
              style: AppTypography.labelSmall.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
