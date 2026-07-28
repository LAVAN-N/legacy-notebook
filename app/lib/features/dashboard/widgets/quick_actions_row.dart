import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/router/routes.dart';
import '../../inventory/widgets/add_product_sheet.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuickActionItem(
          label: 'Collect Money',
          icon: Icons.account_balance_wallet_outlined,
          color: colors.primary,
          onTap: () {
            // Direct route explorer jump to weekday
            context.go(Routes.weekday('Thursday'));
          },
        ),
        _QuickActionItem(
          label: 'New Client Sale',
          icon: Icons.person_add_alt_1_outlined,
          color: colors.success,
          onTap: () {
            // Navigate to new client form
            context.go(Routes.newClient);
          },
        ),
        _QuickActionItem(
          label: 'Add Product',
          icon: Icons.add_box_outlined,
          color: colors.warning,
          onTap: () {
            // Show bottom sheet to add product
            showAddProductSheet(context);
          },
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
