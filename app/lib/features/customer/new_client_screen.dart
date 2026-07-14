import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/utils/formatters.dart';
import '../../core/router/routes.dart';
import '../../data/providers.dart';
import 'new_client_controller.dart';

class NewClientScreen extends ConsumerStatefulWidget {
  const NewClientScreen({super.key});

  @override
  ConsumerState<NewClientScreen> createState() => _NewClientScreenState();
}

class _NewClientScreenState extends ConsumerState<NewClientScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _alternatePhoneController;
  late TextEditingController _addressController;
  late TextEditingController _landmarkController;
  late TextEditingController _nomineeNameController;
  late TextEditingController _idProofNumberController;
  late TextEditingController _openingBalanceController;
  late TextEditingController _placeNameController;
  late TextEditingController _areaNameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _alternatePhoneController = TextEditingController();
    _addressController = TextEditingController();
    _landmarkController = TextEditingController();
    _nomineeNameController = TextEditingController();
    _idProofNumberController = TextEditingController();
    _openingBalanceController = TextEditingController();
    _placeNameController = TextEditingController();
    _areaNameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _nomineeNameController.dispose();
    _idProofNumberController.dispose();
    _placeNameController.dispose();
    _areaNameController.dispose();
    super.dispose();
  }

  void _showAddPlaceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _AddPlaceSheet(controller: _placeNameController),
      isScrollControlled: true,
    );
  }

  void _showAddAreaSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _AddAreaSheet(controller: _areaNameController),
      isScrollControlled: true,
    );
  }

  void _scrollToError(String fieldKey) {
    // Scroll to first error field (simple implementation)
    // In a real app, you'd use Scrollable.ensureVisible or similar
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final formState = ref.watch(newClientControllerProvider);
    final controller = ref.read(newClientControllerProvider.notifier);

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (controller.isDirty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Discard new customer?'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  // Stay on form, snackbar auto-dismisses
                },
              ),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          context.go(Routes.dashboard);
        }
        return true;
      },
      child: AppScaffold(
        showSyncIndicator: false,
        appBarLeading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (controller.isDirty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Discard new customer?'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {},
                  ),
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              context.go(Routes.dashboard);
            }
          },
        ),
        title: const Text('New Credit Sale'),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route Placement Section
                _RouteSection(
                  state: formState,
                  controller: controller,
                  onAddPlace: _showAddPlaceSheet,
                  onAddArea: _showAddAreaSheet,
                  colors: colors,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Customer Details Section
                _CustomerDetailsSection(
                  state: formState,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  alternatePhoneController: _alternatePhoneController,
                  addressController: _addressController,
                  landmarkController: _landmarkController,
                  nomineeNameController: _nomineeNameController,
                  idProofNumberController: _idProofNumberController,
                  controller: controller,
                  colors: colors,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Action Buttons
                _ActionButtons(
                  isLoading: formState.isLoading,
                  onCreateAndSale: () async {
                    final customer = await controller.createAndSale();
                    if (customer != null && mounted) {
                      // Capture ref dependencies before showing snackbar
                      final repository = ref.read(customerRepositoryProvider);
                      final notifier = ref.read(newClientControllerProvider.notifier);
                      
                      // Show snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Customer added · UNDO'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () async {
                              await repository.undoCustomer(customer.id);
                              notifier.resetForm();
                            },
                          ),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      // Navigate to sale screen
                      if (mounted) {
                        context.go(Routes.sale(
                          formState.selectedWeekday,
                          formState.placeId,
                          formState.areaId,
                          customer.id,
                        ));
                      }
                    }
                  },
                  onCreateOnly: () async {
                    final customer = await controller.createOnly();
                    if (customer != null && mounted) {
                      // Capture ref dependencies before showing snackbar
                      final repository = ref.read(customerRepositoryProvider);
                      final notifier = ref.read(newClientControllerProvider.notifier);
                      
                      // Show snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Customer added · UNDO'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () async {
                              await repository.undoCustomer(customer.id);
                              notifier.resetForm();
                            },
                          ),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      // Navigate to customer detail
                      if (mounted) {
                        context.go(Routes.customer(
                          formState.selectedWeekday,
                          formState.placeId,
                          formState.areaId,
                          customer.id,
                        ));
                      }
                    }
                  },
                  colors: colors,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Route Section ───────────────────────────────────────
class _RouteSection extends StatefulWidget {
  const _RouteSection({
    required this.state,
    required this.controller,
    required this.onAddPlace,
    required this.onAddArea,
    required this.colors,
  });

  final NewClientFormState state;
  final NewClientController controller;
  final VoidCallback onAddPlace;
  final VoidCallback onAddArea;
  final AppColors colors;

  @override
  State<_RouteSection> createState() => _RouteSectionState();
}

class _RouteSectionState extends State<_RouteSection> {
  @override
  Widget build(BuildContext context) {
    final weekdayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route Placement',
              style: AppTypography.labelLarge.copyWith(
                color: widget.colors.foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Weekday Chips
            Text('Weekday *', style: AppTypography.labelSmall.copyWith(color: widget.colors.mutedFg)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: weekdayNames.map((day) {
                final isSelected = widget.state.selectedWeekday == day;
                return FilterChip(
                  label: Text(day.substring(0, 3)),
                  selected: isSelected,
                  onSelected: (selected) async {
                    if (selected) {
                      await widget.controller.setWeekday(widget.controller.getWeekdayIdByName(day), day);
                    }
                  },
                  backgroundColor: widget.colors.surface,
                  selectedColor: widget.colors.primary.withOpacity(0.2),
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: isSelected ? widget.colors.primary : widget.colors.mutedFg,
                  ),
                );
              }).toList(),
            ),
            if (widget.state.errors.containsKey('weekday')) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.state.errors['weekday']!,
                style: AppTypography.bodySmall.copyWith(color: widget.colors.destructive),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            // Place Dropdown
            Text('Place *', style: AppTypography.labelSmall.copyWith(color: widget.colors.mutedFg)),
            const SizedBox(height: AppSpacing.sm),
            if (widget.state.places.isEmpty)
              OutlinedButton.icon(
                onPressed: widget.onAddPlace,
                icon: const Icon(Icons.add),
                label: const Text('Add new place'),
              )
            else
              DropdownButtonFormField<String>(
                value: widget.state.placeId.isEmpty ? null : widget.state.placeId,
                items: widget.state.places
                    .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.controller.setPlace(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Select a place',
                  errorText: widget.state.errors['place'],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),

            // Area Dropdown
            Text('Area *', style: AppTypography.labelSmall.copyWith(color: widget.colors.mutedFg)),
            const SizedBox(height: AppSpacing.sm),
            if (widget.state.areas.isEmpty)
              OutlinedButton.icon(
                onPressed: widget.onAddArea,
                icon: const Icon(Icons.add),
                label: const Text('Add new area'),
              )
            else
              DropdownButtonFormField<String>(
                value: widget.state.areaId.isEmpty ? null : widget.state.areaId,
                items: widget.state.areas
                    .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.controller.setArea(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Select an area',
                  errorText: widget.state.errors['area'],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            if (widget.state.errors.containsKey('area')) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.state.errors['area']!,
                style: AppTypography.bodySmall.copyWith(color: widget.colors.destructive),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Customer Details Section ───────────────────────────
class _CustomerDetailsSection extends StatelessWidget {
  const _CustomerDetailsSection({
    required this.state,
    required this.nameController,
    required this.phoneController,
    required this.alternatePhoneController,
    required this.addressController,
    required this.landmarkController,
    required this.nomineeNameController,
    required this.idProofNumberController,
    required this.controller,
    required this.colors,
  });

  final NewClientFormState state;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController alternatePhoneController;
  final TextEditingController addressController;
  final TextEditingController landmarkController;
  final TextEditingController nomineeNameController;
  final TextEditingController idProofNumberController;
  final NewClientController controller;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Details',
              style: AppTypography.labelLarge.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Full Name
            _buildTextField(
              label: 'Full name *',
              controller: nameController,
              onChanged: controller.setName,
              errorText: state.errors['name'],
              hintText: 'e.g., Lakshmi Priya',
              maxLength: 80,
              colors: colors,
            ),
            const SizedBox(height: AppSpacing.md),

            // Phone
            _buildTextField(
              label: 'Phone *',
              controller: phoneController,
              onChanged: controller.setPhone,
              errorText: state.errors['phone'],
              hintText: 'e.g., 98765 43210',
              keyboardType: TextInputType.phone,
              maxLength: 14,
              colors: colors,
            ),
            const SizedBox(height: AppSpacing.md),

            // Alternate Phone
            _buildTextField(
              label: 'Alternate phone',
              controller: alternatePhoneController,
              onChanged: controller.setAlternatePhone,
              hintText: '(optional)',
              keyboardType: TextInputType.phone,
              maxLength: 14,
              colors: colors,
            ),
            const SizedBox(height: AppSpacing.md),

            // Address
            _buildTextField(
              label: 'Address *',
              controller: addressController,
              onChanged: controller.setAddress,
              errorText: state.errors['address'],
              hintText: 'Full address (≤240 chars)',
              maxLines: 3,
              maxLength: 240,
              colors: colors,
            ),
            const SizedBox(height: AppSpacing.md),

            // Landmark
            _buildTextField(
              label: 'Landmark',
              controller: landmarkController,
              onChanged: controller.setLandmark,
              hintText: 'e.g., Near Ganesha Temple',
              maxLength: 120,
              colors: colors,
            ),
            const SizedBox(height: AppSpacing.md),

            // Location Placeholder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: colors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Location', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Map / Get Current Location (Placeholder)', style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.my_location),
                    label: const Text('Fetch Location'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Nominees Placeholder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.muted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nominees', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('No nominees added.', style: AppTypography.bodySmall.copyWith(color: colors.mutedFg)),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add Nominee'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ID Proofs Placeholder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.muted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID Proofs', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('No ID proofs uploaded.', style: AppTypography.bodySmall.copyWith(color: colors.mutedFg)),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Add ID Proof'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    String? errorText,
    String? hintText,
    int maxLength = 1024,
    int maxLines = 1,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required AppColors colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: colors.mutedFg)),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLength: maxLength,
          maxLines: maxLines,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}


// ─── Action Buttons ─────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isLoading,
    required this.onCreateAndSale,
    required this.onCreateOnly,
    required this.colors,
  });

  final bool isLoading;
  final VoidCallback onCreateAndSale;
  final VoidCallback onCreateOnly;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onCreateAndSale,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create & start sale'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : onCreateOnly,
            child: const Text('Create only'),
          ),
        ),
      ],
    );
  }
}

// ─── Add Place Sheet ─────────────────────────────────────
class _AddPlaceSheet extends StatefulWidget {
  const _AddPlaceSheet({required this.controller});

  final TextEditingController controller;

  @override
  State<_AddPlaceSheet> createState() => _AddPlaceSheetState();
}

class _AddPlaceSheetState extends State<_AddPlaceSheet> {
  @override
  void dispose() {
    widget.controller.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add new place', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: 'Place name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, widget.controller.text);
                },
                child: const Text('Add place'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Area Sheet ──────────────────────────────────────
class _AddAreaSheet extends StatefulWidget {
  const _AddAreaSheet({required this.controller});

  final TextEditingController controller;

  @override
  State<_AddAreaSheet> createState() => _AddAreaSheetState();
}

class _AddAreaSheetState extends State<_AddAreaSheet> {
  @override
  void dispose() {
    widget.controller.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add new area', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: 'Area name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, widget.controller.text);
                },
                child: const Text('Add area'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
