import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../buttons/primary_button.dart';

/// Error state widget - shown when loading fails.
class ErrorState extends StatelessWidget {
  final String headline;
  final String? message;
  final IconData icon;
  final VoidCallback? onRetryPressed;
  final String retryLabel;
  final VoidCallback? onContactPressed;
  final String? contactLabel;

  const ErrorState({
    this.headline = 'Something went wrong',
    this.message,
    this.icon = Icons.error_outline,
    this.onRetryPressed,
    this.retryLabel = 'Retry',
    this.onContactPressed,
    this.contactLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (onRetryPressed != null)
              PrimaryButton(
                label: retryLabel,
                onPressed: onRetryPressed!,
              ),
            if (onContactPressed != null && contactLabel != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: onContactPressed!,
                child: Text(contactLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
