import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_spacing.dart';

/// Secondary action button (filled tonal).
/// Used for secondary actions that support the primary action.
/// WCAG 2.1 AA compliant with semantic labels and haptic feedback.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isEnabled;
  
  /// Semantic label for screen readers. If null, uses the label text.
  final String? semanticLabel;
  
  /// Tooltip for icon-only buttons.
  final String? tooltip;

  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppSpacing.secondaryButtonHeight,
    this.isEnabled = true,
    this.semanticLabel,
    this.tooltip,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.onSecondaryContainer,
              ),
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

    Widget buttonWidget = SizedBox(
      width: width,
      height: height,
      child: FilledButton.tonal(
        onPressed: isEnabled && !isLoading
            ? () {
                HapticFeedback.mediumImpact();
                onPressed();
              }
            : null,
        child: child,
      ),
    );

    // Add tooltip if provided
    final tooltipText = tooltip ?? (icon != null && label.isEmpty ? label : null);
    if (tooltipText != null && tooltipText.isNotEmpty) {
      buttonWidget = Tooltip(
        message: tooltipText,
        child: buttonWidget,
      );
    }

    return Semantics(
      enabled: isEnabled,
      button: true,
      onTap: isEnabled && !isLoading ? onPressed : null,
      label: semanticLabel ?? label,
      focusable: isEnabled,
      child: buttonWidget,
    );
  }
}
