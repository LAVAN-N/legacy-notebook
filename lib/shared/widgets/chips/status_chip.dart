import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_colors.dart';

/// Status chip with icon and label.
/// Displays status information with consistent iconography and color coding.
class StatusChip extends StatelessWidget {
  final String status;
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const StatusChip({
    required this.status,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  /// Factory constructor for common statuses.
  factory StatusChip.fromStatus(String status) {
    final color = AppColors.getStatusColor(status);

    IconData? icon;
    String label = status;

    switch (status.toLowerCase()) {
      case 'pending':
        icon = Icons.schedule;
        label = 'Pending';
        break;
      case 'done':
      case 'completed':
        icon = Icons.check_circle;
        label = 'Done';
        break;
      case 'partial':
        icon = Icons.compare_arrows;
        label = 'Partial';
        break;
      case 'carry_forward':
      case 'carryforward':
        icon = Icons.arrow_forward;
        label = 'Carry Forward';
        break;
      case 'no_outstanding':
      case 'nooutstanding':
        icon = Icons.check;
        label = 'No Outstanding';
        break;
      default:
        label = status;
    }

    return StatusChip(
      status: status,
      label: label,
      icon: icon,
      backgroundColor: color.withValues(alpha: 0.2),
      textColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Icon(
                icon,
                size: 16,
                color: textColor ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
