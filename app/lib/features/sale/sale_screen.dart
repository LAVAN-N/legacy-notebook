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
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../data/models/product.dart';
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
      Navigator.pop(context);
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
      builder: (context) {
        final colors = context.colors;

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.8,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Product from Catalog',
                    style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final outOfStock = product.stock <= 0;

                        return ListTile(
                          title: Row(
                            children: [
                              Text(
                                product.name,
                                style: AppTypography.labelLarge.copyWith(
                                  color: outOfStock ? colors.mutedFg : colors.foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (outOfStock) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colors.danger.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
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
                          subtitle: Text(
                            'SKU: ${product.sku} · Brand: ${product.brand} · Stock: ${product.stock} units',
                            style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                          ),
                          trailing: Text(
                            rupees(product.price),
                            style: AppTypography.currencySmall.copyWith(
                              color: outOfStock ? colors.mutedFg : colors.primary,
                            ),
                          ),
                          onTap: outOfStock
                              ? null
                              : () {
                                  AppHaptics.selectionClick();
                                  ref
                                      .read(saleControllerProvider(widget.customerId).notifier)
                                      .addProduct(product);
                                  Navigator.pop(context);
                                },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
