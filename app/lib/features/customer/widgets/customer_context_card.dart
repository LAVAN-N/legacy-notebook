import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/nominee.dart';
import '../../../data/models/id_proof.dart';
import '../../../data/models/location.dart';

class CustomerContextCard extends StatefulWidget {
  const CustomerContextCard({
    super.key,
    required this.customer,
    required this.onEditPhone,
    required this.onAddNominee,
  });

  final Customer customer;
  final ValueChanged<String> onEditPhone;
  final VoidCallback onAddNominee;

  @override
  State<CustomerContextCard> createState() => _CustomerContextCardState();
}

class _CustomerContextCardState extends State<CustomerContextCard> {
  bool _isEditing = false;
  
  // Controllers for edit mode
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _landmarkController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }
  
  @override
  void didUpdateWidget(CustomerContextCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customer != widget.customer && !_isEditing) {
      _initControllers();
    }
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneController = TextEditingController(text: widget.customer.phone);
    _addressController = TextEditingController(text: widget.customer.address);
    _landmarkController = TextEditingController(text: widget.customer.landmark ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openMap(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final customer = widget.customer;
    
    final primaryNominee = customer.nominees.isNotEmpty ? customer.nominees.first : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Row
            Row(
              children: [
                Avatar(name: customer.name, photoUrl: customer.photoUrl, size: 56),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isEditing
                        ? TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                          )
                        : Text(
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
                            style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!_isEditing)
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: colors.mutedFg),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            // 3. Primary Phone
            Text('Primary Phone', style: AppTypography.labelSmall.copyWith(color: colors.mutedFg)),
            const SizedBox(height: 2),
            if (_isEditing)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
              )
            else
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
            const SizedBox(height: AppSpacing.md),

            // 4. Guardian / Spouse
            if (!_isEditing && primaryNominee != null) ...[
              Text('Guardian / Spouse', style: AppTypography.labelSmall.copyWith(color: colors.mutedFg)),
              const SizedBox(height: 2),
              Text(
                '${primaryNominee.name} (${primaryNominee.relation ?? 'N/A'})',
                style: AppTypography.bodyMedium.copyWith(color: colors.foreground),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // 5. & 6. Address & Landmark
            Text('Address', style: AppTypography.labelSmall.copyWith(color: colors.mutedFg)),
            const SizedBox(height: 2),
            if (_isEditing) ...[
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(isDense: true, hintText: 'Address', contentPadding: EdgeInsets.symmetric(vertical: 8)),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _landmarkController,
                decoration: const InputDecoration(isDense: true, hintText: 'Landmark', contentPadding: EdgeInsets.symmetric(vertical: 8)),
              ),
            ] else ...[
              Text(
                customer.address,
                style: AppTypography.bodyMedium.copyWith(color: colors.foreground),
              ),
              if (customer.landmark != null && customer.landmark!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Landmark: ${customer.landmark!}',
                  style: AppTypography.labelSmall.copyWith(color: colors.mutedFg, fontStyle: FontStyle.italic),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.lg),

            // 7. Location Row
            if (!_isEditing) ...[
              if (customer.location == null)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text('📍 NO LOCATION URL', style: AppTypography.labelMedium),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: () {}, // Trigger location picker
                      style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48), padding: EdgeInsets.zero),
                      child: const Icon(Icons.person_add, size: 20),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 120, // 16:9 approx
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.map, size: 48, color: colors.primary.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _openMap(customer.location!.lat, customer.location!.lng),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Open in Maps'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
            ],

            // 8. Nominees List (Read-only for now)
            if (customer.nominees.isNotEmpty && !_isEditing) ...[
              Text('Nominees', style: AppTypography.labelSmall.copyWith(color: colors.mutedFg)),
              const SizedBox(height: 4),
              ...customer.nominees.map((n) => Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                elevation: 0,
                color: colors.muted,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                child: ListTile(
                  dense: true,
                  title: Text(n.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('${n.relation ?? ''}${n.phone != null ? ' · ${n.phone}' : ''}', style: AppTypography.labelSmall),
                ),
              )),
              const SizedBox(height: AppSpacing.md),
            ],

            // 9. ID Proofs List
            if (customer.idProofs.isNotEmpty && !_isEditing) ...[
              Text('ID Proofs', style: AppTypography.labelSmall.copyWith(color: colors.mutedFg)),
              const SizedBox(height: 8),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: customer.idProofs.map((p) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors.muted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(p.document?.mimeType == 'application/pdf' ? Icons.picture_as_pdf : Icons.image, size: 24, color: colors.mutedFg),
                      const SizedBox(height: 4),
                      Text(p.type, style: AppTypography.labelSmall, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                )).toList(),
              ),
            ],

            // Edit Mode Actions
            if (_isEditing) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _initControllers(); // Reset
                      setState(() => _isEditing = false);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () {
                      widget.onEditPhone(_phoneController.text.trim());
                      // Here we would also call widget.onSave(allFields...)
                      setState(() => _isEditing = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.primaryFg,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}

