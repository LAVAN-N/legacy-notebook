import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../router/navigation_shell.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../../data/providers.dart';

class BreadcrumbsBar extends ConsumerWidget {
  const BreadcrumbsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(placesStreamProvider);
    ref.watch(areasStreamProvider);
    ref.watch(customersStreamProvider);

    final breadcrumbs = context.getBreadcrumbs();
    final colors = context.colors;

    if (breadcrumbs.length <= 1) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 24,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: breadcrumbs.length,
        separatorBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              Icons.chevron_right,
              size: 14,
              color: colors.mutedFg,
            ),
          );
        },
        itemBuilder: (context, index) {
          final crumb = breadcrumbs[index];
          final isLast = index == breadcrumbs.length - 1;

          if (isLast || crumb.route == null) {
            return Center(
              child: Text(
                crumb.label,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.foreground.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return Center(
            child: InkWell(
              onTap: () => context.go(crumb.route!),
              borderRadius: BorderRadius.circular(4),
              child: Text(
                crumb.label,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
