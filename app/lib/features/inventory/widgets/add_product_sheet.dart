import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/config/category_icons.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/providers.dart';
import '../../../data/models/product.dart';
import '../../../data/models/category.dart';
import 'product_camera_screen.dart';

void showAddProductSheet(BuildContext context, {String? initialCategoryId}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _AddProductSheet(initialCategoryId: initialCategoryId);
    },
  );
}

void showEditProductSheet(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _EditProductSheet(product: product);
    },
  );
}

class SkuCardTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text == newValue.text) {
      return newValue;
    }

    final bool isDeleting = newValue.text.length < oldValue.text.length;

    String raw = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    if (raw.length > 9) {
      raw = raw.substring(0, 9);
    }

    if (isDeleting) {
      if (oldValue.text.endsWith('-') &&
          newValue.text == oldValue.text.substring(0, oldValue.text.length - 1)) {
        if (raw.isNotEmpty) {
          raw = raw.substring(0, raw.length - 1);
        }
      }
    }

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('-');
      }
      buffer.write(raw[i]);
    }

    if (!isDeleting) {
      if (raw.length == 3 || raw.length == 6) {
        buffer.write('-');
      }
    }

    final String formatted = buffer.toString();

    int cursorPosition = formatted.length;
    if (newValue.selection.end < newValue.text.length) {
      final String textBeforeCursor = newValue.text.substring(0, newValue.selection.end);
      final int rawCharsBefore = textBeforeCursor.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').length;
      int rawCount = 0;
      int newCursor = 0;
      for (int i = 0; i < formatted.length; i++) {
        if (formatted[i] != '-') {
          rawCount++;
        }
        if (rawCount == rawCharsBefore) {
          newCursor = i + 1;
          break;
        }
      }
      cursorPosition = newCursor.clamp(0, formatted.length);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class SegmentedSkuField extends StatefulWidget {
  final TextEditingController controller;
  final AppColors colors;
  final Set<String>? existingSkus;
  final ValueChanged<String>? onChanged;

  const SegmentedSkuField({
    super.key,
    required this.controller,
    required this.colors,
    this.existingSkus,
    this.onChanged,
  });

  @override
  State<SegmentedSkuField> createState() => _SegmentedSkuFieldState();
}

class _SegmentedSkuFieldState extends State<SegmentedSkuField> {
  @override
  void initState() {
    super.initState();
    _formatInitialText();
  }

  void _formatInitialText() {
    final raw = widget.controller.text.trim();
    if (raw.isNotEmpty && !raw.contains('-')) {
      final clean = raw.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      final buf = StringBuffer();
      for (int i = 0; i < clean.length && i < 9; i++) {
        if (i == 3 || i == 6) buf.write('-');
        buf.write(clean[i]);
      }
      widget.controller.text = buf.toString();
    }
  }

  bool _isValidSku(String text) {
    return RegExp(r'^[A-Z0-9]{3}-[A-Z0-9]{3}-[A-Z0-9]{3}$').hasMatch(text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final text = widget.controller.text.trim().toUpperCase();
    final isComplete = _isValidSku(text);
    final isDuplicate = widget.existingSkus != null && widget.existingSkus!.contains(text);

    return TextFormField(
      controller: widget.controller,
      textCapitalization: TextCapitalization.characters,
      keyboardType: TextInputType.text,
      style: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 2.5,
        color: colors.foreground,
      ),
      inputFormatters: [
        SkuCardTextInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: 'SKU *',
        hintText: 'PRE-COK-10L',
        hintStyle: AppTypography.titleMedium.copyWith(
          color: colors.mutedFg.withValues(alpha: 0.35),
          fontWeight: FontWeight.w600,
          letterSpacing: 2.5,
        ),
        prefixIcon: Icon(Icons.qr_code_outlined, color: colors.primary),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDuplicate)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.danger.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 12, color: colors.danger),
                      const SizedBox(width: 4),
                      Text(
                        'EXISTS',
                        style: TextStyle(
                          color: colors.danger,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.success.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12, color: colors.success),
                      const SizedBox(width: 4),
                      Text(
                        'VALID',
                        style: TextStyle(
                          color: colors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '3-3-3',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'SKU is required (e.g. PRE-COK-10L)';
        }
        final raw = val.trim().toUpperCase();
        if (!RegExp(r'^[A-Z0-9]{3}-[A-Z0-9]{3}-[A-Z0-9]{3}$').hasMatch(raw)) {
          return 'SKU must have 3 parts of 3 chars (e.g. PRE-COK-10L)';
        }
        if (widget.existingSkus != null && widget.existingSkus!.contains(raw)) {
          return 'SKU "$raw" already exists in database';
        }
        return null;
      },
      onChanged: (val) {
        setState(() {});
        widget.onChanged?.call(val);
      },
    );
  }
}

Future<void> _pickMfgDate(BuildContext context, TextEditingController controller) async {
  final theme = Theme.of(context);
  final colors = theme.extension<AppColors>()!;
  final months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  String currentMonth = 'JAN';
  int currentYear = 2026;
  final parts = controller.text.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    final m = parts[0].toUpperCase();
    if (months.contains(m)) currentMonth = m;
    final y = int.tryParse(parts[1]);
    if (y != null && y >= 2015 && y <= 2040) currentYear = y;
  }

  int selectedYear = currentYear;
  String selectedMonth = currentMonth;

  await showModalBottomSheet(
    context: context,
    backgroundColor: colors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Mfg Date',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Year Picker Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setModalState(() {
                              selectedYear--;
                            });
                          },
                        ),
                        Text(
                          '$selectedYear',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setModalState(() {
                              selectedYear++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Month 4x3 Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.0,
                    ),
                    itemCount: months.length,
                    itemBuilder: (context, idx) {
                      final month = months[idx];
                      final isSelected = month == selectedMonth;
                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            selectedMonth = month;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? colors.primary : colors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? colors.primary : colors.border,
                            ),
                          ),
                          child: Text(
                            month,
                            style: TextStyle(
                              color: isSelected ? colors.primaryFg : colors.foreground,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      controller.text = '$selectedMonth $selectedYear';
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Apply Mfg Date'),
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

Widget _buildImageSlot({
  required BuildContext context,
  required int slotNumber,
  required String label,
  required String? imagePath,
  required VoidCallback onTap,
  required VoidCallback onRemove,
  required AppColors colors,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.05),
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(12),
            image: imagePath != null && imagePath.isNotEmpty
                ? (imagePath.startsWith('assets/')
                    ? DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      )
                    : (imagePath.startsWith('http')
                        ? DecorationImage(
                            image: NetworkImage(imagePath),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            image: FileImage(File(imagePath)),
                            fit: BoxFit.cover,
                          )))
                : null,
          ),
          child: imagePath == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 28, color: colors.primary),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to add',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.mutedFg,
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
              : Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#$slotNumber',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
        ),
      ),
      if (imagePath != null) ...[
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, size: 13, color: colors.danger),
                  const SizedBox(width: 2),
                  Text(
                    'Remove',
                    style: AppTypography.labelSmall.copyWith(color: colors.danger, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ] else ...[
        const SizedBox(height: 4),
      ],
    ],
  );
}

class _AddProductSheet extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  const _AddProductSheet({this.initialCategoryId});

  @override
  ConsumerState<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends ConsumerState<_AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategoryId;
  String? _imagePath;
  String? _imagePath2;
  String? _selectedBrand;
  List<String> _brands = [];
  
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _skuController = TextEditingController();
  final _mrpController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '5');
  final _mfgDateController = TextEditingController(text: 'JAN 2026');
  final _warrantyController = TextEditingController(text: '0');
  final _descriptionController = TextEditingController();
  double _markupPercent = 25.0;
  bool _isSubmitting = false;

  bool get _isDirty {
    if (_nameController.text.isNotEmpty ||
        _brandController.text.isNotEmpty ||
        _skuController.text.isNotEmpty ||
        _mrpController.text.isNotEmpty ||
        _costPriceController.text.isNotEmpty ||
        _sellingPriceController.text.isNotEmpty ||
        (_stockController.text != '0' && _stockController.text.isNotEmpty) ||
        _descriptionController.text.isNotEmpty ||
        _imagePath != null ||
        _imagePath2 != null ||
        _mfgDateController.text != 'JAN 2026' ||
        (_warrantyController.text != '0' && _warrantyController.text.isNotEmpty)) {
      return true;
    }
    return false;
  }

  void _handleBack() async {
    if (_isDirty) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes'),
          content: const Text('Are you sure you want to discard this product?'),
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

      if (shouldDiscard == true && mounted) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _mrpController.addListener(_onMrpChanged);
    _costPriceController.addListener(_onCostPriceChanged);
    _sellingPriceController.addListener(_onSellingPriceChanged);

    Future.microtask(() async {
      final configRepo = ref.read(configRepositoryProvider);
      final uniqueBrands = await configRepo.getBrands();
      if (mounted) {
        setState(() {
          _brands = uniqueBrands;
        });
      }
    });
  }

  void _showAddBrandDialog(BuildContext context) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final addCtrl = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        title: Text('Add Brand', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: addCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Brand Name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              Navigator.pop(context, val.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.mutedFg)),
          ),
          ElevatedButton(
            onPressed: () {
              if (addCtrl.text.trim().isNotEmpty) {
                Navigator.pop(context, addCtrl.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    
    if (result != null && result.trim().isNotEmpty && mounted) {
      final trimmed = result.trim();
      final configRepo = ref.read(configRepositoryProvider);
      final currentBrands = await configRepo.getBrands();
      final existing = currentBrands.cast<String?>().firstWhere(
        (b) => b?.toLowerCase() == trimmed.toLowerCase(),
        orElse: () => null,
      );
      final finalBrand = existing ?? trimmed;
      if (existing == null) {
        currentBrands.add(finalBrand);
        currentBrands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        await configRepo.saveBrands(currentBrands);
      }
      setState(() {
        _selectedBrand = finalBrand;
        _brandController.text = finalBrand;
      });
    }
  }

  void _showEditBrandDialog(BuildContext context, String oldBrand) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final editCtrl = TextEditingController(text: oldBrand);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        title: Text('Edit Brand', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: editCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Brand Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.mutedFg)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, editCtrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty && result != oldBrand && mounted) {
      final configRepo = ref.read(configRepositoryProvider);
      final productRepo = ref.read(productRepositoryProvider);
      final currentBrands = await configRepo.getBrands();
      final idx = currentBrands.indexOf(oldBrand);
      if (idx != -1) {
        currentBrands[idx] = result;
      } else if (!currentBrands.contains(result)) {
        currentBrands.add(result);
      }
      currentBrands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      await configRepo.saveBrands(currentBrands);
      await productRepo.renameBrand(oldBrand, result);
      if (mounted) {
        setState(() {
          _selectedBrand = result;
          _brandController.text = result;
        });
      }
    }
  }

  void _showDeleteBrandDialog(BuildContext context, String brand) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        title: Text('Delete Brand', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete brand "$brand"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colors.mutedFg)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.destructive),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      final configRepo = ref.read(configRepositoryProvider);
      final productRepo = ref.read(productRepositoryProvider);
      final currentBrands = await configRepo.getBrands();
      currentBrands.remove(brand);
      await configRepo.saveBrands(currentBrands);
      await productRepo.renameBrand(brand, '');
      if (!context.mounted) return;
      setState(() {
        if (_selectedBrand == brand) {
          _selectedBrand = null;
          _brandController.clear();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brand deleted successfully'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showEditCategorySheet(BuildContext context, String categoryId) {
    final categoriesAsync = ref.read(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? [];
    final category = categories.cast<Category?>().firstWhere(
      (c) => c?.id == categoryId,
      orElse: () => null,
    );
    if (category == null) return;
    final colors = Theme.of(context).extension<AppColors>()!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _EditCategoryDialogContent(
            category: category,
            colors: colors,
            onSave: (updatedCategory) async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final configRepo = ref.read(configRepositoryProvider);
              final currentCategories = await configRepo.getCategories();
              final idx = currentCategories.indexWhere((c) => c.id == categoryId);
              if (idx != -1) {
                currentCategories[idx] = updatedCategory;
                await configRepo.saveCategories(currentCategories);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Category "${updatedCategory.name}" updated successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, String categoryId) async {
    final categoriesAsync = ref.read(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? [];
    final category = categories.cast<Category?>().firstWhere(
      (c) => c?.id == categoryId,
      orElse: () => null,
    );
    if (category == null) return;
    final colors = Theme.of(context).extension<AppColors>()!;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        title: Text('Delete Category', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete category "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colors.mutedFg)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.destructive),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      final configRepo = ref.read(configRepositoryProvider);
      final currentCategories = await configRepo.getCategories();
      currentCategories.removeWhere((c) => c.id == categoryId);
      await configRepo.saveCategories(currentCategories);
      if (!context.mounted) return;
      setState(() {
        if (_selectedCategoryId == categoryId) {
          _selectedCategoryId = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  bool _isUpdatingPrice = false;

  void _onMrpChanged() {
    if (_isUpdatingPrice) return;
    _isUpdatingPrice = true;
    final mrp = double.tryParse(_mrpController.text) ?? 0.0;
    final cost = double.tryParse(_costPriceController.text) ?? 0.0;
    final selling = double.tryParse(_sellingPriceController.text) ?? 0.0;
    
    if (mrp > 0 && selling > mrp) {
      _sellingPriceController.text = mrp.toStringAsFixed(2);
      if (cost > 0) {
        _markupPercent = (((mrp - cost) / cost) * 100).clamp(5.0, 100.0);
      }
    }
    _isUpdatingPrice = false;
    setState(() {});
  }

  void _onCostPriceChanged() {
    if (_isUpdatingPrice) return;
    _isUpdatingPrice = true;
    final cost = double.tryParse(_costPriceController.text) ?? 0.0;
    final mrp = double.tryParse(_mrpController.text) ?? 0.0;
    double selling = cost * (1 + _markupPercent / 100);
    if (mrp > 0 && selling > mrp) {
      selling = mrp;
      if (cost > 0) {
        _markupPercent = (((selling - cost) / cost) * 100).clamp(5.0, 100.0);
      }
    }
    _sellingPriceController.text = selling == 0.0 ? '' : selling.toStringAsFixed(2);
    _isUpdatingPrice = false;
    setState(() {});
  }

  void _onSellingPriceChanged() {
    if (_isUpdatingPrice) return;
    _isUpdatingPrice = true;
    final cost = double.tryParse(_costPriceController.text) ?? 0.0;
    final selling = double.tryParse(_sellingPriceController.text) ?? 0.0;
    final mrp = double.tryParse(_mrpController.text) ?? 0.0;
    
    double finalSelling = selling;
    if (mrp > 0 && selling > mrp) {
      finalSelling = mrp;
      _sellingPriceController.text = mrp.toStringAsFixed(2);
    }
    
    if (cost > 0 && finalSelling >= cost) {
      _markupPercent = (((finalSelling - cost) / cost) * 100).clamp(5.0, 100.0);
    }
    _isUpdatingPrice = false;
    setState(() {});
  }

  void _onMarkupSliderChanged(double value) {
    final snapped = ((value / 5).round() * 5).toDouble();
    setState(() {
      _markupPercent = snapped;
      _isUpdatingPrice = true;
      final cost = double.tryParse(_costPriceController.text) ?? 0.0;
      final mrp = double.tryParse(_mrpController.text) ?? 0.0;
      
      double selling = cost * (1 + _markupPercent / 100);
      if (mrp > 0 && selling > mrp) {
        selling = mrp;
        _markupPercent = (((selling - cost) / cost) * 100).clamp(5.0, 100.0);
      }
      _sellingPriceController.text = selling == 0.0 ? '' : selling.toStringAsFixed(2);
      _isUpdatingPrice = false;
    });
  }

  double get _maxAllowedMarkup {
    final cost = double.tryParse(_costPriceController.text) ?? 0.0;
    final mrp = double.tryParse(_mrpController.text) ?? 0.0;
    if (cost > 0 && mrp > cost) {
      return (((mrp - cost) / cost) * 100).clamp(5.0, 100.0);
    }
    return 100.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _skuController.dispose();
    _mrpController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _mfgDateController.dispose();
    _warrantyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openFilePicker({required int slot}) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
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
                      'Choose Photo #$slot',
                      style: AppTypography.titleMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.camera_alt, color: colors.primary),
                title: Text('Take Photo',
                    style: AppTypography.bodyLarge.copyWith(color: colors.foreground, fontWeight: FontWeight.w500)),
                onTap: () async {
                  navigator.pop();
                  try {
                    final double targetRatio = slot == 2 ? (9 / 16) : (16 / 9);
                    final photoPath = await openProductCamera(context, targetAspectRatio: targetRatio);
                    if (photoPath != null && mounted) {
                      setState(() {
                        if (slot == 1) {
                          _imagePath = photoPath;
                        } else {
                          _imagePath2 = photoPath;
                        }
                      });
                      return;
                    }
                    if (photoPath == null && mounted) {
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 85,
                      );
                      if (image != null && mounted) {
                        final croppedPath = await navigator.push<String>(
                          MaterialPageRoute(
                            builder: (context) => PhotoCropDialog(
                              imagePath: image.path,
                              cropAspectRatio: targetRatio,
                            ),
                          ),
                        );
                        if (croppedPath != null && mounted) {
                          setState(() {
                            if (slot == 1) {
                              _imagePath = croppedPath;
                            } else {
                              _imagePath2 = croppedPath;
                            }
                          });
                        }
                      }
                    }
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error taking photo: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: colors.primary),
                title: Text('Choose from Gallery',
                    style: AppTypography.bodyLarge.copyWith(color: colors.foreground, fontWeight: FontWeight.w500)),
                onTap: () async {
                  navigator.pop();
                  try {
                    final double targetRatio = slot == 2 ? (9 / 16) : (16 / 9);
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (image != null && mounted) {
                      final croppedPath = await navigator.push<String>(
                        MaterialPageRoute(
                          builder: (context) => PhotoCropDialog(
                            imagePath: image.path,
                            cropAspectRatio: targetRatio,
                          ),
                        ),
                      );
                      if (croppedPath != null && mounted) {
                        setState(() {
                          if (slot == 1) {
                            _imagePath = croppedPath;
                          } else {
                            _imagePath2 = croppedPath;
                          }
                        });
                      }
                    }
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error picking image: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.file_present, color: colors.primary),
                title: Text('Select File',
                    style: AppTypography.bodyLarge.copyWith(color: colors.foreground, fontWeight: FontWeight.w500)),
                onTap: () async {
                  navigator.pop();
                  try {
                    final double targetRatio = slot == 2 ? (9 / 16) : (16 / 9);
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png'],
                    );
                    if (result != null && result.files.single.path != null && mounted) {
                      final croppedPath = await navigator.push<String>(
                        MaterialPageRoute(
                          builder: (context) => PhotoCropDialog(
                            imagePath: result.files.single.path!,
                            cropAspectRatio: targetRatio,
                          ),
                        ),
                      );
                      if (croppedPath != null && mounted) {
                        setState(() {
                          if (slot == 1) {
                            _imagePath = croppedPath;
                          } else {
                            _imagePath2 = croppedPath;
                          }
                        });
                      }
                    }
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error picking file: $e')),
                    );
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

  void _showAddCategorySheet(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _AddCategoryDialogContent(
            colors: colors,
            onSave: (newCategory) async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final configRepo = ref.read(configRepositoryProvider);
              final currentCategories = await configRepo.getCategories();
              currentCategories.add(newCategory);
              await configRepo.saveCategories(currentCategories);
              setState(() {
                _selectedCategoryId = newCategory.id;
              });
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Category "${newCategory.name}" created successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final rawMaxMarkup = _maxAllowedMarkup;
    final maxMarkup = ((rawMaxMarkup / 5).floor() * 5).toDouble().clamp(5.0, 100.0);
    final divisions = ((maxMarkup - 5) / 5).round().clamp(1, 20);

    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? mockCategoriesList;

    final productsAsync = ref.watch(productsStreamProvider);
    final allProducts = productsAsync.value ?? [];

    final brandsAsync = ref.watch(brandsStreamProvider);
    final brands = brandsAsync.value ?? _brands;

    // Sourced by selected category's own products
    final categoryProducts = _selectedCategoryId != null
        ? allProducts.where((p) => p.categoryId == _selectedCategoryId).toList()
        : <Product>[];

    final Set<String> brandSet = {};
    if (categoryProducts.isNotEmpty) {
      for (final p in categoryProducts) {
        final b = p.brand.trim();
        if (b.isNotEmpty) {
          brandSet.add(b);
        }
      }
    }

    // Fallback: show all brands only if the category has no products (or no category selected yet)
    if (brandSet.isEmpty) {
      brandSet.addAll(brands.map((b) => b.trim()).where((b) => b.isNotEmpty));
      for (final p in allProducts) {
        final b = p.brand.trim();
        if (b.isNotEmpty) {
          brandSet.add(b);
        }
      }
    }

    // Always preserve current selected brand so dropdown value remains valid
    if (_selectedBrand != null && _selectedBrand!.trim().isNotEmpty) {
      brandSet.add(_selectedBrand!.trim());
    }

    final List<String> availableBrands = brandSet.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final Set<String> existingSkus = allProducts
        .map((p) => p.sku.trim().toUpperCase())
        .where((s) => s.isNotEmpty)
        .toSet();

    Widget buildSliderLabels(double maxMarkup, AppColors colors) {
      final list = <double>[];
      for (double val = 5.0; val <= maxMarkup; val += 5.0) {
        list.add(val);
      }
      
      return Container(
        height: 14,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Stack(
          children: list.map((val) {
            final double fraction = maxMarkup > 5.0 
                ? (val - 5.0) / (maxMarkup - 5.0) 
                : 0.0;
            final double alignX = 2 * fraction - 1;
            return Align(
              alignment: Alignment(alignX, 0),
              child: Text(
                val.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 7.0,
                  color: colors.mutedFg.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24 + MediaQueryData.fromView(View.of(context)).padding.bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Product',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: _handleBack,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              const Divider(),
              const SizedBox(height: 16),

                            Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: categories.any((c) => c.id == _selectedCategoryId) ? _selectedCategoryId : null,
                      decoration: InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category_outlined, color: colors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: categories.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                          if (val != null) {
                            final newCatProducts = allProducts.where((p) => p.categoryId == val).toList();
                            if (newCatProducts.isNotEmpty) {
                              final newCatBrands = newCatProducts
                                  .map((p) => p.brand.trim())
                                  .where((b) => b.isNotEmpty)
                                  .toSet();
                              if (_selectedBrand != null && !newCatBrands.contains(_selectedBrand!.trim())) {
                                _selectedBrand = null;
                                _brandController.clear();
                              }
                            }
                          }
                        });
                      },
                      validator: (val) => val == null ? 'Category is required' : null,
                    ),
                  ),
                  if (_selectedCategoryId != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.edit, color: colors.primary, size: 20),
                      onPressed: () => _showEditCategorySheet(context, _selectedCategoryId!),
                      tooltip: 'Edit Category',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: colors.destructive, size: 20),
                      onPressed: () => _showDeleteCategoryDialog(context, _selectedCategoryId!),
                      tooltip: 'Delete Category',
                    ),
                  ],
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _showAddCategorySheet(context),
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Add new category'),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildImageSlot(
                      context: context,
                      slotNumber: 1,
                      label: 'Photo 1 (16:9)',
                      imagePath: _imagePath,
                      onTap: () => _openFilePicker(slot: 1),
                      onRemove: () => setState(() => _imagePath = null),
                      colors: colors,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildImageSlot(
                      context: context,
                      slotNumber: 2,
                      label: 'Photo 2 (Portrait)',
                      imagePath: _imagePath2,
                      onTap: () => _openFilePicker(slot: 2),
                      onRemove: () => setState(() => _imagePath2 = null),
                      colors: colors,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.shopping_bag_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      menuMaxHeight: 200,
                      value: availableBrands.contains(_selectedBrand) ? _selectedBrand : null,
                      decoration: InputDecoration(
                        labelText: 'Brand *',
                        prefixIcon: Icon(Icons.branding_watermark_outlined, color: colors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: availableBrands.map((b) {
                        return DropdownMenuItem(
                          value: b,
                          child: Text(b),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedBrand = val;
                            _brandController.text = val;
                          });
                        }
                      },
                      validator: (val) => val == null ? 'Brand is required' : null,
                    ),
                  ),
                  if (_selectedBrand != null && availableBrands.contains(_selectedBrand)) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.edit, color: colors.primary, size: 20),
                      onPressed: () => _showEditBrandDialog(context, _selectedBrand!),
                      tooltip: 'Edit Brand',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: colors.destructive, size: 20),
                      onPressed: () => _showDeleteBrandDialog(context, _selectedBrand!),
                      tooltip: 'Delete Brand',
                    ),
                  ],
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _showAddBrandDialog(context),
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Add new brand'),
                ),
              ),
              const SizedBox(height: 12),

              SegmentedSkuField(
                controller: _skuController,
                colors: colors,
                existingSkus: existingSkus,
              ),
              const SizedBox(height: 12),

              // MRP Field
              TextFormField(
                controller: _mrpController,
                decoration: InputDecoration(
                  labelText: 'MRP (₹) *',
                  prefixIcon: Icon(Icons.currency_rupee_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onTap: () {
                  if (_mrpController.text == '0') {
                    _mrpController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _mrpController.text.length),
                    );
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'MRP is required';
                  final parsed = double.tryParse(val);
                  if (parsed == null) return 'Enter a valid number';
                  if (parsed <= 0) return 'MRP must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Cost Price Field
              TextFormField(
                controller: _costPriceController,
                decoration: InputDecoration(
                  labelText: 'Cost Price (₹) *',
                  prefixIcon: Icon(Icons.currency_rupee_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onTap: () {
                  if (_costPriceController.text == '0') {
                    _costPriceController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _costPriceController.text.length),
                    );
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Cost Price is required';
                  final parsed = double.tryParse(val);
                  if (parsed == null) return 'Enter a valid number';
                  if (parsed < 0) return 'Cost Price cannot be negative';
                  final mrp = double.tryParse(_mrpController.text) ?? 0.0;
                  if (mrp > 0 && parsed > mrp) return 'Cost price cannot exceed MRP';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Markup Slider (dotted at 5 multiples, progress bar removed)
              Card(
                elevation: 0,
                color: colors.muted.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colors.border.withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Profit Markup', style: AppTypography.bodySmall.copyWith(color: colors.mutedFg)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_markupPercent.toStringAsFixed(0)}% Markup',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: colors.success.withValues(alpha: 0.8),
                          inactiveTrackColor: colors.muted.withValues(alpha: 0.15),
                          thumbColor: colors.success,
                          overlayColor: colors.success.withValues(alpha: 0.1),
                          trackHeight: 1.5,
                          showValueIndicator: ShowValueIndicator.onDrag,
                          activeTickMarkColor: colors.success,
                          inactiveTickMarkColor: colors.muted.withValues(alpha: 0.5),
                          tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3.0),
                        ),
                        child: Slider(
                          min: 5.0,
                          max: maxMarkup,
                          divisions: divisions,
                          value: _markupPercent.clamp(5.0, maxMarkup),
                          label: '${_markupPercent.toStringAsFixed(0)}%',
                          onChanged: _onMarkupSliderChanged,
                        ),
                      ),
                      const SizedBox(height: 2),
                      buildSliderLabels(maxMarkup, colors),
                      if (maxMarkup < 100.0) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Note: Markup capped at ${maxMarkup.toStringAsFixed(0)}% to stay within MRP.',
                            style: TextStyle(fontSize: 10, color: colors.warning, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Selling Price Field
              TextFormField(
                controller: _sellingPriceController,
                decoration: InputDecoration(
                  labelText: 'Selling Price (₹) *',
                  prefixIcon: Icon(Icons.currency_rupee_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onTap: () {
                  if (_sellingPriceController.text == '0') {
                    _sellingPriceController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _sellingPriceController.text.length),
                    );
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Selling Price is required';
                  final parsed = double.tryParse(val);
                  if (parsed == null) return 'Enter a valid number';
                  if (parsed < 0) return 'Selling Price cannot be negative';
                  final cost = double.tryParse(_costPriceController.text) ?? 0.0;
                  if (parsed < cost) return 'Selling price cannot be less than cost price';
                  final mrp = double.tryParse(_mrpController.text) ?? 0.0;
                  if (mrp > 0 && parsed > mrp) return 'Selling price cannot exceed MRP';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: InputDecoration(
                        labelText: 'Stock *',
                        prefixIcon: Icon(Icons.inventory_outlined, color: colors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                      onTap: () {
                        if (_stockController.text == '0') {
                          _stockController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _stockController.text.length),
                          );
                        }
                      },
                      onChanged: (val) {
                        String sanitized = val.replaceAll(RegExp(r'[^0-9]'), '');
                        sanitized = sanitized.replaceAll(RegExp(r'^0+'), '');
                        if (sanitized.isEmpty) {
                          sanitized = '0';
                        }
                        if (sanitized != val) {
                          _stockController.value = TextEditingValue(
                            text: sanitized,
                            selection: TextSelection.collapsed(offset: sanitized.length),
                          );
                        }
                      },
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Stock is required';
                        final parsed = int.tryParse(val);
                        if (parsed == null) return 'Enter a valid integer';
                        if (parsed < 0) return 'Stock cannot be negative';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            final current = int.tryParse(_stockController.text) ?? 0;
                            if (current > 0) {
                              _stockController.text = (current - 1).toString();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final current = int.tryParse(_stockController.text) ?? 0;
                            _stockController.text = (current + 1).toString();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minStockController,
                      decoration: InputDecoration(
                        labelText: 'Min stock *',
                        prefixIcon: Icon(Icons.warning_amber_outlined, color: colors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                      onTap: () {
                        if (_minStockController.text == '0') {
                          _minStockController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _minStockController.text.length),
                          );
                        }
                      },
                      onChanged: (val) {
                        String sanitized = val.replaceAll(RegExp(r'[^0-9]'), '');
                        sanitized = sanitized.replaceAll(RegExp(r'^0+'), '');
                        if (sanitized.isEmpty) {
                          sanitized = '0';
                        }
                        if (sanitized != val) {
                          _minStockController.value = TextEditingValue(
                            text: sanitized,
                            selection: TextSelection.collapsed(offset: sanitized.length),
                          );
                        }
                      },
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Min stock is required';
                        final parsed = int.tryParse(val);
                        if (parsed == null) return 'Enter a valid integer';
                        if (parsed < 0) return 'Min stock cannot be negative';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            final current = int.tryParse(_minStockController.text) ?? 0;
                            if (current > 0) {
                              _minStockController.text = (current - 1).toString();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final current = int.tryParse(_minStockController.text) ?? 0;
                            _minStockController.text = (current + 1).toString();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Warranty Field with 0.5 incrementor (below Min stock)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _warrantyController,
                      decoration: InputDecoration(
                        labelText: 'Warranty (Years) *',
                        hintText: '0',
                        prefixIcon: Icon(Icons.verified_outlined, color: colors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onTap: () {
                        if (_warrantyController.text == '0') {
                          _warrantyController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _warrantyController.text.length),
                          );
                        }
                      },
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Warranty is required';
                        final parsed = double.tryParse(val.trim());
                        if (parsed == null) return 'Enter a valid number';
                        if (parsed < 0) return 'Warranty cannot be negative';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            final current = double.tryParse(_warrantyController.text) ?? 0.0;
                            if (current >= 0.5) {
                              final next = current - 0.5;
                              _warrantyController.text = (next % 1 == 0) ? next.toInt().toString() : next.toStringAsFixed(1);
                            } else if (current > 0) {
                              _warrantyController.text = '0';
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final current = double.tryParse(_warrantyController.text) ?? 0.0;
                            final next = current + 0.5;
                            _warrantyController.text = (next % 1 == 0) ? next.toInt().toString() : next.toStringAsFixed(1);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mfg Date Field
              TextFormField(
                controller: _mfgDateController,
                readOnly: true,
                onTap: () => _pickMfgDate(context, _mfgDateController),
                decoration: InputDecoration(
                  labelText: 'Mfg Date *',
                  hintText: 'JAN 2026',
                  prefixIcon: Icon(Icons.calendar_month_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Mfg date is required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.description_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleBack,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(140, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedCategoryId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a category')),
                          );
                          return;
                        }

                        final sku = _skuController.text.trim();
                        if (existingSkus.contains(sku.toUpperCase())) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cannot save: SKU "$sku" already exists in database'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (_isSubmitting) return;
                        setState(() => _isSubmitting = true);

                        final repo = ref.read(productRepositoryProvider);
                        final name = _nameController.text.trim();
                        final brand = _brandController.text.trim();
                        final mrp = ((double.tryParse(_mrpController.text) ?? 0.0) * 100).round();
                        final costPrice = ((double.tryParse(_costPriceController.text) ?? 0.0) * 100).round();
                        final sellingPrice = ((double.tryParse(_sellingPriceController.text) ?? 0.0) * 100).round();
                        final stock = int.tryParse(_stockController.text) ?? 0;
                        final minimumStock = int.tryParse(_minStockController.text) ?? 0;
                        final categoryId = _selectedCategoryId!;
                        final description = _descriptionController.text.trim().isEmpty 
                            ? null 
                            : _descriptionController.text.trim();

                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);

                        try {
                          await repo.addProduct(
                            name: name,
                            brand: brand,
                            sku: sku,
                            costPrice: costPrice,
                            sellingPrice: sellingPrice,
                            mrp: mrp,
                            stock: stock,
                            categoryId: categoryId,
                            minimumStock: minimumStock,
                            description: description,
                            imageUrl: _imagePath,
                            imageUrl2: _imagePath2,
                            mfgDate: _mfgDateController.text.trim().isNotEmpty ? _mfgDateController.text.trim() : 'JAN 2026',
                            warranty: double.tryParse(_warrantyController.text.trim()) ?? 0.0,
                          );
                          if (navigator.canPop()) {
                            navigator.pop();
                          }
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Product "$name" added successfully'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Error adding product: $e')),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _isSubmitting = false);
                          }
                        }
                      }
                    },
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Add product'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _EditProductSheet extends ConsumerStatefulWidget {
  final Product product;
  const _EditProductSheet({required this.product});

  @override
  ConsumerState<_EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends ConsumerState<_EditProductSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategoryId;
  String? _imagePath;
  String? _imagePath2;
  String? _selectedBrand;
  List<String> _brands = [];
  
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _skuController;
  late final TextEditingController _mrpController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minimumStockController;
  late final TextEditingController _mfgDateController;
  late final TextEditingController _warrantyController;
  late final TextEditingController _descriptionController;
  double _markupPercent = 25.0;
  bool _isSubmitting = false;

  bool get _isDirty {
    if (_nameController.text != widget.product.name ||
        _brandController.text != widget.product.brand ||
        _skuController.text != widget.product.sku ||
        _mrpController.text != (widget.product.mrp / 100).toString() ||
        _costPriceController.text != (widget.product.costPrice / 100).toString() ||
        _sellingPriceController.text != (widget.product.sellingPrice / 100).toString() ||
        _stockController.text != widget.product.stock.toString() ||
        _minimumStockController.text != widget.product.minimumStock.toString() ||
        _descriptionController.text != (widget.product.description ?? '') ||
        _imagePath != widget.product.imageUrl ||
        _imagePath2 != widget.product.imageUrl2 ||
        _mfgDateController.text != widget.product.mfgDate ||
        _warrantyController.text != widget.product.warranty.toString() ||
        _selectedCategoryId != widget.product.categoryId) {
      return true;
    }
    return false;
  }

  void _handleBack() async {
    if (_isDirty) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes'),
          content: const Text('Are you sure you want to discard your edits?'),
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

      if (shouldDiscard == true && mounted) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.product.categoryId;
    _imagePath = widget.product.imageUrl;
    _imagePath2 = widget.product.imageUrl2;
    _nameController = TextEditingController(text: widget.product.name);
    _brandController = TextEditingController(text: widget.product.brand);
    _skuController = TextEditingController(text: widget.product.sku);
    _mrpController = TextEditingController(text: (widget.product.mrp / 100).toString());
    _costPriceController = TextEditingController(text: (widget.product.costPrice / 100).toString());
    _sellingPriceController = TextEditingController(text: (widget.product.sellingPrice / 100).toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _minimumStockController = TextEditingController(text: widget.product.minimumStock.toString());
    _mfgDateController = TextEditingController(
      text: widget.product.mfgDate.isNotEmpty ? widget.product.mfgDate : 'JAN 2026',
    );
    _warrantyController = TextEditingController(
      text: widget.product.warranty > 0
          ? (widget.product.warranty % 1 == 0
              ? widget.product.warranty.toInt().toString()
              : widget.product.warranty.toString())
          : '0',
    );
    _descriptionController = TextEditingController(text: widget.product.description ?? '');

    _selectedBrand = widget.product.brand;

    Future.microtask(() async {
      final configRepo = ref.read(configRepositoryProvider);
      final uniqueBrands = await configRepo.getBrands();
      if (mounted) {
        setState(() {
          _brands = uniqueBrands;
          if (_selectedBrand != null && !_brands.contains(_selectedBrand!)) {
            _brands.add(_selectedBrand!);
            _brands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          }
        });
      }
    });

    // Calculate initial markup percent
    final cost = widget.product.costPrice.toDouble();
    final selling = widget.product.sellingPrice.toDouble();
    if (cost > 0) {
      _markupPercent = (((selling - cost) / cost) * 100).clamp(5.0, 100.0);
    }

    _mrpController.addListener(_onMrpChanged);
    _costPriceController.addListener(_onCostPriceChanged);
    _sellingPriceController.addListener(_onSellingPriceChanged);
  }

  void _showAddCategorySheet(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _AddCategoryDialogContent(
            colors: colors,
            onSave: (newCategory) async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final configRepo = ref.read(configRepositoryProvider);
              final currentCategories = await configRepo.getCategories();
              currentCategories.add(newCategory);
              await configRepo.saveCategories(currentCategories);
              setState(() {
                _selectedCategoryId = newCategory.id;
              });
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Category "${newCategory.name}" created successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddBrandDialog(BuildContext context) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final addCtrl = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        title: Text('Add Brand', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: addCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Brand Name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              Navigator.pop(context, val.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.mutedFg)),
          ),
          ElevatedButton(
            onPressed: () {
              if (addCtrl.text.trim().isNotEmpty) {
                Navigator.pop(context, addCtrl.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    
    if (result != null && result.trim().isNotEmpty && mounted) {
      final trimmed = result.trim();
      final configRepo = ref.read(configRepositoryProvider);
      final currentBrands = await configRepo.getBrands();
      final existing = currentBrands.cast<String?>().firstWhere(
        (b) => b?.toLowerCase() == trimmed.toLowerCase(),
        orElse: () => null,
      );
      final finalBrand = existing ?? trimmed;
      if (existing == null) {
        currentBrands.add(finalBrand);
        currentBrands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        await configRepo.saveBrands(currentBrands);
      }
      setState(() {
        _selectedBrand = finalBrand;
        _brandController.text = finalBrand;
      });
    }
  }

  void _showEditBrandDialog(BuildContext context, String oldBrand) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final editCtrl = TextEditingController(text: oldBrand);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        title: Text('Edit Brand', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: editCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Brand Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.mutedFg)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, editCtrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty && result != oldBrand && mounted) {
      final configRepo = ref.read(configRepositoryProvider);
      final productRepo = ref.read(productRepositoryProvider);
      final currentBrands = await configRepo.getBrands();
      final idx = currentBrands.indexOf(oldBrand);
      if (idx != -1) {
        currentBrands[idx] = result;
      } else if (!currentBrands.contains(result)) {
        currentBrands.add(result);
      }
      currentBrands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      await configRepo.saveBrands(currentBrands);
      await productRepo.renameBrand(oldBrand, result);
      if (mounted) {
        setState(() {
          _selectedBrand = result;
          _brandController.text = result;
        });
      }
    }
  }

  void _showDeleteBrandDialog(BuildContext context, String brand) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        title: Text('Delete Brand', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete brand "$brand"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colors.mutedFg)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.destructive),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      final configRepo = ref.read(configRepositoryProvider);
      final productRepo = ref.read(productRepositoryProvider);
      final currentBrands = await configRepo.getBrands();
      currentBrands.remove(brand);
      await configRepo.saveBrands(currentBrands);
      await productRepo.renameBrand(brand, '');
      if (!context.mounted) return;
      setState(() {
        if (_selectedBrand == brand) {
          _selectedBrand = null;
          _brandController.clear();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brand deleted successfully'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showEditCategorySheet(BuildContext context, String categoryId) {
    final categoriesAsync = ref.read(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? [];
    final category = categories.cast<Category?>().firstWhere(
      (c) => c?.id == categoryId,
      orElse: () => null,
    );
    if (category == null) return;
    final colors = Theme.of(context).extension<AppColors>()!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _EditCategoryDialogContent(
            category: category,
            colors: colors,
            onSave: (updatedCategory) async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final configRepo = ref.read(configRepositoryProvider);
              final currentCategories = await configRepo.getCategories();
              final idx = currentCategories.indexWhere((c) => c.id == categoryId);
              if (idx != -1) {
                currentCategories[idx] = updatedCategory;
                await configRepo.saveCategories(currentCategories);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Category "${updatedCategory.name}" updated successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, String categoryId) async {
    final categoriesAsync = ref.read(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? [];
    final category = categories.cast<Category?>().firstWhere(
      (c) => c?.id == categoryId,
      orElse: () => null,
    );
    if (category == null) return;
    final colors = Theme.of(context).extension<AppColors>()!;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        title: Text('Delete Category', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete category "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colors.mutedFg)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.destructive),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      final configRepo = ref.read(configRepositoryProvider);
      final currentCategories = await configRepo.getCategories();
      currentCategories.removeWhere((c) => c.id == categoryId);
      await configRepo.saveCategories(currentCategories);
      if (!context.mounted) return;
      setState(() {
        if (_selectedCategoryId == categoryId) {
          _selectedCategoryId = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  bool _isUpdatingPrice = false;

  void _onMrpChanged() {
    if (_isUpdatingPrice) return;
    _isUpdatingPrice = true;
    final mrp = double.tryParse(_mrpController.text) ?? 0.0;
    final cost = double.tryParse(_costPriceController.text) ?? 0.0;
    final selling = double.tryParse(_sellingPriceController.text) ?? 0.0;
    
    if (mrp > 0 && selling > mrp) {
      _sellingPriceController.text = mrp.toStringAsFixed(2);
      if (cost > 0) {
        _markupPercent = (((mrp - cost) / cost) * 100).clamp(5.0, 100.0);
      }
    }
    _isUpdatingPrice = false;
    setState(() {});
  }

  void _onCostPriceChanged() {
    if (_isUpdatingPrice) return;
    _isUpdatingPrice = true;
    final cost = double.tryParse(_costPriceController.text) ?? 0.0;
    final mrp = double.tryParse(_mrpController.text) ?? 0.0;
    double selling = cost * (1 + _markupPercent / 100);
    if (mrp > 0 && selling > mrp) {
      selling = mrp;
      if (cost > 0) {
        _markupPercent = (((selling - cost) / cost) * 100).clamp(5.0, 100.0);
      }
    }
    _sellingPriceController.text = selling == 0.0 ? '' : selling.toStringAsFixed(2);
    _isUpdatingPrice = false;
    setState(() {});
  }

  void _onSellingPriceChanged() {
    if (_isUpdatingPrice) return;
    _isUpdatingPrice = true;
    final cost = double.tryParse(_costPriceController.text) ?? 0.0;
    final selling = double.tryParse(_sellingPriceController.text) ?? 0.0;
    final mrp = double.tryParse(_mrpController.text) ?? 0.0;
    
    double finalSelling = selling;
    if (mrp > 0 && selling > mrp) {
      finalSelling = mrp;
      _sellingPriceController.text = mrp.toStringAsFixed(2);
    }
    
    if (cost > 0 && finalSelling >= cost) {
      _markupPercent = (((finalSelling - cost) / cost) * 100).clamp(5.0, 100.0);
    }
    _isUpdatingPrice = false;
    setState(() {});
  }

  void _onMarkupSliderChanged(double value) {
    final snapped = ((value / 5).round() * 5).toDouble();
    setState(() {
      _markupPercent = snapped;
      _isUpdatingPrice = true;
      final cost = double.tryParse(_costPriceController.text) ?? 0.0;
      final mrp = double.tryParse(_mrpController.text) ?? 0.0;
      
      double selling = cost * (1 + _markupPercent / 100);
      if (mrp > 0 && selling > mrp) {
        selling = mrp;
        _markupPercent = (((selling - cost) / cost) * 100).clamp(5.0, 100.0);
      }
      _sellingPriceController.text = selling == 0.0 ? '' : selling.toStringAsFixed(2);
      _isUpdatingPrice = false;
    });
  }

  double get _maxAllowedMarkup {
    final cost = double.tryParse(_costPriceController.text) ?? 0.0;
    final mrp = double.tryParse(_mrpController.text) ?? 0.0;
    if (cost > 0 && mrp > cost) {
      return (((mrp - cost) / cost) * 100).clamp(5.0, 100.0);
    }
    return 100.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _skuController.dispose();
    _mrpController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minimumStockController.dispose();
    _mfgDateController.dispose();
    _warrantyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openFilePicker({required int slot}) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
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
                      'Choose Photo $slot',
                      style: AppTypography.titleMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.camera_alt, color: colors.primary),
                title: Text('Take Photo',
                    style: AppTypography.bodyLarge.copyWith(color: colors.foreground, fontWeight: FontWeight.w500)),
                onTap: () async {
                  navigator.pop();
                  try {
                    final double targetRatio = slot == 2 ? (9 / 16) : (16 / 9);
                    final photoPath = await openProductCamera(context, targetAspectRatio: targetRatio);
                    if (photoPath != null && mounted) {
                      setState(() {
                        if (slot == 1) {
                          _imagePath = photoPath;
                        } else {
                          _imagePath2 = photoPath;
                        }
                      });
                      return;
                    }
                    if (photoPath == null && mounted) {
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 85,
                      );
                      if (image != null && mounted) {
                        final croppedPath = await navigator.push<String>(
                          MaterialPageRoute(
                            builder: (context) => PhotoCropDialog(
                              imagePath: image.path,
                              cropAspectRatio: targetRatio,
                            ),
                          ),
                        );
                        if (croppedPath != null && mounted) {
                          setState(() {
                            if (slot == 1) {
                              _imagePath = croppedPath;
                            } else {
                              _imagePath2 = croppedPath;
                            }
                          });
                        }
                      }
                    }
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error taking photo: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: colors.primary),
                title: Text('Choose from Gallery',
                    style: AppTypography.bodyLarge.copyWith(color: colors.foreground, fontWeight: FontWeight.w500)),
                onTap: () async {
                  navigator.pop();
                  try {
                    final double targetRatio = slot == 2 ? (9 / 16) : (16 / 9);
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (image != null && mounted) {
                      final croppedPath = await navigator.push<String>(
                        MaterialPageRoute(
                          builder: (context) => PhotoCropDialog(
                            imagePath: image.path,
                            cropAspectRatio: targetRatio,
                          ),
                        ),
                      );
                      if (croppedPath != null && mounted) {
                        setState(() {
                          if (slot == 1) {
                            _imagePath = croppedPath;
                          } else {
                            _imagePath2 = croppedPath;
                          }
                        });
                      }
                    }
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error picking image: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.file_present, color: colors.primary),
                title: Text('Select File',
                    style: AppTypography.bodyLarge.copyWith(color: colors.foreground, fontWeight: FontWeight.w500)),
                onTap: () async {
                  navigator.pop();
                  try {
                    final double targetRatio = slot == 2 ? (9 / 16) : (16 / 9);
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png'],
                    );
                    if (result != null && result.files.single.path != null && mounted) {
                      final croppedPath = await navigator.push<String>(
                        MaterialPageRoute(
                          builder: (context) => PhotoCropDialog(
                            imagePath: result.files.single.path!,
                            cropAspectRatio: targetRatio,
                          ),
                        ),
                      );
                      if (croppedPath != null && mounted) {
                        setState(() {
                          if (slot == 1) {
                            _imagePath = croppedPath;
                          } else {
                            _imagePath2 = croppedPath;
                          }
                        });
                      }
                    }
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error picking file: $e')),
                    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final rawMaxMarkup = _maxAllowedMarkup;
    final maxMarkup = ((rawMaxMarkup / 5).floor() * 5).toDouble().clamp(5.0, 100.0);
    final divisions = ((maxMarkup - 5) / 5).round().clamp(1, 20);

    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? mockCategoriesList;

    final productsAsync = ref.watch(productsStreamProvider);
    final allProducts = productsAsync.value ?? [];

    final brandsAsync = ref.watch(brandsStreamProvider);
    final brands = brandsAsync.value ?? _brands;

    // Sourced by selected category's own products
    final categoryProducts = _selectedCategoryId != null
        ? allProducts.where((p) => p.categoryId == _selectedCategoryId).toList()
        : <Product>[];

    final Set<String> brandSet = {};
    if (categoryProducts.isNotEmpty) {
      for (final p in categoryProducts) {
        final b = p.brand.trim();
        if (b.isNotEmpty) {
          brandSet.add(b);
        }
      }
    }

    // Fallback: show all brands only if the category has no products (or no category selected yet)
    if (brandSet.isEmpty) {
      brandSet.addAll(brands.map((b) => b.trim()).where((b) => b.isNotEmpty));
      for (final p in allProducts) {
        final b = p.brand.trim();
        if (b.isNotEmpty) {
          brandSet.add(b);
        }
      }
    }

    // Always preserve current selected brand so dropdown value remains valid
    if (_selectedBrand != null && _selectedBrand!.trim().isNotEmpty) {
      brandSet.add(_selectedBrand!.trim());
    }

    final List<String> availableBrands = brandSet.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final Set<String> existingSkus = allProducts
        .where((p) => p.id != widget.product.id)
        .map((p) => p.sku.trim().toUpperCase())
        .where((s) => s.isNotEmpty)
        .toSet();

    Widget buildSliderLabels(double maxMarkup, AppColors colors) {
      final list = <double>[];
      for (double val = 5.0; val <= maxMarkup; val += 5.0) {
        list.add(val);
      }
      
      return Container(
        height: 14,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Stack(
          children: list.map((val) {
            final double fraction = maxMarkup > 5.0 
                ? (val - 5.0) / (maxMarkup - 5.0) 
                : 0.0;
            final double alignX = 2 * fraction - 1;
            return Align(
              alignment: Alignment(alignX, 0),
              child: Text(
                val.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 7.0,
                  color: colors.mutedFg.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24 + MediaQueryData.fromView(View.of(context)).padding.bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Product',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: _handleBack,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              const Divider(),
              const SizedBox(height: 16),

                            Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: categories.any((c) => c.id == _selectedCategoryId) ? _selectedCategoryId : null,
                      decoration: InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category_outlined, color: colors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: categories.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                          if (val != null) {
                            final newCatProducts = allProducts.where((p) => p.categoryId == val).toList();
                            if (newCatProducts.isNotEmpty) {
                              final newCatBrands = newCatProducts
                                  .map((p) => p.brand.trim())
                                  .where((b) => b.isNotEmpty)
                                  .toSet();
                              if (_selectedBrand != null && !newCatBrands.contains(_selectedBrand!.trim())) {
                                _selectedBrand = null;
                                _brandController.clear();
                              }
                            }
                          }
                        });
                      },
                      validator: (val) => val == null ? 'Category is required' : null,
                    ),
                  ),
                  if (_selectedCategoryId != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.edit, color: colors.primary, size: 20),
                      onPressed: () => _showEditCategorySheet(context, _selectedCategoryId!),
                      tooltip: 'Edit Category',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: colors.destructive, size: 20),
                      onPressed: () => _showDeleteCategoryDialog(context, _selectedCategoryId!),
                      tooltip: 'Delete Category',
                    ),
                  ],
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _showAddCategorySheet(context),
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Add new category'),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildImageSlot(
                      context: context,
                      slotNumber: 1,
                      label: 'Photo 1 (16:9)',
                      imagePath: _imagePath,
                      onTap: () => _openFilePicker(slot: 1),
                      onRemove: () => setState(() => _imagePath = null),
                      colors: colors,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildImageSlot(
                      context: context,
                      slotNumber: 2,
                      label: 'Photo 2 (Portrait)',
                      imagePath: _imagePath2,
                      onTap: () => _openFilePicker(slot: 2),
                      onRemove: () => setState(() => _imagePath2 = null),
                      colors: colors,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.shopping_bag_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      menuMaxHeight: 200,
                      value: availableBrands.contains(_selectedBrand) ? _selectedBrand : null,
                      decoration: InputDecoration(
                        labelText: 'Brand *',
                        prefixIcon: Icon(Icons.branding_watermark_outlined, color: colors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: availableBrands.map((b) {
                        return DropdownMenuItem(
                          value: b,
                          child: Text(b),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedBrand = val;
                            _brandController.text = val;
                          });
                        }
                      },
                      validator: (val) => val == null ? 'Brand is required' : null,
                    ),
                  ),
                  if (_selectedBrand != null && availableBrands.contains(_selectedBrand)) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.edit, color: colors.primary, size: 20),
                      onPressed: () => _showEditBrandDialog(context, _selectedBrand!),
                      tooltip: 'Edit Brand',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: colors.destructive, size: 20),
                      onPressed: () => _showDeleteBrandDialog(context, _selectedBrand!),
                      tooltip: 'Delete Brand',
                    ),
                  ],
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _showAddBrandDialog(context),
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Add new brand'),
                ),
              ),
              const SizedBox(height: 12),

              SegmentedSkuField(
                controller: _skuController,
                colors: colors,
                existingSkus: existingSkus,
              ),
              const SizedBox(height: 12),

              // MRP Field
              TextFormField(
                controller: _mrpController,
                decoration: InputDecoration(
                  labelText: 'MRP (₹) *',
                  prefixIcon: Icon(Icons.currency_rupee_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onTap: () {
                  if (_mrpController.text == '0') {
                    _mrpController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _mrpController.text.length),
                    );
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'MRP is required';
                  final parsed = double.tryParse(val);
                  if (parsed == null) return 'Enter a valid number';
                  if (parsed <= 0) return 'MRP must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Cost Price Field
              TextFormField(
                controller: _costPriceController,
                decoration: InputDecoration(
                  labelText: 'Cost Price (₹) *',
                  prefixIcon: Icon(Icons.currency_rupee_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onTap: () {
                  if (_costPriceController.text == '0') {
                    _costPriceController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _costPriceController.text.length),
                    );
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Cost Price is required';
                  final parsed = double.tryParse(val);
                  if (parsed == null) return 'Enter a valid number';
                  if (parsed < 0) return 'Cost Price cannot be negative';
                  final mrp = double.tryParse(_mrpController.text) ?? 0.0;
                  if (mrp > 0 && parsed > mrp) return 'Cost price cannot exceed MRP';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Markup Slider (dotted at 5 multiples, progress bar removed)
              Card(
                elevation: 0,
                color: colors.muted.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colors.border.withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Profit Markup', style: AppTypography.bodySmall.copyWith(color: colors.mutedFg)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_markupPercent.toStringAsFixed(0)}% Markup',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: colors.success.withValues(alpha: 0.8),
                          inactiveTrackColor: colors.muted.withValues(alpha: 0.15),
                          thumbColor: colors.success,
                          overlayColor: colors.success.withValues(alpha: 0.1),
                          trackHeight: 1.5,
                          showValueIndicator: ShowValueIndicator.onDrag,
                          activeTickMarkColor: colors.success,
                          inactiveTickMarkColor: colors.muted.withValues(alpha: 0.5),
                          tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3.0),
                        ),
                        child: Slider(
                          min: 5.0,
                          max: maxMarkup,
                          divisions: divisions,
                          value: _markupPercent.clamp(5.0, maxMarkup),
                          label: '${_markupPercent.toStringAsFixed(0)}%',
                          onChanged: _onMarkupSliderChanged,
                        ),
                      ),
                      const SizedBox(height: 2),
                      buildSliderLabels(maxMarkup, colors),
                      if (maxMarkup < 100.0) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Note: Markup capped at ${maxMarkup.toStringAsFixed(0)}% to stay within MRP.',
                            style: TextStyle(fontSize: 10, color: colors.warning, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Selling Price Field
              TextFormField(
                controller: _sellingPriceController,
                decoration: InputDecoration(
                  labelText: 'Selling Price (₹) *',
                  prefixIcon: Icon(Icons.currency_rupee_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onTap: () {
                  if (_sellingPriceController.text == '0') {
                    _sellingPriceController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _sellingPriceController.text.length),
                    );
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Selling Price is required';
                  final parsed = double.tryParse(val);
                  if (parsed == null) return 'Enter a valid number';
                  if (parsed < 0) return 'Selling Price cannot be negative';
                  final cost = double.tryParse(_costPriceController.text) ?? 0.0;
                  if (parsed < cost) return 'Selling price cannot be less than cost price';
                  final mrp = double.tryParse(_mrpController.text) ?? 0.0;
                  if (mrp > 0 && parsed > mrp) return 'Selling price cannot exceed MRP';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: InputDecoration(
                        labelText: 'Stock *',
                        prefixIcon: Icon(Icons.inventory_outlined, color: colors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                      onTap: () {
                        if (_stockController.text == '0') {
                          _stockController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _stockController.text.length),
                          );
                        }
                      },
                      onChanged: (val) {
                        String sanitized = val.replaceAll(RegExp(r'[^0-9]'), '');
                        sanitized = sanitized.replaceAll(RegExp(r'^0+'), '');
                        if (sanitized.isEmpty) {
                          sanitized = '0';
                        }
                        if (sanitized != val) {
                          _stockController.value = TextEditingValue(
                            text: sanitized,
                            selection: TextSelection.collapsed(offset: sanitized.length),
                          );
                        }
                      },
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Stock is required';
                        final parsed = int.tryParse(val);
                        if (parsed == null) return 'Enter a valid integer';
                        if (parsed < 0) return 'Stock cannot be negative';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            final current = int.tryParse(_stockController.text) ?? 0;
                            if (current > 0) {
                              _stockController.text = (current - 1).toString();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final current = int.tryParse(_stockController.text) ?? 0;
                            _stockController.text = (current + 1).toString();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minimumStockController,
                      decoration: InputDecoration(
                        labelText: 'Min stock *',
                        prefixIcon: Icon(Icons.warning_amber_outlined, color: colors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                      onTap: () {
                        if (_minimumStockController.text == '0') {
                          _minimumStockController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _minimumStockController.text.length),
                          );
                        }
                      },
                      onChanged: (val) {
                        String sanitized = val.replaceAll(RegExp(r'[^0-9]'), '');
                        sanitized = sanitized.replaceAll(RegExp(r'^0+'), '');
                        if (sanitized.isEmpty) {
                          sanitized = '0';
                        }
                        if (sanitized != val) {
                          _minimumStockController.value = TextEditingValue(
                            text: sanitized,
                            selection: TextSelection.collapsed(offset: sanitized.length),
                          );
                        }
                      },
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Min stock is required';
                        final parsed = int.tryParse(val);
                        if (parsed == null) return 'Enter a valid integer';
                        if (parsed < 0) return 'Min stock cannot be negative';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            final current = int.tryParse(_minimumStockController.text) ?? 0;
                            if (current > 0) {
                              _minimumStockController.text = (current - 1).toString();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final current = int.tryParse(_minimumStockController.text) ?? 0;
                            _minimumStockController.text = (current + 1).toString();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Warranty Field with 0.5 incrementor (below Min stock)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _warrantyController,
                      decoration: InputDecoration(
                        labelText: 'Warranty (Years) *',
                        hintText: '0',
                        prefixIcon: Icon(Icons.verified_outlined, color: colors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onTap: () {
                        if (_warrantyController.text == '0') {
                          _warrantyController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _warrantyController.text.length),
                          );
                        }
                      },
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Warranty is required';
                        final parsed = double.tryParse(val.trim());
                        if (parsed == null) return 'Enter a valid number';
                        if (parsed < 0) return 'Warranty cannot be negative';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            final current = double.tryParse(_warrantyController.text) ?? 0.0;
                            if (current >= 0.5) {
                              final next = current - 0.5;
                              _warrantyController.text = (next % 1 == 0) ? next.toInt().toString() : next.toStringAsFixed(1);
                            } else if (current > 0) {
                              _warrantyController.text = '0';
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final current = double.tryParse(_warrantyController.text) ?? 0.0;
                            final next = current + 0.5;
                            _warrantyController.text = (next % 1 == 0) ? next.toInt().toString() : next.toStringAsFixed(1);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mfg Date Field
              TextFormField(
                controller: _mfgDateController,
                readOnly: true,
                onTap: () => _pickMfgDate(context, _mfgDateController),
                decoration: InputDecoration(
                  labelText: 'Mfg Date *',
                  hintText: 'JAN 2026',
                  prefixIcon: Icon(Icons.calendar_month_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Mfg date is required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.description_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleBack,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(140, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        final sku = _skuController.text.trim();
                        if (existingSkus.contains(sku.toUpperCase())) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cannot save: SKU "$sku" already exists on another product'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (_isSubmitting) return;
                        setState(() => _isSubmitting = true);

                        final repo = ref.read(productRepositoryProvider);
                        final updated = widget.product.copyWith(
                          name: _nameController.text.trim(),
                          brand: _brandController.text.trim(),
                          sku: _skuController.text.trim(),
                          mrp: ((double.tryParse(_mrpController.text) ?? 0.0) * 100).round(),
                          costPrice: ((double.tryParse(_costPriceController.text) ?? 0.0) * 100).round(),
                          sellingPrice: ((double.tryParse(_sellingPriceController.text) ?? 0.0) * 100).round(),
                          stock: int.tryParse(_stockController.text) ?? 0,
                          minimumStock: int.tryParse(_minimumStockController.text) ?? widget.product.minimumStock,
                          categoryId: _selectedCategoryId!,
                          description: _descriptionController.text.trim().isEmpty 
                              ? null 
                              : _descriptionController.text.trim(),
                          imageUrl: _imagePath,
                          imageUrl2: _imagePath2,
                          mfgDate: _mfgDateController.text.trim().isNotEmpty 
                              ? _mfgDateController.text.trim() 
                              : 'JAN 2026',
                          warranty: double.tryParse(_warrantyController.text.trim()) ?? 0.0,
                          updatedAt: DateTime.now().toIso8601String(),
                        );
 
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
 
                        try {
                          await repo.updateProduct(updated);
                          if (navigator.canPop()) {
                            navigator.pop();
                          }
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Product "${updated.name}" updated successfully'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Error updating product: $e')),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _isSubmitting = false);
                          }
                        }
                      }
                    },
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _AddCategoryDialogContent extends StatefulWidget {
  final AppColors colors;
  final ValueChanged<Category> onSave;

  const _AddCategoryDialogContent({
    required this.colors,
    required this.onSave,
  });

  @override
  State<_AddCategoryDialogContent> createState() => _AddCategoryDialogContentState();
}

class _AddCategoryDialogContentState extends State<_AddCategoryDialogContent> {
  final _nameController = TextEditingController();
  String _selectedIconName = 'frying-pan';
  bool _isSubmitting = false;

  bool get _isDirty {
    return _nameController.text.isNotEmpty;
  }

  void _handleBack() async {
    if (_isDirty) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes'),
          content: const Text('Are you sure you want to discard this category?'),
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

      if (shouldDiscard == true && mounted) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  final List<CategoryIconItem> _availableIcons = CategoryIcons.availableIcons;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add new category', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Category name *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose Category Icon',
            style: AppTypography.labelMedium.copyWith(color: widget.colors.mutedFg),
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: widget.colors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final item = _availableIcons[index];
                final name = item.name;
                final isSelected = name == _selectedIconName;
                return Tooltip(
                  message: item.label,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIconName = name;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.colors.primary.withValues(alpha: 0.15)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? widget.colors.primary
                              : widget.colors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        color: isSelected
                            ? widget.colors.primary
                            : widget.colors.mutedFg,
                        size: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _handleBack,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(100, 44),
                ),
                onPressed: _isSubmitting ? null : () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter category name')),
                    );
                    return;
                  }
                  if (_isSubmitting) return;
                  setState(() => _isSubmitting = true);

                  final cleanName = name.trim();
                  final slug = cleanName
                      .toLowerCase()
                      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
                      .replaceAll(RegExp(r'^-+|-+$'), '');
                  final catId = slug.isNotEmpty
                      ? 'cat-$slug'
                      : 'cat-${DateTime.now().millisecondsSinceEpoch}';
                  final newCategory = Category(
                    id: catId,
                    name: cleanName,
                    icon: _selectedIconName,
                    productCount: 0,
                  );
                  widget.onSave(newCategory);
                },
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _EditCategoryDialogContent extends StatefulWidget {
  final Category category;
  final AppColors colors;
  final ValueChanged<Category> onSave;

  const _EditCategoryDialogContent({
    required this.category,
    required this.colors,
    required this.onSave,
  });

  @override
  State<_EditCategoryDialogContent> createState() => _EditCategoryDialogContentState();
}

class _EditCategoryDialogContentState extends State<_EditCategoryDialogContent> {
  late final TextEditingController _nameController;
  late String _selectedIconName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedIconName = widget.category.icon;
  }

  bool get _isDirty {
    return _nameController.text != widget.category.name || _selectedIconName != widget.category.icon;
  }

  void _handleBack() async {
    if (_isDirty) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes'),
          content: const Text('Are you sure you want to discard your edits?'),
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

      if (shouldDiscard == true && mounted) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  final List<CategoryIconItem> _availableIcons = CategoryIcons.availableIcons;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Category', style: AppTypography.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Category name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose Category Icon',
              style: AppTypography.labelMedium.copyWith(color: widget.colors.mutedFg),
            ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: widget.colors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final item = _availableIcons[index];
                  final name = item.name;
                  final isSelected = name == _selectedIconName;
                  return Tooltip(
                    message: item.label,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIconName = name;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.colors.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? widget.colors.primary
                                : widget.colors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected
                              ? widget.colors.primary
                              : widget.colors.mutedFg,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _handleBack,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(100, 44),
                  ),
                  onPressed: _isSubmitting ? null : () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter category name')),
                      );
                      return;
                    }
                    if (_isSubmitting) return;
                    setState(() => _isSubmitting = true);

                    final updatedCategory = widget.category.copyWith(
                      name: name,
                      icon: _selectedIconName,
                    );
                    widget.onSave(updatedCategory);
                  },
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class PhotoCropDialog extends StatefulWidget {
  final String imagePath;
  final double cropAspectRatio;

  const PhotoCropDialog({
    super.key,
    required this.imagePath,
    this.cropAspectRatio = 16 / 9,
  });

  @override
  State<PhotoCropDialog> createState() => _PhotoCropDialogState();
}

class _PhotoCropDialogState extends State<PhotoCropDialog> {
  final TransformationController _transformationController = TransformationController();
  bool _isCropping = false;
  int? _imageWidth;
  int? _imageHeight;
  Size? _viewportSize;
  Offset? _viewportOffset;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_handleTransformationChanged);
    _loadImageDimensions();
  }

  @override
  void dispose() {
    _transformationController.removeListener(_handleTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _loadImageDimensions() async {
    try {
      String cleanPath = widget.imagePath;
      if (cleanPath.startsWith('file://')) {
        cleanPath = Uri.parse(cleanPath).toFilePath();
      }
      final bytes = await File(cleanPath).readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _imageWidth = frameInfo.image.width;
          _imageHeight = frameInfo.image.height;
        });
        _handleTransformationChanged();
      }
    } catch (e) {
      debugPrint('Error loading image dimensions: $e');
    }
  }

  void _handleTransformationChanged() {
    if (_imageWidth == null || _imageHeight == null) return;

    final matrix = _transformationController.value;
    final double scale = matrix.getMaxScaleOnAxis();
    double tx = matrix.entry(0, 3);
    double ty = matrix.entry(1, 3);

    final size = _viewportSize ?? MediaQuery.of(context).size;
    final double r = _imageWidth! / _imageHeight!;
    final double R = size.width / size.height;

    double wImg, hImg;
    if (r > R) {
      wImg = size.width;
      hImg = size.width / r;
    } else {
      hImg = size.height;
      wImg = size.height * r;
    }

    final double leftImg = (size.width - wImg) / 2;
    final double topImg = (size.height - hImg) / 2;

    final double cropWidth;
    final double cropHeight;
    if (widget.cropAspectRatio >= 1.0) {
      cropWidth = (size.width - 32).clamp(240.0, 360.0);
      cropHeight = cropWidth / widget.cropAspectRatio;
    } else {
      cropHeight = (size.height * 0.55).clamp(280.0, 480.0);
      cropWidth = cropHeight * widget.cropAspectRatio;
    }
    final double leftCrop = (size.width - cropWidth) / 2;
    final double topCrop = (size.height - cropHeight) / 2;
    final double rightCrop = leftCrop + cropWidth;
    final double bottomCrop = topCrop + cropHeight;

    final double minScaleX = cropWidth / wImg;
    final double minScaleY = cropHeight / hImg;
    final double minScale = minScaleX > minScaleY ? minScaleX : minScaleY;

    double newScale = scale;
    if (scale < minScale) {
      newScale = minScale;
    }

    final double maxTx = leftCrop - leftImg * newScale;
    final double minTx = rightCrop - (leftImg + wImg) * newScale;

    final double maxTy = topCrop - topImg * newScale;
    final double minTy = bottomCrop - (topImg + hImg) * newScale;

    double newTx = tx;
    double newTy = ty;

    if (minTx <= maxTx) {
      newTx = tx.clamp(minTx, maxTx);
    } else {
      newTx = (minTx + maxTx) / 2;
    }

    if (minTy <= maxTy) {
      newTy = ty.clamp(minTy, maxTy);
    } else {
      newTy = (minTy + maxTy) / 2;
    }

    if (newScale != scale || newTx != tx || newTy != ty) {
      final newMatrix = Matrix4.identity()
        ..setEntry(0, 0, newScale)
        ..setEntry(1, 1, newScale)
        ..setEntry(0, 3, newTx)
        ..setEntry(1, 3, newTy);

      _transformationController.removeListener(_handleTransformationChanged);
      _transformationController.value = newMatrix;
      _transformationController.addListener(_handleTransformationChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Crop Product Photo', style: AppTypography.titleMedium.copyWith(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: _isCropping
                ? null
                : () async {
                    setState(() {
                      _isCropping = true;
                    });
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final size = _viewportSize ?? MediaQuery.of(context).size;
                      final double cropWidth;
                      final double cropHeight;
                      if (widget.cropAspectRatio >= 1.0) {
                        cropWidth = (size.width - 32).clamp(240.0, 360.0);
                        cropHeight = cropWidth / widget.cropAspectRatio;
                      } else {
                        cropHeight = (size.height * 0.55).clamp(280.0, 480.0);
                        cropWidth = cropHeight * widget.cropAspectRatio;
                      }
                      final currentCropSize = Size(cropWidth, cropHeight);
                      final offset = _viewportOffset ?? Offset(
                        (size.width - cropWidth) / 2,
                        (size.height - cropHeight) / 2,
                      );
                      final croppedPath = await cropImage(
                        imagePath: widget.imagePath,
                        transform: _transformationController.value,
                        imageSize: size,
                        viewportSize: currentCropSize,
                        viewportOffset: offset,
                      );
                      if (mounted) {
                        navigator.pop(croppedPath);
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() {
                          _isCropping = false;
                        });
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error cropping image: $e')),
                        );
                      }
                    }
                  },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewportWidth = constraints.maxWidth;
          final viewportHeight = constraints.maxHeight;
          final double currentCropWidth;
          final double currentCropHeight;
          if (widget.cropAspectRatio >= 1.0) {
            currentCropWidth = (viewportWidth - 32).clamp(240.0, 360.0);
            currentCropHeight = currentCropWidth / widget.cropAspectRatio;
          } else {
            currentCropHeight = (viewportHeight * 0.55).clamp(280.0, 480.0);
            currentCropWidth = currentCropHeight * widget.cropAspectRatio;
          }
          final currentCropSize = Size(currentCropWidth, currentCropHeight);
          final currentViewportOffset = Offset(
            (viewportWidth - currentCropWidth) / 2,
            (viewportHeight - currentCropHeight) / 2,
          );

          _viewportSize = Size(viewportWidth, viewportHeight);
          _viewportOffset = currentViewportOffset;

          return Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  boundaryMargin: const EdgeInsets.all(300),
                  child: SizedBox(
                    width: viewportWidth,
                    height: viewportHeight,
                    child: Image.file(
                      File(widget.imagePath.startsWith('file://')
                          ? Uri.parse(widget.imagePath).toFilePath()
                          : widget.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: CutoutPainter(
                      cutoutRect: Rect.fromLTWH(
                        currentViewportOffset.dx,
                        currentViewportOffset.dy,
                        currentCropSize.width,
                        currentCropSize.height,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Pinch to zoom · Drag to pan',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
              if (_isCropping)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class CutoutPainter extends CustomPainter {
  final Rect cutoutRect;
  CutoutPainter({required this.cutoutRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.7);
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutRRect = RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12));
    final cutoutPath = Path()..addRRect(cutoutRRect);
    final finalPath = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    canvas.drawPath(finalPath, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(cutoutRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<String> cropImage({
  required String imagePath,
  required Matrix4 transform,
  required Size imageSize,
  required Size viewportSize,
  required Offset viewportOffset,
}) async {
  String cleanPath = imagePath;
  if (cleanPath.startsWith('file://')) {
    cleanPath = Uri.parse(cleanPath).toFilePath();
  }
  final bytes = await File(cleanPath).readAsBytes();
  final ui.Codec codec = await ui.instantiateImageCodec(bytes);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image image = frameInfo.image;

  const double exportScale = 2.0;
  final outWidth = (viewportSize.width * exportScale).toInt();
  final outHeight = (viewportSize.height * exportScale).toInt();

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, outWidth.toDouble(), outHeight.toDouble()),
  );

  canvas.scale(exportScale, exportScale);
  canvas.translate(-viewportOffset.dx, -viewportOffset.dy);
  canvas.transform(transform.storage);

  paintImage(
    canvas: canvas,
    rect: Rect.fromLTWH(0, 0, imageSize.width, imageSize.height),
    image: image,
    fit: BoxFit.contain,
  );

  final picture = recorder.endRecording();
  final croppedImage = await picture.toImage(outWidth, outHeight);

  final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
  final croppedBytes = byteData!.buffer.asUint8List();

  final tempDir = Directory.systemTemp;
  final croppedPath =
      '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';
  await File(croppedPath).writeAsBytes(croppedBytes);

  return croppedPath;
}

class _SearchableBrandDialog extends StatefulWidget {
  final AppColors colors;
  final List<String> brands;
  final String? initialBrand;
  final ValueChanged<String> onSelect;

  const _SearchableBrandDialog({
    required this.colors,
    required this.brands,
    required this.initialBrand,
    required this.onSelect,
  });

  @override
  State<_SearchableBrandDialog> createState() => _SearchableBrandDialogState();
}

class _SearchableBrandDialogState extends State<_SearchableBrandDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late List<String> _filteredBrands;

  @override
  void initState() {
    super.initState();
    _filteredBrands = List.from(widget.brands);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      if (_searchQuery.isEmpty) {
        _filteredBrands = List.from(widget.brands);
      } else {
        _filteredBrands = widget.brands
            .where((b) => b.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final showAddOption = _searchQuery.isNotEmpty && 
        !widget.brands.any((b) => b.toLowerCase() == _searchQuery.toLowerCase());

    return Dialog(
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 350, maxWidth: 320),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Brand',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search brand...',
                prefixIcon: Icon(Icons.search, size: 20, color: colors.mutedFg),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredBrands.isEmpty && !showAddOption
                  ? Center(
                      child: Text(
                        'No brands found',
                        style: TextStyle(color: colors.mutedFg, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredBrands.length + (showAddOption ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _filteredBrands.length) {
                          final brand = _filteredBrands[index];
                          final isSelected = widget.initialBrand == brand;
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: Text(
                              brand,
                              style: TextStyle(
                                color: isSelected ? colors.primary : colors.foreground,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected 
                                ? Icon(Icons.check, color: colors.primary, size: 16) 
                                : null,
                            onTap: () {
                              widget.onSelect(brand);
                              Navigator.pop(context);
                            },
                          );
                        } else {
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            leading: Icon(Icons.add_circle_outline, color: colors.primary, size: 18),
                            title: Text(
                              'Add "$_searchQuery"',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              widget.onSelect(_searchQuery);
                              Navigator.pop(context);
                            },
                          );
                        }
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: colors.mutedFg)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
