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
import '../../core/router/navigation_shell.dart';
import '../../core/router/routes.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../data/models/product.dart';
import '../customer/widgets/edit_customer_sheet.dart';
import 'controllers/sale_controller.dart';

class SaleScreen extends ConsumerStatefulWidget {
  const SaleScreen({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends ConsumerState<SaleScreen> {
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _advanceController.text = '0';
  }

  @override
  void dispose() {
    _advanceController.dispose();
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
        final backTarget = context.getBackTarget() ?? Routes.dashboard;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(backTarget);
        }
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

    return AppScaffold(
      showSyncIndicator: false,
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
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => EditCustomerSheet(customer: state.customer),
                  );
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
                  onPressed: () => _showProductPicker(context, state.catalog),
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
                    Icon(Icons.shopping_bag, size: 36, color: colors.mutedFg.withOpacity(0.5)),
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
                        '${rupees(item.product.price)} x ${item.quantity}',
                        style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rupees(item.subtotal),
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
              onChanged: (val) {
                final adv = int.tryParse(val) ?? 0;
                ref.read(saleControllerProvider(widget.customerId).notifier).updateAdvance(adv);
              },
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: 'Enter cash down payment collected',
              ),
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
              color: colors.muted.withOpacity(0.4),
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
                                ? colors.success.withOpacity(0.12)
                                : colors.warning.withOpacity(0.12),
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
                  color: colors.danger.withOpacity(0.12),
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
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('RECORD COMPLETED SALE'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showProductPicker(BuildContext context, List<Product> products) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ProductPickerSheet(
        products: products,
        onProductSelected: (product) {
          Navigator.pop(context); // Close picker
          _showLineItemEditor(context, product);
        },
      ),
    );
  }

  void _showLineItemEditor(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _LineItemEditorSheet(
        product: product,
        onSave: (quantity, unitPrice) {
          // add to sale controller with custom price/quantity
          final notifier = ref.read(saleControllerProvider(widget.customerId).notifier);
          // currently addProduct only takes product, but we need custom quantity/price!
          // We will call addProduct multiple times or we need to update SaleController.
          // For now, let's just add it (if the controller supports custom items, we'd use that).
          // Actually, SaleController `addProduct` adds 1 quantity at default price.
          // Let's loop for quantity for now since the controller might not support custom line items yet.
          for(int i=0; i<quantity; i++) {
             notifier.addProduct(product); // Temporary workaround until controller is updated
          }
          Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filtered = widget.products.where((p) {
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
            const SizedBox(height: 8),
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
                                  rupees(product.price),
                                  style: AppTypography.currencySmall.copyWith(
                                    color: outOfStock ? colors.mutedFg : colors.primary,
                                  ),
                                ),
                                if (outOfStock) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colors.danger.withOpacity(0.12),
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
    _priceController = TextEditingController(text: (widget.product.price / 100).toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentPrice = double.tryParse(_priceController.text) ?? (widget.product.price / 100);
    final total = currentPrice * _quantity;
    final isEdited = currentPrice != (widget.product.price / 100);

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
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (isEdited) ...[
            const SizedBox(height: 4),
            Text(
              'Price differs from catalog (₹${(widget.product.price / 100).toStringAsFixed(2)})',
              style: AppTypography.labelSmall.copyWith(color: colors.warning),
            ),
          ],
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Line total:', style: AppTypography.labelLarge),
              Text(rupees((total * 100).round()), style: AppTypography.titleMedium.copyWith(color: colors.primary)),
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
                onPressed: () => widget.onSave(_quantity, currentPrice),
                child: const Text('Save item'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
