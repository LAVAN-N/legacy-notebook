import 'package:flutter/material.dart';

/// Material 3 Semantic Colors and Custom Palette.
/// This class provides consistent color usage across the application.
class AppColors {
  // Material 3 Semantic Colors
  // These are derived from the theme but provided here for reference

  // Status colors (never use red for money)
  static const Color success = Color(0xFF28A745); // Green for collections
  static const Color pending = Color(0xFFFFC107); // Amber for pending
  static const Color carry = Color(0xFF6C757D); // Grey for carry forward
  static const Color error = Color(0xFFDC3545); // Red for errors only
  static const Color info = Color(0xFF17A2B8); // Blue for info/sales

  // Neutral grays
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454E);
  static const Color outline = Color(0xFF79747E);

  // Skeleton loading
  static const Color skeletonShimmer = Color(0xFFF0F0F0);

  // Amount display colors
  static const Color amountNormal = Color(0xFF1C1B1F);
  static const Color amountPositive = success; // Green
  static const Color amountNegative = error; // Red (if negative balance)

  /// Get status color based on status string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
      case 'completed':
        return success;
      case 'partial':
      case 'pending':
        return pending;
      case 'carry_forward':
      case 'carryforward':
        return carry;
      case 'error':
      case 'failed':
        return error;
      default:
        return onSurface;
    }
  }

  /// Get activity type color
  static Color getActivityTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
      case 'partial_payment':
        return success;
      case 'sale':
      case 'advance':
        return info;
      case 'carry_forward':
        return carry;
      default:
        return onSurface;
    }
  }
}
