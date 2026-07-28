import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/providers.dart';
import '../../../data/models/product.dart';
import '../../../data/models/category.dart';

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
  String? _selectedBrand;
  List<String> _brands = [];
  final _brandKey = GlobalKey<FormFieldState<String>>();
  
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _skuController = TextEditingController();
  final _mrpController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '5');
  final _descriptionController = TextEditingController();
  double _markupPercent = 25.0;

  bool get _isDirty {
    if (_nameController.text.isNotEmpty ||
        _brandController.text.isNotEmpty ||
        _skuController.text.isNotEmpty ||
        _mrpController.text.isNotEmpty ||
        _costPriceController.text.isNotEmpty ||
        _sellingPriceController.text.isNotEmpty ||
        (_stockController.text != '0' && _stockController.text.isNotEmpty) ||
        _descriptionController.text.isNotEmpty ||
        _imagePath != null) {
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
    final uniqueBrands = mockProductsList.map((p) => p.brand).toSet().toList();
    uniqueBrands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _brands = uniqueBrands;
    _mrpController.addListener(_onMrpChanged);
    _costPriceController.addListener(_onCostPriceChanged);
    _sellingPriceController.addListener(_onSellingPriceChanged);
  }

  void _showAddBrandSheet(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.background,
          title: Text(
            'Add New Brand',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Brand Name',
              hintText: 'e.g., Samsung',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colors.mutedFg)),
            ),
            TextButton(
              onPressed: () {
                final newBrand = nameController.text.trim();
                if (newBrand.isNotEmpty) {
                  Navigator.pop(context);
                  setState(() {
                    if (!_brands.contains(newBrand)) {
                      _brands.add(newBrand);
                      _brands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                    }
                    _selectedBrand = newBrand;
                    _brandController.text = newBrand;
                    _brandKey.currentState?.didChange(newBrand);
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
    _descriptionController.dispose();
    super.dispose();
  }

  void _openFilePicker() async {
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
                      'Choose Product Image',
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
                    final String? croppedPath = await navigator.push<String>(
                      MaterialPageRoute(
                        builder: (context) => const CameraCaptureScreen(),
                      ),
                    );
                    if (croppedPath != null && mounted) {
                      setState(() {
                        _imagePath = croppedPath;
                      });
                    }
                  } catch (e) {
                    try {
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 85,
                      );
                      if (image != null && mounted) {
                        final croppedPath = await navigator.push<String>(
                          MaterialPageRoute(
                            builder: (context) => PhotoCropDialog(imagePath: image.path),
                          ),
                        );
                        if (croppedPath != null && mounted) {
                          setState(() {
                            _imagePath = croppedPath;
                          });
                        }
                      }
                    } catch (e2) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Error taking photo: $e2')),
                      );
                    }
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
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (image != null && mounted) {
                      final croppedPath = await navigator.push<String>(
                        MaterialPageRoute(
                          builder: (context) => PhotoCropDialog(imagePath: image.path),
                        ),
                      );
                      if (croppedPath != null && mounted) {
                        setState(() {
                          _imagePath = croppedPath;
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
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png'],
                    );
                    if (result != null && result.files.single.path != null && mounted) {
                      final croppedPath = await navigator.push<String>(
                        MaterialPageRoute(
                          builder: (context) => PhotoCropDialog(imagePath: result.files.single.path!),
                        ),
                      );
                      if (croppedPath != null && mounted) {
                        setState(() {
                          _imagePath = croppedPath;
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
            onSave: (newCategory) {
              Navigator.pop(context);
              setState(() {
                mockCategoriesList.add(newCategory);
                _selectedCategoryId = newCategory.id;
              });
              ScaffoldMessenger.of(context).showSnackBar(
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

              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: mockCategoriesList.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (val) => val == null ? 'Category is required' : null,
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

              Center(
                child: GestureDetector(
                  onTap: _openFilePicker,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.05),
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(12),
                      image: _imagePath != null && _imagePath!.isNotEmpty
                          ? (_imagePath!.startsWith('assets/')
                              ? DecorationImage(
                                  image: AssetImage(_imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : (_imagePath!.startsWith('http')
                                  ? DecorationImage(
                                      image: NetworkImage(_imagePath!),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: FileImage(File(_imagePath!)),
                                      fit: BoxFit.cover,
                                    )))
                          : null,
                    ),
                    child: _imagePath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 36, color: colors.primary),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to choose product image',
                                style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              if (_imagePath != null) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _imagePath = null),
                    icon: Icon(Icons.delete_outline, size: 14, color: colors.danger),
                    label: Text('Remove photo', style: AppTypography.labelLarge.copyWith(color: colors.danger)),
                  ),
                ),
              ],
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

              DropdownButtonFormField<String>(
                key: _brandKey,
                initialValue: _selectedBrand,
                decoration: InputDecoration(
                  labelText: 'Brand *',
                  prefixIcon: Icon(Icons.branding_watermark_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  ..._brands.map((b) => DropdownMenuItem(
                        value: b,
                        child: Text(b),
                      )),
                  DropdownMenuItem(
                    value: 'add_new_brand',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: colors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Add new brand...',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (val) async {
                  if (val == 'add_new_brand') {
                    _showAddBrandSheet(context);
                  } else if (val != null) {
                    setState(() {
                      _selectedBrand = val;
                      _brandController.text = val;
                    });
                  }
                },
                validator: (val) => (val == null || val == 'add_new_brand' || val.trim().isEmpty) ? 'Brand is required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _skuController,
                decoration: InputDecoration(
                  labelText: 'SKU *',
                  prefixIcon: Icon(Icons.qr_code_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'SKU is required' : null,
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedCategoryId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a category')),
                          );
                          return;
                        }

                        final repo = ref.read(productRepositoryProvider);
                        final name = _nameController.text.trim();
                        final brand = _brandController.text.trim();
                        final sku = _skuController.text.trim();
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
                          );
                          navigator.pop();
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
                        }
                      }
                    },
                    child: const Text('Add product'),
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
  String? _selectedBrand;
  List<String> _brands = [];
  final _brandKey = GlobalKey<FormFieldState<String>>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _skuController;
  late final TextEditingController _mrpController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minimumStockController;
  late final TextEditingController _descriptionController;
  double _markupPercent = 25.0;

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
    _nameController = TextEditingController(text: widget.product.name);
    _brandController = TextEditingController(text: widget.product.brand);
    _skuController = TextEditingController(text: widget.product.sku);
    _mrpController = TextEditingController(text: (widget.product.mrp / 100).toString());
    _costPriceController = TextEditingController(text: (widget.product.costPrice / 100).toString());
    _sellingPriceController = TextEditingController(text: (widget.product.sellingPrice / 100).toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _minimumStockController = TextEditingController(text: widget.product.minimumStock.toString());
    _descriptionController = TextEditingController(text: widget.product.description ?? '');

    final uniqueBrands = mockProductsList.map((p) => p.brand).toSet().toList();
    uniqueBrands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _brands = uniqueBrands;
    _selectedBrand = widget.product.brand;
    if (_selectedBrand != null && !_brands.contains(_selectedBrand!)) {
      _brands.add(_selectedBrand!);
      _brands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }

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

  void _showAddBrandSheet(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.background,
          title: Text(
            'Add New Brand',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Brand Name',
              hintText: 'e.g., Samsung',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colors.mutedFg)),
            ),
            TextButton(
              onPressed: () {
                final newBrand = nameController.text.trim();
                if (newBrand.isNotEmpty) {
                  Navigator.pop(context);
                  setState(() {
                    if (!_brands.contains(newBrand)) {
                      _brands.add(newBrand);
                      _brands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                    }
                    _selectedBrand = newBrand;
                    _brandController.text = newBrand;
                    _brandKey.currentState?.didChange(newBrand);
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
    _descriptionController.dispose();
    super.dispose();
  }

  void _openFilePicker() async {
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
                      'Choose Product Image',
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
                    final String? croppedPath = await navigator.push<String>(
                      MaterialPageRoute(
                        builder: (context) => const CameraCaptureScreen(),
                      ),
                    );
                    if (croppedPath != null && mounted) {
                      setState(() {
                        _imagePath = croppedPath;
                      });
                    }
                  } catch (e) {
                    try {
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 85,
                      );
                      if (image != null && mounted) {
                        final croppedPath = await navigator.push<String>(
                          MaterialPageRoute(
                            builder: (context) => PhotoCropDialog(imagePath: image.path),
                          ),
                        );
                        if (croppedPath != null && mounted) {
                          setState(() {
                            _imagePath = croppedPath;
                          });
                        }
                      }
                    } catch (e2) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Error taking photo: $e2')),
                      );
                    }
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
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (image != null && mounted) {
                      final croppedPath = await navigator.push<String>(
                        MaterialPageRoute(
                          builder: (context) => PhotoCropDialog(imagePath: image.path),
                        ),
                      );
                      if (croppedPath != null && mounted) {
                        setState(() {
                          _imagePath = croppedPath;
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
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png'],
                    );
                    if (result != null && result.files.single.path != null && mounted) {
                      final croppedPath = await navigator.push<String>(
                        MaterialPageRoute(
                          builder: (context) => PhotoCropDialog(imagePath: result.files.single.path!),
                        ),
                      );
                      if (croppedPath != null && mounted) {
                        setState(() {
                          _imagePath = croppedPath;
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

              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: mockCategoriesList.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (val) => val == null ? 'Category is required' : null,
              ),
              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: _openFilePicker,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.05),
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(12),
                      image: _imagePath != null && _imagePath!.isNotEmpty
                          ? (_imagePath!.startsWith('assets/')
                              ? DecorationImage(
                                  image: AssetImage(_imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : (_imagePath!.startsWith('http')
                                  ? DecorationImage(
                                      image: NetworkImage(_imagePath!),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: FileImage(File(_imagePath!)),
                                      fit: BoxFit.cover,
                                    )))
                          : null,
                    ),
                    child: _imagePath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 36, color: colors.primary),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to choose product image',
                                style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              if (_imagePath != null) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _imagePath = null),
                    icon: Icon(Icons.delete_outline, size: 14, color: colors.danger),
                    label: Text('Remove photo', style: AppTypography.labelLarge.copyWith(color: colors.danger)),
                  ),
                ),
              ],
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

              DropdownButtonFormField<String>(
                key: _brandKey,
                initialValue: _selectedBrand,
                decoration: InputDecoration(
                  labelText: 'Brand *',
                  prefixIcon: Icon(Icons.branding_watermark_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  ..._brands.map((b) => DropdownMenuItem(
                        value: b,
                        child: Text(b),
                      )),
                  DropdownMenuItem(
                    value: 'add_new_brand',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: colors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Add new brand...',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (val) async {
                  if (val == 'add_new_brand') {
                    _showAddBrandSheet(context);
                  } else if (val != null) {
                    setState(() {
                      _selectedBrand = val;
                      _brandController.text = val;
                    });
                  }
                },
                validator: (val) => (val == null || val == 'add_new_brand' || val.trim().isEmpty) ? 'Brand is required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _skuController,
                decoration: InputDecoration(
                  labelText: 'SKU *',
                  prefixIcon: Icon(Icons.qr_code_outlined, color: colors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'SKU is required' : null,
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
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
                        );
 
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
 
                        try {
                          await repo.updateProduct(updated);
                          navigator.pop();
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
                        }
                      }
                    },
                    child: const Text('Save Changes'),
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

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'frying-pan', 'icon': Icons.kitchen, 'keywords': 'kitchen food frying pan cook pot'},
    {'name': 'shirt', 'icon': Icons.checkroom, 'keywords': 'shirt clothes dress checkroom hanger'},
    {'name': 'speaker', 'icon': Icons.speaker, 'keywords': 'speaker sound music audio device'},
    {'name': 'lightbulb', 'icon': Icons.lightbulb, 'keywords': 'lightbulb light bulb electricity idea'},
    {'name': 'wind', 'icon': Icons.air, 'keywords': 'wind air fan weather AC'},
    {'name': 'shopping-bag', 'icon': Icons.shopping_bag, 'keywords': 'bag shopping purchase item store'},
    {'name': 'phone', 'icon': Icons.phone_android, 'keywords': 'phone mobile android screen electronics'},
    {'name': 'laptop', 'icon': Icons.laptop, 'keywords': 'laptop computer macbook pc screen office'},
    {'name': 'chair', 'icon': Icons.chair, 'keywords': 'chair furniture seat table sofa home'},
    {'name': 'tv', 'icon': Icons.tv, 'keywords': 'tv television display monitor video screen'},
    {'name': 'book', 'icon': Icons.book, 'keywords': 'book read library school education paper'},
    {'name': 'toy', 'icon': Icons.toys, 'keywords': 'toy game play kids robot controller'},
  ];

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
            height: 160,
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
                final name = item['name'] as String;
                final isSelected = name == _selectedIconName;
                return InkWell(
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
                      item['icon'] as IconData,
                      color: isSelected
                          ? widget.colors.primary
                          : widget.colors.mutedFg,
                      size: 24,
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
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter category name')),
                    );
                    return;
                  }
                  final newCategory = Category(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    icon: _selectedIconName,
                    productCount: 0,
                  );
                  widget.onSave(newCategory);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = 'No cameras found';
        });
        return;
      }
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _initialized = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const viewportSize = Size(280, 280);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Capture Product Photo', style: AppTypography.titleMedium.copyWith(color: Colors.white)),
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: AppTypography.bodyLarge.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            )
          : !_initialized
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final viewportWidth = constraints.maxWidth;
                    final viewportHeight = constraints.maxHeight;
                    final viewportOffset = Offset(
                      (viewportWidth - viewportSize.width) / 2,
                      (viewportHeight - viewportSize.height) / 2,
                    );

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CameraPreview(_controller!),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: CutoutPainter(
                                cutoutRect: Rect.fromLTWH(
                                  viewportOffset.dx,
                                  viewportOffset.dy,
                                  viewportSize.width,
                                  viewportSize.height,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          left: 16,
                          right: 16,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Align product photo within the box',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () async {
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  final XFile photo = await _controller!.takePicture();
                                  final croppedPath = await navigator.push<String>(
                                    MaterialPageRoute(
                                      builder: (context) => PhotoCropDialog(imagePath: photo.path),
                                    ),
                                  );
                                  if (croppedPath != null && mounted) {
                                    navigator.pop(croppedPath);
                                  }
                                } catch (e) {
                                  messenger.showSnackBar(
                                    SnackBar(content: Text('Error taking photo: $e')),
                                  );
                                }
                              },
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                                child: const Center(
                                  child: Icon(Icons.camera_alt, color: Colors.white, size: 36),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                ),
    );
  }
}

class PhotoCropDialog extends StatefulWidget {
  final String imagePath;
  const PhotoCropDialog({super.key, required this.imagePath});

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

    const double cropSize = 280.0;
    final double leftCrop = (size.width - cropSize) / 2;
    final double topCrop = (size.height - cropSize) / 2;
    final double rightCrop = leftCrop + cropSize;
    final double bottomCrop = topCrop + cropSize;

    final double minScaleX = cropSize / wImg;
    final double minScaleY = cropSize / hImg;
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
    const viewportSize = Size(280, 280);

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
                      final offset = _viewportOffset ?? Offset(
                        (size.width - viewportSize.width) / 2,
                        (size.height - viewportSize.height) / 2,
                      );
                      final croppedPath = await cropImage(
                        imagePath: widget.imagePath,
                        transform: _transformationController.value,
                        imageSize: size,
                        viewportSize: viewportSize,
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
          final currentViewportSize = Size(viewportWidth, viewportHeight);
          final currentViewportOffset = Offset(
            (viewportWidth - viewportSize.width) / 2,
            (viewportHeight - viewportSize.height) / 2,
          );

          _viewportSize = currentViewportSize;
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
                        viewportSize.width,
                        viewportSize.height,
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
        }
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
    final cutoutPath = Path()..addRect(cutoutRect);
    final finalPath = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    canvas.drawPath(finalPath, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(cutoutRect, borderPaint);
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

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, viewportSize.width, viewportSize.height),
  );

  canvas.translate(-viewportOffset.dx, -viewportOffset.dy);
  canvas.transform(transform.storage);

  paintImage(
    canvas: canvas,
    rect: Rect.fromLTWH(0, 0, imageSize.width, imageSize.height),
    image: image,
    fit: BoxFit.contain,
  );

  final picture = recorder.endRecording();
  final croppedImage = await picture.toImage(
    viewportSize.width.toInt(),
    viewportSize.height.toInt(),
  );

  final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
  final croppedBytes = byteData!.buffer.asUint8List();

  final tempDir = Directory.systemTemp;
  final croppedPath =
      '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';
  await File(croppedPath).writeAsBytes(croppedBytes);

  return croppedPath;
}
