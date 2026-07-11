import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system using Plus Jakarta Sans (display) + Space Grotesk (numeric).
class AppTypography {
  AppTypography._();

  /// Display font for all UI text
  static TextStyle get _displayBase => GoogleFonts.plusJakartaSans();

  /// Numeric font for currency and numbers
  static TextStyle get numericBase => GoogleFonts.spaceGrotesk(
        fontFeatures: [const FontFeature.tabularFigures()],
        letterSpacing: -0.02,
      );

  // ─── Display ───────────────────────────────────────
  static TextStyle get displayLarge => _displayBase.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get displayMedium => _displayBase.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  // ─── Headline ──────────────────────────────────────
  static TextStyle get headlineLarge => _displayBase.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get headlineMedium => _displayBase.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  // ─── Title ─────────────────────────────────────────
  static TextStyle get titleLarge => _displayBase.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  static TextStyle get titleMedium => _displayBase.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.35,
      );

  static TextStyle get titleSmall => _displayBase.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ─── Body ──────────────────────────────────────────
  static TextStyle get bodyLarge => _displayBase.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _displayBase.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // ─── Caption / Overline ────────────────────────────
  static TextStyle get caption => _displayBase.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get overline => _displayBase.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.5,
      );

  // ─── Label ─────────────────────────────────────────
  static TextStyle get labelLarge => _displayBase.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get labelMedium => _displayBase.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get labelSmall => _displayBase.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // ─── Currency (always numeric font) ────────────────
  static TextStyle get currencyLarge => numericBase.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get currencyMedium => numericBase.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  static TextStyle get currencySmall => numericBase.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  /// Build a complete TextTheme for Material
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
