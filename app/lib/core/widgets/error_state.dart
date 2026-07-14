import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Something went wrong',
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: colors.danger,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  style: AppTypography.headlineMedium.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.mutedFg,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tap to Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.primaryFg,
                    minimumSize: const Size(160, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
