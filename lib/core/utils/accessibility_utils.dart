import 'package:flutter/material.dart';

/// Semantic labels for common actions.
class SemanticLabels {
  static const String collectPayment = 'Collect payment from customer';
  static const String newSale = 'Record new sale';
  static const String findCustomer = 'Search for customer';
  static const String viewInventory = 'View inventory items';
  static const String startCollecting = 'Start collecting for today\'s route';
  static const String selectWeekday = 'Select weekday to view route';
  static const String seeAll = 'See all activities';
  static const String notifications = 'View notifications';
  static const String profileSettings = 'Open profile and settings';
  static const String retry = 'Retry loading data';
}

/// Accessibility utilities for WCAG 2.1 AA compliance.
/// 
/// This module provides:
/// - Semantic labels for screen readers
/// - Contrast ratio validation helpers
/// - Haptic feedback utilities
/// - Text scaling support
class AccessibilityUtils {
  /// Standard haptic feedback intensities.
  static const hapticDuration = Duration(milliseconds: 50);

  /// Minimum contrast ratio for WCAG AA compliance: 4.5:1 for normal text.
  static const double wcagAAContrastRatioNormal = 4.5;

  /// Minimum contrast ratio for WCAG AA compliance: 3:1 for large text.
  static const double wcagAAContrastRatioLarge = 3.0;

  /// Generate semantic label for avatar with customer initials.
  static String avatarLabel(String name, String initials) {
    return '$name, avatar with initials $initials';
  }

  /// Generate semantic label for activity row.
  static String activityLabel({
    required String customerName,
    required String activityType,
    required String amount,
    required String timeAgo,
  }) {
    return '$customerName, $activityType transaction for $amount, $timeAgo';
  }

  /// Generate semantic label for status chip.
  static String statusChipLabel(String status, {String? count}) {
    final baseLabel = '$status status';
    return count != null ? '$baseLabel, $count items' : baseLabel;
  }

  /// Generate semantic label for summary card.
  static String summaryCardLabel(String label, String value) {
    return '$label: $value';
  }

  /// Generate semantic label for progress bar.
  static String progressLabel({
    required String label,
    required int collected,
    required int expected,
    required int percentage,
  }) {
    return '$label: $collected out of $expected collected, $percentage percent complete';
  }

  /// Generate semantic label for route card.
  static String routeCardLabel({
    required String weekday,
    required int places,
    required int areas,
    required int customers,
    required int expected,
  }) {
    return '$weekday\'s route: $places places, $areas areas, $customers customers, $expected rupees expected';
  }

  /// Generate semantic label for weekday chip.
  static String weekdayChipLabel(String day, int count, {bool isToday = false}) {
    final todayLabel = isToday ? ', today' : '';
    return '$day, $count customers$todayLabel';
  }

  /// Check if color combination meets WCAG AA contrast ratio.
  /// Returns true if contrast >= 4.5:1 (or 3:1 for large text).
  static bool hasMinimumContrast(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    final contrastRatio = getContrastRatio(foreground, background);
    final minimumRatio = isLargeText
        ? wcagAAContrastRatioLarge
        : wcagAAContrastRatioNormal;
    return contrastRatio >= minimumRatio;
  }

  /// Calculate WCAG contrast ratio between two colors.
  /// Formula: (L1 + 0.05) / (L2 + 0.05), where L is relative luminance.
  static double getContrastRatio(Color color1, Color color2) {
    final l1 = _getRelativeLuminance(color1);
    final l2 = _getRelativeLuminance(color2);

    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calculate relative luminance of a color according to WCAG formula.
  static double _getRelativeLuminance(Color color) {
    final r = _gammaAdjust(color.r);
    final g = _gammaAdjust(color.g);
    final b = _gammaAdjust(color.b);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Gamma adjustment for luminance calculation.
  static double _gammaAdjust(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return Math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Format error message for screen readers with clear guidance.
  static String formatErrorMessage(String error, {String? action}) {
    final actionText = action != null ? ' To retry, $action.' : '';
    return 'Error: $error.$actionText';
  }

  /// Format validation error for accessibility.
  static String formatValidationError(String fieldName, String reason) {
    return '$fieldName is invalid. $reason. Please correct this field.';
  }

  /// Format amount for screen reader announcement.
  static String formatAmountForA11y(int amount) {
    final formatted = _formatIndianNumber(amount);
    // Spell out currency for clarity
    return 'Rupees $formatted';
  }

  /// Helper to format number in Indian numbering system for a11y.
  static String _formatIndianNumber(int amount) {
    if (amount == 0) return 'zero';
    if (amount < 0) return 'minus ${_formatIndianNumber(-amount)}';

    final numStr = amount.toString();
    if (numStr.length <= 3) {
      return numStr;
    }

    // Break into groups for clearer reading
    final result = StringBuffer();
    final len = numStr.length;

    // Hundreds place
    if (len > 3) {
      result.write(numStr.substring(0, len - 3));
      result.write(' thousand ');
    }

    // Last three digits
    result.write(numStr.substring(len - 3));

    return result.toString();
  }

  /// Get semantic role description for button types.
  static String getButtonRoleDescription(String buttonType) {
    switch (buttonType) {
      case 'primary':
        return 'Primary action button';
      case 'secondary':
        return 'Secondary action button';
      case 'tertiary':
        return 'Tertiary action button';
      default:
        return 'Button';
    }
  }

  /// Get semantic label for navigation item.
  static String getNavItemLabel(String label, {bool isSelected = false}) {
    final selected = isSelected ? ', selected' : '';
    return '$label$selected';
  }
}

/// Math helper for accessibility calculations.
class Math {
  static double pow(double base, double exponent) {
    return base == 0
        ? 0
        : (base < 0 && exponent % 1 != 0)
            ? double.nan
            : _power(base.abs(), exponent) * (base < 0 && exponent % 1 == 1 ? -1 : 1);
  }

  static double _power(double base, double exp) {
    if (exp == 0) return 1;
    if (base == 0) return 0;
    if (base == 1) return 1;

    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}

/// Extension for adding accessibility to BuildContext.
extension AccessibilityContextExtension on BuildContext {
  /// Get the current text scale factor from MediaQuery.
  double getTextScaleFactor() {
    return MediaQuery.of(this).textScaler.scale(1.0);
  }

  /// Check if high contrast mode is enabled.
  bool isHighContrastMode() {
    return MediaQuery.of(this).highContrast;
  }

  /// Announce a message to screen readers.
  Future<void> announceToAccessibility(String message) async {
    // SemanticsService is not available in all contexts, so we use a try-catch
    try {
      // For now, just print to debug. In production, use native platform channels
      // await SemanticsService.announce(message);
    } catch (e) {
      // Silently fail if not available
    }
  }

  /// Get responsive font size based on text scale factor.
  double getResponsiveFontSize(double baseSize) {
    return baseSize * getTextScaleFactor();
  }
}
