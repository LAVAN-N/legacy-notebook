import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar.dart';
import '../../../data/models/customer.dart';

class CustomerContextCard extends StatelessWidget {
  const CustomerContextCard({
    super.key,
    required this.customer,
    required this.onEditPhone,
    required this.onAddNominee,
  });

  final Customer customer;
  final ValueChanged<String> onEditPhone;
  final VoidCallback onAddNominee;

  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openMap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Avatar, Name, Code)
            Row(
              children: [
                Avatar(name: customer.name, photoUrl: customer.photoUrl, size: 56),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: AppTypography.headlineMedium.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            customer.customerCode,
                            style: AppTypography.labelMedium.copyWith(
                              color: colors.mutedFg,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (customer.status != 'ACTIVE')
                            Container(
                              decoration: BoxDecoration(
                                color: colors.danger.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Text(
                                customer.status,
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.danger,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            // Contact Block with Tap-to-Call
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Primary Phone',
                        style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                      ),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => _callPhone(customer.phone),
                        child: Row(
                          children: [
                            Icon(Icons.call, size: 16, color: colors.primary),
                            const SizedBox(width: 6),
                            Text(
                              customer.phone,
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, size: 18, color: colors.mutedFg),
                  onPressed: () {
                    // Quick Phone Editor pop-up
                    _showPhoneEditDialog(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Guardian/Spouse Info
            if (customer.guardianName != null) ...[
              Text(
                'Guardian / Spouse',
                style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
              ),
              const SizedBox(height: 2),
              Text(
                customer.guardianName!,
                style: AppTypography.bodyMedium.copyWith(color: colors.foreground),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Address Block
            Text(
              'Address',
              style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
            ),
            const SizedBox(height: 2),
            Text(
              customer.address,
              style: AppTypography.bodyMedium.copyWith(color: colors.foreground),
            ),
            if (customer.landmark != null) ...[
              const SizedBox(height: 4),
              Text(
                'Landmark: ${customer.landmark!}',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.mutedFg,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            // Location URL Directions Trigger
            Row(
              children: [
                if (customer.locationUrl != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openMap(customer.locationUrl!),
                      icon: const Icon(Icons.location_on),
                      label: const Text('GET DIRECTIONS'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.location_on),
                      label: const Text('NO LOCATION URL'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: onAddNominee,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.person_add, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPhoneEditDialog(BuildContext context) {
    final controller = TextEditingController(text: customer.phone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Phone Number'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Enter new 10-digit phone',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onEditPhone(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }
}
