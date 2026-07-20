import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geocoding/geocoding.dart' as gc;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/router/routes.dart';
import '../../data/providers.dart';
import '../../data/models/nominee.dart';
import '../../data/models/location.dart';
import '../../data/models/id_proof.dart';
import '../../data/models/customer.dart';
import 'new_client_controller.dart';

class NewClientScreen extends ConsumerStatefulWidget {
  const NewClientScreen({super.key, this.customer});

  final Customer? customer;

  @override
  ConsumerState<NewClientScreen> createState() => _NewClientScreenState();
}

class _NewClientScreenState extends ConsumerState<NewClientScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _alternatePhoneController;
  late TextEditingController _occupationController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _landmarkController;
  late TextEditingController _notesController;
  late TextEditingController _placeNameController;
  late TextEditingController _areaNameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.customer?.phone ?? '');
    _alternatePhoneController =
        TextEditingController(text: widget.customer?.alternatePhone ?? '');
    _occupationController =
        TextEditingController(text: widget.customer?.occupation ?? '');
    _dobController = TextEditingController(text: widget.customer?.dob ?? '');
    _addressController =
        TextEditingController(text: widget.customer?.address ?? '');
    _landmarkController =
        TextEditingController(text: widget.customer?.landmark ?? '');
    _notesController =
        TextEditingController(text: widget.customer?.notes ?? '');
    _placeNameController = TextEditingController();
    _areaNameController = TextEditingController();

    if (widget.customer != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(newClientControllerProvider.notifier)
              .prepopulateForm(widget.customer!);
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(newClientControllerProvider.notifier).resetForm();
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _occupationController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _notesController.dispose();
    _placeNameController.dispose();
    _areaNameController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(newClientControllerProvider.notifier).resetForm();
    });
    super.dispose();
  }

  void _showAddPlaceSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _AddPlaceSheet(controller: _placeNameController),
      isScrollControlled: true,
    );
    if (result != null && result.trim().isNotEmpty && mounted) {
      final newPlace = await ref
          .read(newClientControllerProvider.notifier)
          .addNewPlace(result.trim());
      if (newPlace != null) {
        await ref
            .read(newClientControllerProvider.notifier)
            .setPlace(newPlace.id);
      }
    }
  }

  void _showAddAreaSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _AddAreaSheet(controller: _areaNameController),
      isScrollControlled: true,
    );
    if (result != null && result.trim().isNotEmpty && mounted) {
      final newArea = await ref
          .read(newClientControllerProvider.notifier)
          .addNewArea(result.trim());
      if (newArea != null) {
        ref.read(newClientControllerProvider.notifier).setArea(newArea.id);
      }
    }
  }

  void _handleBack() async {
    final isDirty = ref.read(newClientControllerProvider.notifier).isDirty;
    if (isDirty) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes'),
          content: Text(widget.customer != null
              ? 'Are you sure you want to discard your changes?'
              : 'Are you sure you want to discard this customer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (shouldDiscard == true) {
        _exitScreen();
      }
    } else {
      _exitScreen();
    }
  }

  void _exitScreen() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      context.go(Routes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final formState = ref.watch(newClientControllerProvider);
    final controller = ref.read(newClientControllerProvider.notifier);

    return BackButtonListener(
      onBackButtonPressed: () async {
        _handleBack();
        return true;
      },
      child: AppScaffold(
        showSyncIndicator: false,
        appBarLeading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        title:
            Text(widget.customer != null ? 'Edit Client' : 'New Credit Sale'),
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
                  occupationController: _occupationController,
                  dobController: _dobController,
                  addressController: _addressController,
                  landmarkController: _landmarkController,
                  notesController: _notesController,
                  controller: controller,
                  colors: colors,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Action Buttons
                _ActionButtons(
                  isLoading: formState.isLoading,
                  isEditing: widget.customer != null,
                  onCreateAndSale: () async {
                    final customer = await controller.createAndSale();
                    if (customer == null) return;
                    if (!context.mounted) return;

                    // Capture ref dependencies before showing snackbar
                    final repository = ref.read(customerRepositoryProvider);
                    final notifier =
                        ref.read(newClientControllerProvider.notifier);

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
                    context.go('${Routes.sale(
                      formState.selectedWeekday,
                      formState.placeId,
                      formState.areaId,
                      customer.id,
                    )}?source=create');
                  },
                  onCreateOnly: () async {
                    final customer = await controller.createOnly();
                    if (customer == null) return;
                    if (!context.mounted) return;

                    if (widget.customer != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Customer details updated successfully'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context);
                      return;
                    }

                    // Capture ref dependencies before showing snackbar
                    final repository = ref.read(customerRepositoryProvider);
                    final notifier =
                        ref.read(newClientControllerProvider.notifier);

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
                    context.go(Routes.customer(
                      formState.selectedWeekday,
                      formState.placeId,
                      formState.areaId,
                      customer.id,
                    ));
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
    final weekdayNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

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
            Text('Weekday *',
                style: AppTypography.labelSmall
                    .copyWith(color: widget.colors.mutedFg)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: weekdayNames.map((day) {
                final isSelected = widget.state.selectedWeekday == day;
                final shortName = day.substring(0, 3).toUpperCase();
                return InkWell(
                  onTap: () async {
                    await widget.controller.setWeekday(
                        widget.controller.getWeekdayIdByName(day), day);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.colors.primary
                          : widget.colors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? widget.colors.primary
                            : widget.colors.border,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: widget.colors.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      shortName,
                      style: AppTypography.labelSmall.copyWith(
                        color:
                            isSelected ? Colors.white : widget.colors.mutedFg,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (widget.state.errors.containsKey('weekday')) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.state.errors['weekday']!,
                style: AppTypography.bodySmall
                    .copyWith(color: widget.colors.destructive),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            // Place Dropdown
            Text('Place *',
                style: AppTypography.labelSmall
                    .copyWith(color: widget.colors.mutedFg)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: widget.state.placeId.isEmpty ? null : widget.state.placeId,
              dropdownColor: widget.colors.surface,
              icon:
                  Icon(Icons.keyboard_arrow_down, color: widget.colors.mutedFg),
              items: [
                ...widget.state.places.map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(
                        p.name,
                        style: TextStyle(
                            color: widget.colors.foreground, fontSize: 14),
                      ),
                    )),
                DropdownMenuItem(
                  value: 'add_new_place',
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: widget.colors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Add new place...',
                        style: TextStyle(
                          color: widget.colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == 'add_new_place') {
                  widget.onAddPlace();
                } else if (value != null) {
                  widget.controller.setPlace(value);
                }
              },
              decoration: InputDecoration(
                prefixIcon:
                    Icon(Icons.place_outlined, color: widget.colors.primary),
                hintText: 'Select a place',
                hintStyle:
                    TextStyle(color: widget.colors.mutedFg, fontSize: 14),
                errorText: widget.state.errors['place'],
                filled: true,
                fillColor: widget.colors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: widget.colors.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: widget.colors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: widget.colors.destructive, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: widget.colors.destructive, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Area Dropdown
            Text('Area *',
                style: AppTypography.labelSmall
                    .copyWith(color: widget.colors.mutedFg)),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: widget.state.areaId.isEmpty ? null : widget.state.areaId,
              dropdownColor: widget.colors.surface,
              icon:
                  Icon(Icons.keyboard_arrow_down, color: widget.colors.mutedFg),
              items: [
                ...widget.state.areas.map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text(
                        a.name,
                        style: TextStyle(
                            color: widget.colors.foreground, fontSize: 14),
                      ),
                    )),
                DropdownMenuItem(
                  value: 'add_new_area',
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: widget.colors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Add new area...',
                        style: TextStyle(
                          color: widget.colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == 'add_new_area') {
                  widget.onAddArea();
                } else if (value != null) {
                  widget.controller.setArea(value);
                }
              },
              decoration: InputDecoration(
                prefixIcon:
                    Icon(Icons.explore_outlined, color: widget.colors.primary),
                hintText: 'Select an area',
                hintStyle:
                    TextStyle(color: widget.colors.mutedFg, fontSize: 14),
                errorText: widget.state.errors['area'],
                filled: true,
                fillColor: widget.colors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: widget.colors.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: widget.colors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: widget.colors.destructive, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: widget.colors.destructive, width: 2),
                ),
              ),
            ),
            if (widget.state.errors.containsKey('area')) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.state.errors['area']!,
                style: AppTypography.bodySmall
                    .copyWith(color: widget.colors.destructive),
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
    required this.occupationController,
    required this.dobController,
    required this.addressController,
    required this.landmarkController,
    required this.notesController,
    required this.controller,
    required this.colors,
  });

  final NewClientFormState state;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController alternatePhoneController;
  final TextEditingController occupationController;
  final TextEditingController dobController;
  final TextEditingController addressController;
  final TextEditingController landmarkController;
  final TextEditingController notesController;
  final NewClientController controller;
  final AppColors colors;

  void _selectDate(BuildContext context, TextEditingController textController,
      Function(String) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      final dateStr = '$day/$month/$year';
      textController.text = dateStr;
      onDateSelected(dateStr);
    }
  }

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

            // Phone | Alternate Phone in row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Phone *',
                    controller: phoneController,
                    onChanged: controller.setPhone,
                    errorText: state.errors['phone'],
                    hintText: 'e.g., 98765 43210',
                    keyboardType: TextInputType.phone,
                    maxLength: 14,
                    colors: colors,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildTextField(
                    label: 'Alternate phone',
                    controller: alternatePhoneController,
                    onChanged: controller.setAlternatePhone,
                    hintText: '(optional)',
                    keyboardType: TextInputType.phone,
                    maxLength: 14,
                    colors: colors,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Date of birth (mandatory)
            _buildDateField(
              label: 'Date of birth *',
              controller: dobController,
              onChanged: controller.setDob,
              errorText: state.errors['dob'],
              hintText: 'DD/MM/YYYY',
              colors: colors,
              onCalendarTap: () =>
                  _selectDate(context, dobController, controller.setDob),
            ),
            const SizedBox(height: AppSpacing.md),

            // Occupation (single row)
            _buildTextField(
              label: 'Occupation',
              controller: occupationController,
              onChanged: controller.setOccupation,
              hintText: 'e.g., Engineer',
              maxLength: 60,
              colors: colors,
            ),
            const SizedBox(height: AppSpacing.md),

            // Location block
            _LocationBlock(
                state: state, controller: controller, colors: colors),
            const SizedBox(height: AppSpacing.md),

            // Address (with Autofill check button in header)
            _buildTextField(
              label: 'Address *',
              controller: addressController,
              onChanged: controller.setAddress,
              errorText: state.errors['address'],
              hintText: 'Full address (≤240 chars)',
              maxLines: 3,
              maxLength: 240,
              colors: colors,
              trailingLabelAction: (state.location != null &&
                      state.location!.label != null &&
                      state.location!.label!.isNotEmpty)
                  ? TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(Icons.autorenew,
                          size: 14, color: colors.primary),
                      label: Text(
                        'Autofill from Map',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      onPressed: () {
                        addressController.text = state.location!.label ?? '';
                        controller.setAddress(state.location!.label ?? '');
                      },
                    )
                  : null,
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

            // Nominees block
            _NomineesBlock(
              state: state,
              controller: controller,
              colors: colors,
            ),
            const SizedBox(height: AppSpacing.md),

            // ID Proofs block
            _IdProofsBlock(
                state: state, controller: controller, colors: colors),
            const SizedBox(height: AppSpacing.md),

            // Remarks/Notes at the end
            _buildTextField(
              label: 'Remarks',
              controller: notesController,
              onChanged: controller.setNotes,
              hintText: 'Enter any remarks...',
              maxLines: 3,
              maxLength: 500,
              colors: colors,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required VoidCallback onCalendarTap,
    String? errorText,
    String? hintText,
    required AppColors colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelSmall.copyWith(color: colors.mutedFg)),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            hintText: hintText ?? 'DD/MM/YYYY',
            errorText: errorText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today_outlined,
                  color: colors.primary, size: 20),
              onPressed: onCalendarTap,
            ),
          ),
        ),
      ],
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
    Widget? trailingLabelAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    AppTypography.labelSmall.copyWith(color: colors.mutedFg)),
            if (trailingLabelAction != null) trailingLabelAction,
          ],
        ),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
    this.isEditing = false,
  });

  final bool isLoading;
  final VoidCallback onCreateAndSale;
  final VoidCallback onCreateOnly;
  final AppColors colors;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onCreateOnly,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save changes'),
        ),
      );
    }
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
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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

class _NomineesBlock extends StatefulWidget {
  const _NomineesBlock({
    required this.state,
    required this.controller,
    required this.colors,
  });

  final NewClientFormState state;
  final NewClientController controller;
  final AppColors colors;

  @override
  State<_NomineesBlock> createState() => _NomineesBlockState();
}

class _NomineesBlockState extends State<_NomineesBlock> {
  void _openNomineeBottomSheet([Nominee? nominee]) {
    final isEditing = nominee != null;
    final nameCtrl = TextEditingController(text: nominee?.name ?? '');
    final phoneCtrl = TextEditingController(text: nominee?.phone ?? '');

    final standardRelations = ['Spouse', 'Parent', 'Child', 'Sibling'];
    String rel;
    final customRelCtrl = TextEditingController();

    if (nominee != null) {
      final String relationVal = nominee.relation ?? 'Spouse';
      if (standardRelations.contains(relationVal)) {
        rel = relationVal;
      } else {
        rel = 'Other';
        customRelCtrl.text = relationVal;
      }
    } else {
      rel = 'Spouse';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.colors.background,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Nominee' : 'Add Nominee',
                          style: AppTypography.titleMedium
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Name *',
                        style: AppTypography.labelSmall
                            .copyWith(color: widget.colors.mutedFg)),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: nameCtrl,
                      maxLength: 60,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        hintText: 'Enter nominee name',
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Relation *',
                        style: AppTypography.labelSmall
                            .copyWith(color: widget.colors.mutedFg)),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      initialValue: rel,
                      dropdownColor: widget.colors.surface,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: widget.colors.mutedFg),
                      items: ['Spouse', 'Parent', 'Child', 'Sibling', 'Other']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: TextStyle(
                                        color: widget.colors.foreground,
                                        fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            rel = val;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.people_outline,
                            color: widget.colors.primary),
                        filled: true,
                        fillColor: widget.colors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: widget.colors.border, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: widget.colors.primary, width: 2),
                        ),
                      ),
                    ),
                    if (rel == 'Other') ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text('Specify Relationship *',
                          style: AppTypography.labelSmall
                              .copyWith(color: widget.colors.mutedFg)),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: customRelCtrl,
                        maxLength: 30,
                        decoration: InputDecoration(
                          hintText: 'e.g., Grandparent',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onChanged: (_) => setModalState(() {}),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Text('Phone',
                        style: AppTypography.labelSmall
                            .copyWith(color: widget.colors.mutedFg)),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 14,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        hintText: 'Enter phone number (optional)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(80, 44),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        ElevatedButton(
                          onPressed: nameCtrl.text.trim().isNotEmpty &&
                                  (rel != 'Other' ||
                                      customRelCtrl.text.trim().isNotEmpty)
                              ? () {
                                  final chosenRelation = rel == 'Other'
                                      ? (customRelCtrl.text.trim().isEmpty
                                          ? 'Other'
                                          : customRelCtrl.text.trim())
                                      : rel;
                                  final n = Nominee(
                                    id: nominee?.id ??
                                        DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                    name: nameCtrl.text.trim(),
                                    phone: phoneCtrl.text.trim().isEmpty
                                        ? null
                                        : phoneCtrl.text.trim(),
                                    relation: chosenRelation,
                                    dob: null,
                                  );
                                  if (nominee != null) {
                                    widget.controller
                                        .updateNominee(nominee.id, n);
                                  } else {
                                    widget.controller.addNominee(n);
                                  }
                                  Navigator.pop(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.colors.primary,
                            foregroundColor: widget.colors.primaryFg,
                            minimumSize: const Size(100, 44),
                          ),
                          child: Text(isEditing ? 'Update' : 'Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final nominees = widget.state.nominees;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Nominees',
                style: AppTypography.labelLarge
                    .copyWith(fontWeight: FontWeight.bold)),
            Text(
              nominees.isEmpty
                  ? 'No nominees added.'
                  : '${nominees.length} of 3 added.',
              style: AppTypography.bodySmall.copyWith(color: colors.mutedFg),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // List of chips/cards
        if (nominees.isNotEmpty) ...[
          ...nominees.map((n) => Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: colors.border),
                ),
                child: ListTile(
                  title: Text(n.name,
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${n.relation ?? ''}${n.phone != null && n.phone!.isNotEmpty ? ' · ${n.phone}' : ''}',
                    style:
                        AppTypography.bodySmall.copyWith(color: colors.mutedFg),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 20, color: colors.primary),
                        onPressed: () => _openNomineeBottomSheet(n),
                        tooltip: 'Edit Nominee',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            size: 20, color: colors.destructive),
                        onPressed: () => widget.controller.removeNominee(n.id),
                        tooltip: 'Remove Nominee',
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: AppSpacing.sm),
        ],

        if (nominees.length < 3)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _openNomineeBottomSheet(),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary),
              ),
              child: const Text('+ Add Nominee'),
            ),
          )
        else
          Text('Maximum 3 nominees.',
              style: AppTypography.bodySmall.copyWith(color: colors.mutedFg)),
      ],
    );
  }
}

// ─── Location Block ─────────────────────────────────────
class _LocationBlock extends StatefulWidget {
  const _LocationBlock({
    required this.state,
    required this.controller,
    required this.colors,
  });

  final NewClientFormState state;
  final NewClientController controller;
  final AppColors colors;

  @override
  State<_LocationBlock> createState() => _LocationBlockState();
}

class _LocationBlockState extends State<_LocationBlock> {
  GoogleMapController? _mapController;
  bool _isLocating = false;
  LatLng? _cameraCenter;
  bool _userInteracted = false;
  LatLng? _lastGeocodedLocation;
  bool _mapUnlocked = false;

  void _updateInlineLocation(LatLng target) {
    if (_lastGeocodedLocation != null &&
        (_lastGeocodedLocation!.latitude - target.latitude).abs() < 0.0001 &&
        (_lastGeocodedLocation!.longitude - target.longitude).abs() < 0.0001) {
      return;
    }
    widget.controller.setLocation(Location(
      lat: double.parse(target.latitude.toStringAsFixed(6)),
      lng: double.parse(target.longitude.toStringAsFixed(6)),
      label: 'Fetching address...',
    ));
    _reverseGeocodeInline(target);
  }

  Future<void> _reverseGeocodeInline(LatLng latLng) async {
    _lastGeocodedLocation = latLng;
    try {
      List<gc.Placemark> placemarks = await gc
          .placemarkFromCoordinates(
            latLng.latitude,
            latLng.longitude,
          )
          .timeout(const Duration(seconds: 4));
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final addressParts = [
          if (p.street != null && p.street!.isNotEmpty) p.street,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality,
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
            p.administrativeArea,
          if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode,
          if (p.country != null && p.country!.isNotEmpty) p.country,
        ];
        widget.controller.setLocation(Location(
          lat: double.parse(latLng.latitude.toStringAsFixed(6)),
          lng: double.parse(latLng.longitude.toStringAsFixed(6)),
          label: addressParts.join(', '),
        ));
      } else {
        widget.controller.setLocation(Location(
          lat: double.parse(latLng.latitude.toStringAsFixed(6)),
          lng: double.parse(latLng.longitude.toStringAsFixed(6)),
          label:
              'Pinned Location (${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})',
        ));
      }
    } catch (_) {
      widget.controller.setLocation(Location(
        lat: double.parse(latLng.latitude.toStringAsFixed(6)),
        lng: double.parse(latLng.longitude.toStringAsFixed(6)),
        label:
            'Pinned Location (${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})',
      ));
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _LocationBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.location != null &&
        widget.state.location != oldWidget.state.location &&
        _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.state.location!.lat, widget.state.location!.lng),
        ),
      );
    }
  }

  Future<void> _requestLocationPermission() async {
    final colors = widget.colors;
    setState(() => _isLocating = true);

    try {
      // Check location permission status using permission_handler
      ph.PermissionStatus status = await ph.Permission.locationWhenInUse.status;
      if (status.isDenied) {
        status = await ph.Permission.locationWhenInUse.request();
      }

      if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Location permission is permanently denied. Please enable it in settings.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => ph.openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      if (status.isGranted || status.isLimited) {
        // Check if location services are enabled
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'GPS/Location services are disabled on the device.'),
                action: SnackBarAction(
                  label: 'Enable',
                  onPressed: () => Geolocator.openLocationSettings(),
                ),
              ),
            );
          }
          return;
        }

        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 8),
            ),
          );
        } catch (e) {
          try {
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 5),
              ),
            );
          } catch (e2) {
            position = await Geolocator.getLastKnownPosition();
          }
        }

        if (mounted && position != null) {
          _userInteracted = false;
          final target = LatLng(position.latitude, position.longitude);
          widget.controller.setLocation(Location(
            lat: target.latitude,
            lng: target.longitude,
            label: 'Fetching address...',
          ));
          _reverseGeocodeInline(target);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📍 Location updated to current GPS position'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          throw 'Could not determine position';
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to acquire GPS location: $e'),
            backgroundColor: colors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final location = widget.state.location;

    // Use current location, or fallback to default Chennai center (13.0827, 80.2707)
    final double centerLat = location?.lat ?? 13.0827;
    final double centerLng = location?.lng ?? 80.2707;

    final hasLocation = location != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.map_outlined, size: 20, color: colors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('LOCATION',
                    style: AppTypography.labelLarge
                        .copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            // Location Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasLocation
                    ? colors.primary.withValues(alpha: 0.1)
                    : colors.muted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: hasLocation
                        ? colors.primary.withValues(alpha: 0.3)
                        : colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: hasLocation ? colors.primary : colors.mutedFg,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasLocation ? 'Pinned' : 'Not Set',
                    style: AppTypography.bodySmall.copyWith(
                      color: hasLocation ? colors.primary : colors.mutedFg,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Map Preview Container
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: colors.muted,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasLocation
                  ? colors.primary.withValues(alpha: 0.5)
                  : colors.border,
              width: hasLocation ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Listener(
                  onPointerDown: (_) {
                    if (_mapUnlocked) {
                      _userInteracted = true;
                    }
                  },
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(centerLat, centerLng),
                      zoom: 16.0,
                    ),
                    mapType: MapType.hybrid,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    gestureRecognizers: _mapUnlocked
                        ? <Factory<OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                            ),
                          }
                        : const <Factory<OneSequenceGestureRecognizer>>{},
                    onMapCreated: (mapController) {
                      _mapController = mapController;
                    },
                    onCameraMoveStarted: () {
                      if (_mapUnlocked) {
                        _userInteracted = true;
                      }
                    },
                    onCameraMove: (position) {
                      _cameraCenter = position.target;
                    },
                    onCameraIdle: () {
                      if (_userInteracted && _cameraCenter != null) {
                        _userInteracted = false;
                        _updateInlineLocation(_cameraCenter!);
                      }
                    },
                  ),
                ),
                if (!_mapUnlocked)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _mapUnlocked = true;
                        });
                      },
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.15),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.touch_app,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Tap to interact with map',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_mapUnlocked)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _mapUnlocked = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_outline,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Lock Scroll',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Fixed pin overlay at the center of the inline map preview
                if (hasLocation)
                  Center(
                    child: IgnorePointer(
                      child: Transform.translate(
                        offset: const Offset(0, -18),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: 8,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.location_on,
                              color: colors.destructive,
                              size: 36,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Top Hint Banner
                // if (!hasLocation)
                //   Positioned(
                //     top: 10,
                //     left: 10,
                //     right: 10,
                //     child: IgnorePointer(
                //       child: AnimatedOpacity(
                //         opacity: 0.9,
                //         duration: const Duration(milliseconds: 300),
                //         child: Container(
                //           padding: const EdgeInsets.symmetric(
                //               horizontal: 10, vertical: 6),
                //           decoration: BoxDecoration(
                //             color: Colors.black.withValues(alpha: 0.7),
                //             borderRadius: BorderRadius.circular(20),
                //           ),
                //           child: Row(
                //             mainAxisSize: MainAxisSize.min,
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               const Icon(Icons.touch_app,
                //                   color: Colors.white, size: 14),
                //               const SizedBox(width: 6),
                //               const Text(
                //                 'Tap map or use GPS to pin client location',
                //                 style: TextStyle(
                //                     color: Colors.white,
                //                     fontSize: 10,
                //                     fontWeight: FontWeight.w500),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),

                // GPS Target Action Button Overlay (Bottom Left)
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: _isLocating ? null : _requestLocationPermission,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colors.background.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Center(
                          child: _isLocating
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.primary,
                                  ),
                                )
                              : Icon(
                                  Icons.gps_fixed,
                                  color: colors.primary,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Closer View Button Overlay (Bottom Right, above Zoom controls)
                Positioned(
                  bottom: 98,
                  right: 10,
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => _openCloserViewDialog(context),
                      borderRadius: BorderRadius.circular(30),
                      child: Tooltip(
                        message: 'Open Closer View',
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colors.background.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.open_in_full,
                              color: colors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Zoom Controls overlay (Bottom Right)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.background.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            _mapController
                                ?.animateCamera(CameraUpdate.zoomIn());
                          },
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(Icons.add, size: 18),
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 1,
                          color: colors.border,
                        ),
                        InkWell(
                          onTap: () {
                            _mapController
                                ?.animateCamera(CameraUpdate.zoomOut());
                          },
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(Icons.remove, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Selected Location Details Card (or a Get Location helper if null)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: hasLocation
              ? Container(
                  key: const ValueKey('has_location'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.destructive.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.location_on,
                            color: colors.destructive, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CLIENT PINNED POSITION',
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.mutedFg,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (location.label != null &&
                                location.label!.isNotEmpty) ...[
                              Text(
                                location.label!,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.foreground,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              'Lat: ${location.lat.toStringAsFixed(6)}, Lng: ${location.lng.toStringAsFixed(6)}',
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.mutedFg,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Actions
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.clear,
                                color: colors.destructive, size: 20),
                            onPressed: () {
                              widget.controller.setLocation(null);
                              setState(() {
                                _mapUnlocked = false;
                              });
                            },
                            tooltip: 'Clear location',
                          ),
                          IconButton(
                            icon: Icon(Icons.open_in_new,
                                color: colors.primary, size: 20),
                            onPressed: () async {
                              final url = Uri.parse(
                                  'https://www.google.com/maps/search/?api=1&query=${location.lat},${location.lng}');
                              if (await launchUrl(url,
                                  mode: LaunchMode.externalApplication)) {
                                // opened
                              }
                            },
                            tooltip: 'View in Google Maps',
                          ),
                        ],
                      )
                    ],
                  ),
                )
              : Container(
                  key: const ValueKey('no_location'),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: colors.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: colors.border, style: BorderStyle.solid),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colors.mutedFg, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'No location pinned yet. Tap on the satellite map or use the GPS button to set the client\'s location.',
                          style: AppTypography.bodySmall
                              .copyWith(color: colors.mutedFg),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  void _openCloserViewDialog(BuildContext context) {
    setState(() {
      _userInteracted = false;
    });
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Map Closer View',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _FullScreenMapDialog(
          initialLocation: widget.state.location,
          colors: widget.colors,
          onLocationSelected: (Location? newLocation) {
            widget.controller.setLocation(newLocation);
          },
        );
      },
    );
  }
}

// ─── ID Proofs Block ─────────────────────────────────────
class _IdProofsBlock extends StatefulWidget {
  const _IdProofsBlock({
    required this.state,
    required this.controller,
    required this.colors,
  });

  final NewClientFormState state;
  final NewClientController controller;
  final AppColors colors;

  @override
  State<_IdProofsBlock> createState() => _IdProofsBlockState();
}

class _IdProofsBlockState extends State<_IdProofsBlock> {
  String? _selectedType;

  Future<void> _processPickedFile(
      String path, String filename, int sizeBytes) async {
    String mimeType = 'image/jpeg';
    if (filename.toLowerCase().endsWith('.pdf')) {
      mimeType = 'application/pdf';
    } else if (filename.toLowerCase().endsWith('.png')) {
      mimeType = 'image/png';
    }

    final proof = IdProof(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType!,
      number:
          'DOC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      document: IdProofDocument(
        filename: filename,
        mimeType: mimeType,
        sizeBytes: sizeBytes,
        localUri: Uri.file(path).toString(),
      ),
    );
    widget.controller.addIdProof(proof);
    setState(() {
      _selectedType = null;
    });
  }

  void _showErrorSnackBar(dynamic e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  void _openFilePicker() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an ID proof type first')),
      );
      return;
    }

    final colors = widget.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Choose Upload Method',
                      style: AppTypography.titleMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.camera_alt, color: colors.primary),
                title: const Text('Take Photo',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      final sizeBytes = await image.length();
                      await _processPickedFile(
                          image.path, image.name, sizeBytes);
                    }
                  } catch (e) {
                    _showErrorSnackBar(e);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: colors.primary),
                title: const Text('Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      final sizeBytes = await image.length();
                      await _processPickedFile(
                          image.path, image.name, sizeBytes);
                    }
                  } catch (e) {
                    _showErrorSnackBar(e);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.file_present, color: colors.primary),
                title: const Text('Select Document (PDF / Image)',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    );
                    if (result != null && result.files.single.path != null) {
                      final file = result.files.single;
                      await _processPickedFile(
                          file.path!, file.name, file.size);
                    }
                  } catch (e) {
                    _showErrorSnackBar(e);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _viewIdProof(IdProof p) async {
    final doc = p.document;
    if (doc == null || doc.localUri.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No document file associated with this ID proof')),
      );
      return;
    }

    try {
      final fileUri = Uri.parse(doc.localUri);

      if (doc.mimeType.startsWith('image/')) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: widget.colors.background,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text(doc.filename, style: AppTypography.titleMedium),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: InteractiveViewer(
                      child: Image.file(
                        File(fileUri.toFilePath()),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Could not load image file: $error',
                                  style: AppTypography.bodyMedium),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        final launched =
            await launchUrl(fileUri, mode: LaunchMode.externalApplication);
        if (!launched) {
          throw 'Could not launch URL';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final proofs = widget.state.idProofs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ID Proofs Type',
            style: AppTypography.labelSmall.copyWith(color: colors.mutedFg)),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          initialValue: _selectedType,
          dropdownColor: colors.surface,
          icon: Icon(Icons.keyboard_arrow_down, color: colors.mutedFg),
          hint: Text('Select proof type',
              style: TextStyle(color: colors.mutedFg, fontSize: 14)),
          items: ['Aadhaar', 'Voter', 'DL', 'PAN', 'Other']
              .map((e) => DropdownMenuItem(
                    value: e,
                    onTap: () {
                      if (_selectedType == e) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _selectedType = null;
                          });
                        });
                      }
                    },
                    child: Text(e,
                        style:
                            TextStyle(color: colors.foreground, fontSize: 14)),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() {
              if (_selectedType == val) {
                _selectedType = null;
              } else {
                _selectedType = val;
              }
            });
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.badge_outlined, color: colors.primary),
            filled: true,
            fillColor: colors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('ID Proofs',
            style:
                AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        if (proofs.isEmpty)
          Text('No ID proofs uploaded.',
              style: AppTypography.bodySmall.copyWith(color: colors.mutedFg))
        else
          Column(
            children: proofs
                .map((p) => Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: colors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                              p.document?.mimeType == 'application/pdf'
                                  ? Icons.picture_as_pdf
                                  : Icons.image,
                              color: colors.mutedFg),
                        ),
                        title: Text(p.document?.filename ?? p.type,
                            style: AppTypography.bodyMedium),
                        subtitle: Text(
                          p.document != null
                              ? '${(p.document!.sizeBytes / 1024).toStringAsFixed(1)} KB'
                              : '',
                          style: AppTypography.bodySmall
                              .copyWith(color: colors.mutedFg),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.visibility,
                                  size: 20, color: colors.primary),
                              onPressed: () => _viewIdProof(p),
                              tooltip: 'View ID Proof',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  size: 20, color: colors.destructive),
                              onPressed: () =>
                                  widget.controller.removeIdProof(p.id),
                              tooltip: 'Remove ID Proof',
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        const SizedBox(height: AppSpacing.md),
        if (proofs.length < 3)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openFilePicker,
              icon: const Icon(Icons.add_to_photos),
              label: const Text('Add ID Proof'),
            ),
          )
        else
          Text('Maximum 3 files allowed.',
              style: AppTypography.bodySmall.copyWith(color: colors.mutedFg)),
      ],
    );
  }
}

// ─── Full Screen Map Dialog with Search & Geocoding ────────────────
class _FullScreenMapDialog extends StatefulWidget {
  const _FullScreenMapDialog({
    required this.initialLocation,
    required this.colors,
    required this.onLocationSelected,
  });

  final Location? initialLocation;
  final AppColors colors;
  final ValueChanged<Location?> onLocationSelected;

  @override
  State<_FullScreenMapDialog> createState() => _FullScreenMapDialogState();
}

class _FullScreenMapDialogState extends State<_FullScreenMapDialog> {
  GoogleMapController? _dialogMapController;
  LatLng? _tempLocation;
  String _tempAddress = '';
  bool _isSearching = false;
  bool _isLocating = false;
  final TextEditingController _searchController = TextEditingController();
  LatLng? _lastGeocodedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _tempLocation =
          LatLng(widget.initialLocation!.lat, widget.initialLocation!.lng);
      _reverseGeocode(_tempLocation!);
    } else {
      _tempLocation = null;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dialogMapController?.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    if (_lastGeocodedLocation != null &&
        (_lastGeocodedLocation!.latitude - latLng.latitude).abs() < 0.00001 &&
        (_lastGeocodedLocation!.longitude - latLng.longitude).abs() < 0.00001) {
      return;
    }
    _lastGeocodedLocation = latLng;
    try {
      List<gc.Placemark> placemarks = await gc.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final addressParts = [
          if (p.street != null && p.street!.isNotEmpty) p.street,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality,
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
            p.administrativeArea,
          if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode,
          if (p.country != null && p.country!.isNotEmpty) p.country,
        ];
        setState(() {
          _tempAddress = addressParts.join(', ');
        });
      } else {
        setState(() {
          _tempAddress =
              '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      setState(() {
        _tempAddress =
            '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
      });
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSearching = true);

    try {
      List<gc.Location> locations = await gc.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final first = locations.first;
        final latLng = LatLng(first.latitude, first.longitude);
        setState(() {
          _tempLocation = latLng;
        });

        _dialogMapController?.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 16.0),
        );

        await _reverseGeocode(latLng);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No coordinates found for this location.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'GPS/Location services are disabled on the device.'),
              action: SnackBarAction(
                label: 'Enable',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        return;
      }

      ph.PermissionStatus status = await ph.Permission.locationWhenInUse.status;
      if (status.isDenied) {
        status = await ph.Permission.locationWhenInUse.request();
      }

      if (status.isGranted || status.isLimited) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        final latLng = LatLng(position.latitude, position.longitude);
        setState(() {
          _tempLocation = latLng;
        });
        _dialogMapController?.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 16.0),
        );
        await _reverseGeocode(latLng);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission denied.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final hasPin = _tempLocation != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Fullscreen Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _tempLocation ?? const LatLng(13.0827, 80.2707),
              zoom: 16.0,
            ),
            mapType: MapType.hybrid,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            onMapCreated: (controller) {
              _dialogMapController = controller;
            },
            onCameraMove: (position) {
              _tempLocation = position.target;
            },
            onCameraIdle: () {
              if (_tempLocation != null) {
                setState(() {});
                _reverseGeocode(_tempLocation!);
              }
            },
            onTap: (latLng) {
              _dialogMapController?.animateCamera(
                CameraUpdate.newLatLng(latLng),
              );
            },
          ),

          // Fixed pin overlay at the center of the screen
          if (hasPin)
            Center(
              child: IgnorePointer(
                child: Transform.translate(
                  offset: const Offset(0, -22),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Subtly animating pulse/shadow circle under the pin tip
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.location_on,
                        color: colors.destructive,
                        size: 44,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating Search Bar at Top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: colors.foreground,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: _searchAddress,
                            style: TextStyle(
                              color: colors.foreground,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search street, area, or landmark...',
                              hintStyle: TextStyle(
                                color: colors.mutedFg,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            color: colors.mutedFg,
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          ),
                        IconButton(
                          icon: _isSearching
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.primary,
                                  ),
                                )
                              : const Icon(Icons.search),
                          color: colors.primary,
                          onPressed: () =>
                              _searchAddress(_searchController.text),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating Controls (GPS & Zoom) Middle Right
          Positioned(
            right: 16,
            bottom: 220, // Sit nicely above the bottom location card
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // GPS Button
                FloatingActionButton.small(
                  heroTag: 'dialog_gps_btn',
                  onPressed: _isLocating ? null : _getCurrentLocation,
                  backgroundColor: colors.background,
                  foregroundColor: colors.primary,
                  child: _isLocating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.gps_fixed),
                ),
                const SizedBox(height: 12),

                // Zoom Controls
                Container(
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        color: colors.foreground,
                        onPressed: () {
                          _dialogMapController
                              ?.animateCamera(CameraUpdate.zoomIn());
                        },
                      ),
                      Container(width: 20, height: 1, color: colors.border),
                      IconButton(
                        icon: const Icon(Icons.remove, size: 20),
                        color: colors.foreground,
                        onPressed: () {
                          _dialogMapController
                              ?.animateCamera(CameraUpdate.zoomOut());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Location Info Card at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on,
                              color: colors.destructive, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SELECTED PIN POSITION',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: colors.mutedFg,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _tempAddress.isNotEmpty
                                      ? _tempAddress
                                      : 'Fetching address...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colors.foreground,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Lat: ${_tempLocation?.latitude.toStringAsFixed(6)}, Lng: ${_tempLocation?.longitude.toStringAsFixed(6)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.mutedFg,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: hasPin
                            ? () {
                                widget.onLocationSelected(Location(
                                  lat: double.parse(_tempLocation!.latitude
                                      .toStringAsFixed(6)),
                                  lng: double.parse(_tempLocation!.longitude
                                      .toStringAsFixed(6)),
                                  label: _tempAddress.isNotEmpty
                                      ? _tempAddress
                                      : 'Pinned Location (${_tempLocation!.latitude.toStringAsFixed(4)}, ${_tempLocation!.longitude.toStringAsFixed(4)})',
                                ));
                                Navigator.of(context).pop();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.background,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Confirm Pinned Location',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
