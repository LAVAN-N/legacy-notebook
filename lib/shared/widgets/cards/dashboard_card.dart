import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

/// Primary dashboard hero card - filled tonal with emphasis.
class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;

  const DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppSpacing.heroCardRadius,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(radius),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.grey.shade300,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
