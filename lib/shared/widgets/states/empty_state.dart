import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../buttons/primary_button.dart';

/// Empty state widget - shown when there is no data to display.
class EmptyState extends StatelessWidget {
  final String headline;
  final String? subtext;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyState({
    required this.headline,
    this.subtext,
    this.icon = Icons.inbox_outlined,
    this.onActionPressed,
    this.actionLabel,
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
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (subtext != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                subtext!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onActionPressed!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
