import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/amount_text.dart';
import '../../core/widgets/confirm_snackbar.dart';
import '../../core/widgets/custom_visual_loader.dart';
import '../../core/router/navigation_shell.dart';
import '../../core/router/routes.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../data/models/product.dart';
import '../../data/mock/mock_data.dart';

import 'controllers/sale_controller.dart';

class SaleScreen extends ConsumerStatefulWidget {
  const SaleScreen({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends ConsumerState<SaleScreen> {
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _creditChargeController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  bool get _isDirty {
    final state = ref.read(saleControllerProvider(widget.customerId));
    if (state.lineItems.isNotEmpty) {
      return true;
    }
    if (_advanceController.text != '0' && _advanceController.text.isNotEmpty) {
      return true;
    }
    if (_creditChargeController.text.isNotEmpty && _creditChargeController.text != '0') {
      return true;
    }
    if (_remarksController.text.isNotEmpty) {
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
          content: const Text('Are you sure you want to discard this sale record?'),
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
      final backTarget = context.getBackTarget() ?? Routes.dashboard;
      context.go(backTarget);
    }
  }

  @override
  void initState() {
    super.initState();
    _advanceController.text = '0';
  }

  @override
  void dispose() {
    _advanceController.dispose();
    _creditChargeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _onSave() async {
    AppHaptics.mediumImpact();
    final notifier = ref.read(saleControllerProvider(widget.customerId).notifier);
    final success = await notifier.saveSale();

    if (success && mounted) {
      final state = ref.read(saleControllerProvider(widget.customerId));
      ConfirmSnackbar.show(
        context,
        message: 'Successfully recorded ${state.saleType} Sale for ${state.customer.name}',
        onUndo: () {
          // Simply log undo requested
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sale transaction undo requested.')),
          );
        },
      );
      if (mounted) {
        _exitScreen();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(saleControllerProvider(widget.customerId));

    final totalSale = state.totalAmount;
    final creditAdded = state.creditAdded;
    final currentOutstanding = state.outstanding.outstandingAmount;
    final nextOutstanding = currentOutstanding + creditAdded;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: AppScaffold(
        blendHeader: true,
        showSyncIndicator: false,
        appBarLeading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        title: Text(
          'Record Home Appliance Sale',
          style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client card strip
            Card(
              child: ListTile(
                title: Text(
                  state.customer.name,
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Current Outstanding: ${rupees(currentOutstanding)}',
                  style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                ),
                trailing: const Icon(Icons.edit, size: 20),
                onTap: () {
                  final sourceParam = GoRouterState.of(context).uri.queryParameters['source'] ?? '';
                  context.push('${Routes.newClient}?source=sale&parent_source=$sourceParam', extra: state.customer);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Products Catalog Selection trigger
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Line Items / Items Sold',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.foreground,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showProductPicker(state.catalog),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('ADD ITEM'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Line items list
            if (state.lineItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: colors.border),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.shopping_bag, size: 36, color: colors.mutedFg.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'No products added yet',
                      style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
                    ),
                  ],
                ),
              )
            else
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.lineItems.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = state.lineItems[index];

                    return ListTile(
                      title: Text(
                        item.product.name,
                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${rupees(item.price ~/ 100)} x ${item.quantity}',
                        style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rupees(item.subtotal ~/ 100),
                            style: AppTypography.currencySmall.copyWith(color: colors.foreground),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: colors.danger, size: 18),
                            onPressed: () {
                              ref
                                  .read(saleControllerProvider(widget.customerId).notifier)
                                  .updateQuantity(item.product.id, item.quantity - 1);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline, color: colors.primary, size: 18),
                            onPressed: () {
                              ref
                                  .read(saleControllerProvider(widget.customerId).notifier)
                                  .updateQuantity(item.product.id, item.quantity + 1);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: AppSpacing.lg),

            // Advance cash input field
            Text(
              'Down Payment / Advance Received Today (₹)',
              style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
            ),
            const SizedBox(height: AppSpacing.sm),
             TextField(
              controller: _advanceController,
              keyboardType: TextInputType.number,
              style: AppTypography.currencyMedium.copyWith(color: colors.foreground),
              onTap: () {
                if (_advanceController.text == '0') {
                  _advanceController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _advanceController.text.length),
                  );
                }
              },
              onChanged: (val) {
                // Strip negative signs and non-numeric characters
                String sanitized = val.replaceAll(RegExp(r'[^0-9]'), '');
                // Strip leading zeros
                sanitized = sanitized.replaceAll(RegExp(r'^0+'), '');
                if (sanitized.isEmpty) {
                  sanitized = '0';
                }
                if (sanitized != val) {
                  _advanceController.value = TextEditingValue(
                    text: sanitized,
                    selection: TextSelection.collapsed(offset: sanitized.length),
                  );
                }
                final adv = int.tryParse(sanitized) ?? 0;
                ref.read(saleControllerProvider(widget.customerId).notifier).updateAdvance(adv);
              },
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: 'Enter cash down payment collected',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Credit Charge input field
            Text(
              'Credit Charge (Optional)',
              style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _creditChargeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTypography.currencyMedium.copyWith(color: colors.foreground),
                    onChanged: (val) {
                      String sanitized = val.replaceAll(RegExp(r'[^0-9.]'), '');
                      final dots = RegExp(r'\.').allMatches(sanitized);
                      if (dots.length > 1) {
                        final firstDotIdx = sanitized.indexOf('.');
                        sanitized = sanitized.substring(0, firstDotIdx + 1) + 
                            sanitized.substring(firstDotIdx + 1).replaceAll('.', '');
                      }
                      if (sanitized != val) {
                        _creditChargeController.value = TextEditingValue(
                          text: sanitized,
                          selection: TextSelection.collapsed(offset: sanitized.length),
                        );
                      }
                      final parsed = double.tryParse(sanitized) ?? 0.0;
                      ref.read(saleControllerProvider(widget.customerId).notifier).updateCreditChargeValue(parsed);
                    },
                    decoration: InputDecoration(
                      prefixText: state.creditChargeType == 'RUPEE' ? '₹ ' : null,
                      suffixText: state.creditChargeType == 'PERCENT' ? ' %' : null,
                      hintText: 'Enter credit surcharge',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.muted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: colors.border.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref.read(saleControllerProvider(widget.customerId).notifier).toggleCreditChargeType('RUPEE');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: state.creditChargeType == 'RUPEE'
                                ? colors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.horizontal(
                              left: const Radius.circular(AppRadius.md - 1),
                              right: state.creditChargeType == 'RUPEE' ? const Radius.circular(AppRadius.md - 1) : Radius.zero,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '₹',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: state.creditChargeType == 'RUPEE'
                                  ? Colors.white
                                  : colors.foreground,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(saleControllerProvider(widget.customerId).notifier).toggleCreditChargeType('PERCENT');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: state.creditChargeType == 'PERCENT'
                                ? colors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.horizontal(
                              left: state.creditChargeType == 'PERCENT' ? const Radius.circular(AppRadius.md - 1) : Radius.zero,
                              right: const Radius.circular(AppRadius.md - 1),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '%',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: state.creditChargeType == 'PERCENT'
                                  ? Colors.white
                                  : colors.foreground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Checkbox(
                  value: state.isDiscounted,
                  activeColor: colors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(saleControllerProvider(widget.customerId).notifier)
                          .toggleDiscounted(val);
                    }
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discounted Ready Cash Sale',
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Overrides the total price to match the down payment (zero credit).',
                        style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Remarks field
            Text(
              'Remarks / Notes (Optional)',
              style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _remarksController,
              onChanged: (val) => ref
                  .read(saleControllerProvider(widget.customerId).notifier)
                  .updateRemarks(val),
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add remarks about this sales credit purchase...',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Financial Summary Block
            Card(
              color: colors.muted.withValues(alpha: 0.4),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Calculations',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Purchase Value', style: AppTypography.bodyMedium),
                        AmountText(amount: totalSale, style: AppTypography.currencySmall),
                      ],
                    ),
                    if (state.creditChargeAmount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Credit Charge (${state.creditChargeType == 'RUPEE' ? '₹' : '${state.creditChargeValue.toStringAsFixed(0)}%'})',
                            style: AppTypography.bodyMedium.copyWith(color: colors.warning),
                          ),
                          Text(
                            '+ ${rupees(state.creditChargeAmount)}',
                            style: AppTypography.currencySmall.copyWith(color: colors.warning),
                          ),
                        ],
                      ),
                    ],
                    if (state.discountAmount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Discount Applied', style: AppTypography.bodyMedium.copyWith(color: colors.warning)),
                          Text('- ${rupees(state.discountAmount)}', style: AppTypography.currencySmall.copyWith(color: colors.warning)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Discounted Price', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                          AmountText(amount: state.finalAmount, style: AppTypography.currencySmall.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Down Payment (Cash)', style: AppTypography.bodyMedium.copyWith(color: colors.success)),
                        Text('- ${rupees(state.advanceAmount)}', style: AppTypography.currencySmall.copyWith(color: colors.success)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Credit Added (Financed)', style: AppTypography.bodyMedium.copyWith(color: colors.danger)),
                        Text('+ ${rupees(creditAdded)}', style: AppTypography.currencySmall.copyWith(color: colors.danger)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sale Type Classification', style: AppTypography.bodyMedium),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: state.saleType == 'READY'
                                ? colors.success.withValues(alpha: 0.12)
                                : colors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            state.saleType,
                            style: AppTypography.labelSmall.copyWith(
                              color: state.saleType == 'READY' ? colors.success : colors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('New Running Balance Outstanding', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                        AmountText(
                          amount: nextOutstanding,
                          style: AppTypography.currencySmall.copyWith(
                            color: nextOutstanding > 0 ? colors.danger : colors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Warnings / Errors
            if (state.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  state.errorMessage!,
                  style: AppTypography.labelSmall.copyWith(color: colors.danger, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Action Trigger button
            ElevatedButton(
              onPressed: state.isSaving ? null : _onSave,
              child: state.isSaving
                  ? const WaveDotLoader(color: Colors.white, dotSize: 6, spacing: 4)
                  : const Text('RECORD COMPLETED SALE'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  void _showProductPicker(List<Product> products) async {
    final selectedProduct = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ProductPickerSheet(
        products: products,
        onProductSelected: (product) {
          Navigator.pop(context, product); // Close picker and return product
        },
      ),
    );

    if (selectedProduct != null && mounted) {
      _showLineItemEditor(selectedProduct);
    }
  }

  void _showLineItemEditor(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _LineItemEditorSheet(
        product: product,
        onSave: (quantity, unitPrice) {
          Navigator.pop(context); // Close editor sheet first
          final priceInPaise = (unitPrice * 100).round();
          ref.read(saleControllerProvider(widget.customerId).notifier).addProduct(
            product,
            quantity: quantity,
            price: priceInPaise,
          );
        },
      ),
    );
  }
}

class _ProductPickerSheet extends StatefulWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductSelected;

  const _ProductPickerSheet({required this.products, required this.onProductSelected});

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  String _searchQuery = '';
  final Set<String> _selectedCategoryIds = {};

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filtered = widget.products.where((p) {
      if (_selectedCategoryIds.isNotEmpty && !_selectedCategoryIds.contains(p.categoryId)) {
        return false;
      }
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) || 
             p.brand.toLowerCase().contains(q) || 
             p.sku.toLowerCase().contains(q);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select product',
                    style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search name, brand, sku...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategoryIds.isEmpty,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategoryIds.clear();
                          });
                        }
                      },
                      selectedColor: colors.primary.withValues(alpha: 0.12),
                      checkmarkColor: colors.primary,
                      showCheckmark: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _selectedCategoryIds.isEmpty ? colors.primary : colors.border,
                          width: 1,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: _selectedCategoryIds.isEmpty ? colors.primary : colors.mutedFg,
                        fontWeight: _selectedCategoryIds.isEmpty ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ...mockCategoriesList.map((c) {
                    final isSelected = _selectedCategoryIds.contains(c.id);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(c.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategoryIds.add(c.id);
                            } else {
                              _selectedCategoryIds.remove(c.id);
                            }
                          });
                        },
                        selectedColor: colors.primary.withValues(alpha: 0.12),
                        checkmarkColor: colors.primary,
                        showCheckmark: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? colors.primary : colors.border,
                            width: 1,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? colors.primary : colors.mutedFg,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final product = filtered[index];
                  final outOfStock = product.stock <= 0;

                  return InkWell(
                    onTap: outOfStock ? null : () => widget.onProductSelected(product),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: outOfStock ? colors.mutedFg : colors.foreground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product.sku} · ${product.brand} · Stock ${product.stock}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  rupees(product.sellingPrice ~/ 100),
                                  style: AppTypography.currencySmall.copyWith(
                                    color: outOfStock ? colors.mutedFg : colors.primary,
                                  ),
                                ),
                                if (outOfStock) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colors.danger.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'OUT OF STOCK',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.danger,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LineItemEditorSheet extends StatefulWidget {
  final Product product;
  final void Function(int quantity, double unitPrice) onSave;

  const _LineItemEditorSheet({required this.product, required this.onSave});

  @override
  State<_LineItemEditorSheet> createState() => _LineItemEditorSheetState();
}

class _LineItemEditorSheetState extends State<_LineItemEditorSheet> {
  late int _quantity;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _quantity = 1;
    _priceController = TextEditingController(text: (widget.product.sellingPrice / 100).toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentPrice = double.tryParse(_priceController.text) ?? (widget.product.sellingPrice / 100);
    final total = currentPrice * _quantity;
    final isEdited = currentPrice != (widget.product.sellingPrice / 100);

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Line item', style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text(widget.product.name, style: AppTypography.labelLarge),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: Text('Quantity', style: AppTypography.labelMedium),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('$_quantity', style: AppTypography.titleSmall),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Unit price (₹)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              errorText: (double.tryParse(_priceController.text) == null)
                  ? 'Enter a valid price'
                  : (double.tryParse(_priceController.text)! < 0)
                      ? 'Price cannot be negative'
                      : null,
            ),
            onTap: () {
              if (_priceController.text == '0') {
                _priceController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _priceController.text.length),
                );
              }
            },
            onChanged: (val) {
              String cleaned = val.replaceAll(RegExp(r'[^0-9.]'), '');
              final dotIndex = cleaned.indexOf('.');
              if (dotIndex != -1) {
                cleaned = cleaned.substring(0, dotIndex + 1) + 
                          cleaned.substring(dotIndex + 1).replaceAll('.', '');
              }
              if (cleaned.startsWith('0') && cleaned.length > 1 && cleaned[1] != '.') {
                cleaned = cleaned.replaceFirst(RegExp(r'^0+'), '');
                if (cleaned.isEmpty) {
                  cleaned = '0';
                } else if (cleaned.startsWith('.')) {
                  cleaned = '0$cleaned';
                }
              }
              if (cleaned != val) {
                _priceController.value = TextEditingValue(
                  text: cleaned,
                  selection: TextSelection.collapsed(offset: cleaned.length),
                );
              }
              setState(() {});
            },
          ),
          if (isEdited) ...[
            const SizedBox(height: 4),
            Text(
              'Price differs from catalog (₹${(widget.product.sellingPrice / 100).toStringAsFixed(2)})',
              style: AppTypography.labelSmall.copyWith(color: colors.warning),
            ),
          ],
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Line total:', style: AppTypography.labelLarge),
              Text(rupees(total.round()), style: AppTypography.titleMedium.copyWith(color: colors.primary)),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(120, 48),
                ),
                onPressed: (double.tryParse(_priceController.text) == null || double.tryParse(_priceController.text)! < 0)
                    ? null
                    : () => widget.onSave(_quantity, currentPrice),
                child: const Text('Save item'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
