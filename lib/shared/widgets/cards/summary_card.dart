import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

/// Summary card for displaying metric + value.
class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;
  final VoidCallback? onTap;

  const SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (subValue != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subValue!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
