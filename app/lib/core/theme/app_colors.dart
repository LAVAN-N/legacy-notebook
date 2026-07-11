import 'package:flutter/material.dart';

/// Semantic color tokens for the app.
/// Warm paper background + deep teal primary + currency green + marigold warn + vermilion danger.
/// Never use raw `Colors.*` in feature code — always use these tokens.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.foreground,
    required this.surface,
    required this.primary,
    required this.primaryFg,
    required this.accent,
    required this.success,
    required this.warning,
    required this.warningFg,
    required this.danger,
    required this.muted,
    required this.mutedFg,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color surface;
  final Color primary;
  final Color primaryFg;
  final Color accent;
  final Color success;
  final Color warning;
  final Color warningFg;
  final Color danger;
  final Color muted;
  final Color mutedFg;
  final Color border;

  /// Light theme color tokens
  static const light = AppColors(
    background: Color(0xFFF8F5EE), // warm off-white paper
    foreground: Color(0xFF1B1F2A),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF0F5D6B), // deep teal
    primaryFg: Color(0xFFF2FBFC),
    accent: Color(0xFFF2C88C), // warm sand accent
    success: Color(0xFF1F8A5B), // currency green
    warning: Color(0xFFD98A2B), // marigold
    warningFg: Color(0xFF3A2408),
    danger: Color(0xFFC0392B), // vermilion overdue
    muted: Color(0xFFEFEBE1),
    mutedFg: Color(0xFF6C6F78),
    border: Color(0xFFE3DED2),
  );

  /// Dark theme color tokens — same hues, lightness flipped
  static const dark = AppColors(
    background: Color(0xFF121418),
    foreground: Color(0xFFE8E6E1),
    surface: Color(0xFF1E2028),
    primary: Color(0xFF3ABDD0), // lighter teal for dark bg
    primaryFg: Color(0xFF0A2A30),
    accent: Color(0xFFE0A850),
    success: Color(0xFF34D399),
    warning: Color(0xFFF5B04A),
    warningFg: Color(0xFFFFF8E1),
    danger: Color(0xFFEF5350),
    muted: Color(0xFF2A2D35),
    mutedFg: Color(0xFF9CA3AF),
    border: Color(0xFF3A3D45),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? foreground,
    Color? surface,
    Color? primary,
    Color? primaryFg,
    Color? accent,
    Color? success,
    Color? warning,
    Color? warningFg,
    Color? danger,
    Color? muted,
    Color? mutedFg,
    Color? border,
  }) {
    return AppColors(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      surface: surface ?? this.surface,
      primary: primary ?? this.primary,
      primaryFg: primaryFg ?? this.primaryFg,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      warningFg: warningFg ?? this.warningFg,
      danger: danger ?? this.danger,
      muted: muted ?? this.muted,
      mutedFg: mutedFg ?? this.mutedFg,
      border: border ?? this.border,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryFg: Color.lerp(primaryFg, other.primaryFg, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningFg: Color.lerp(warningFg, other.warningFg, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedFg: Color.lerp(mutedFg, other.mutedFg, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

/// Extension to access AppColors from BuildContext
extension AppColorsExtension on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
