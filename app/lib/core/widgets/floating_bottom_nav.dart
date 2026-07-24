import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Floating pill-shaped bottom navigation bar with 4 tabs
/// - Dashboard, Inventory, Transactions, Profile
/// - Uses blur backdrop, soft shadow, sits 12dp above safe area
class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      // 12dp above safe-area bottom, 16dp left/right
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        12 + mediaQuery.padding.bottom,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: colors.surface.withValues(alpha: 0.92),
              border: Border.all(color: colors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _NavBarItem(
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    isActive: selectedIndex == 0,
                    onTap: () => onTap(0),
                    colors: colors,
                  ),
                ),
                Expanded(
                  child: _NavBarItem(
                    icon: Icons.inventory_2,
                    label: 'Inventory',
                    isActive: selectedIndex == 1,
                    onTap: () => onTap(1),
                    colors: colors,
                  ),
                ),
                Expanded(
                  child: _NavBarItem(
                    icon: Icons.receipt,
                    label: 'Transactions',
                    isActive: selectedIndex == 2,
                    onTap: () => onTap(2),
                    colors: colors,
                  ),
                ),
                Expanded(
                  child: _NavBarItem(
                    icon: Icons.people,
                    label: 'Clients',
                    isActive: selectedIndex == 3,
                    onTap: () => onTap(3),
                    colors: colors,
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

/// Individual navigation bar item with icon + label
class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? colors.primary : colors.mutedFg,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isActive ? colors.primary : colors.mutedFg,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
