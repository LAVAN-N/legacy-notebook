import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ConfirmSnackbar {
  ConfirmSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
    String undoLabel = 'UNDO',
    Duration duration = const Duration(seconds: 5),
  }) {
    final colors = context.colors;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(color: colors.primaryFg),
        ),
        backgroundColor: colors.primary,
        duration: duration,
        action: SnackBarAction(
          label: undoLabel,
          textColor: colors.accent,
          onPressed: onUndo,
        ),
      ),
    );
  }
}
