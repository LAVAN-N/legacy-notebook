import 'package:flutter/services.dart';

/// Haptic feedback wrappers for consistent tactile responses.
class AppHaptics {
  AppHaptics._();

  /// Light impact — for taps, chip selections
  static Future<void> lightImpact() => HapticFeedback.lightImpact();

  /// Medium impact — for primary actions (Collect, Save)
  static Future<void> mediumImpact() => HapticFeedback.mediumImpact();

  /// Heavy impact — not used in v1, reserved for destructive actions
  static Future<void> heavyImpact() => HapticFeedback.heavyImpact();

  /// Selection click — for toggle switches, segmented controls
  static Future<void> selectionClick() => HapticFeedback.selectionClick();
}
