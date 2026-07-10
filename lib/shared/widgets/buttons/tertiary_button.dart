import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_colors.dart';

/// Tertiary action button (outlined).
/// Used for less important actions or destructive actions (with caution).
class TertiaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isEnabled;
  final bool isDestructive;

  const TertiaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppSpacing.secondaryButtonHeight,
    this.isEnabled = true,
    this.isDestructive = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDestructive ? AppColors.error : null;

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(textColor),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppSpacing.iconDefault),
                  const SizedBox(width: AppSpacing.sm),
                  Text(label),
                ],
              )
            : Text(label);

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: textColor != null
            ? OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: BorderSide(color: textColor),
              )
            : null,
        child: child,
      ),
    );
  }
}
