import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_spacing.dart';

/// Primary action button (filled, elevated).
/// Used for the most important action on a screen.
/// WCAG 2.1 AA compliant with semantic labels and haptic feedback.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isEnabled;
  
  /// Semantic label for screen readers. If null, uses the label text.
  final String? semanticLabel;
  
  /// Tooltip to display on long press or hover for icon-only buttons.
  final String? tooltip;

  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppSpacing.primaryButtonHeight,
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
                Theme.of(context).colorScheme.onPrimary,
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

    // Create the button with tooltip support for icon-only buttons
    Widget buttonWidget = SizedBox(
      width: width,
      height: height,
      child: FilledButton(
        onPressed: isEnabled && !isLoading
            ? () {
                // Provide haptic feedback on button press
                HapticFeedback.mediumImpact();
                onPressed();
              }
            : null,
        child: child,
      ),
    );

    // Add tooltip if provided or if button is icon-only (best practice)
    final tooltipText = tooltip ?? (icon != null && label.isEmpty ? label : null);
    if (tooltipText != null && tooltipText.isNotEmpty) {
      buttonWidget = Tooltip(
        message: tooltipText,
        child: buttonWidget,
      );
    }

    // Wrap in Semantics for accessibility
    return Semantics(
      button: true,
      onTap: isEnabled && !isLoading ? onPressed : null,
      label: semanticLabel ?? label,
      focusable: isEnabled,
      enabled: isEnabled,
      child: buttonWidget,
    );
  }
}
