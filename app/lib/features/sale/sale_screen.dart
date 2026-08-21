import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
import '../../data/providers.dart';

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
  final TextEditingController _lendAmountController = TextEditingController();
  String? _selectedProductId;

  bool get _isDirty {
    final state = ref.read(saleControllerProvider(widget.customerId));
    if (state.lineItems.isNotEmpty) {
      return true;
    }
    if (_advanceController.text != '0' && _advanceController.text.isNotEmpty) {
      return true;
    }
    if (_lendAmountController.text != '0' && _lendAmountController.text.isNotEmpty) {
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
    _lendAmountController.text = '0';
  }

  @override
  void dispose() {
    _advanceController.dispose();
    _creditChargeController.dispose();
    _remarksController.dispose();
    _lendAmountController.dispose();
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

    ref.listen<SaleScreenState>(saleControllerProvider(widget.customerId), (prev, next) {
      if (prev?.advanceAmount != next.advanceAmount &&
          _advanceController.text != next.advanceAmount.toString()) {
        _advanceController.text = next.advanceAmount.toString();
      }
    });

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
          state.isLend ? 'Record Cash Loan / Lend' : 'Record Home Appliance Sale',
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Outstanding: ${rupees(currentOutstanding)}',
                      style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                    ),
                    if (state.customer.credit > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Available Credit: ${rupees(state.customer.credit)}',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: const Icon(Icons.edit, size: 20),
                onTap: () {
                  final sourceParam = GoRouterState.of(context).uri.queryParameters['source'] ?? '';
                  context.push('${Routes.newClient}?source=sale&parent_source=$sourceParam', extra: state.customer);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (state.customer.credit > 0) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: state.isCreditApplied
                      ? colors.success.withValues(alpha: 0.1)
                      : colors.muted.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: state.isCreditApplied
                        ? colors.success.withValues(alpha: 0.3)
                        : colors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.isCreditApplied ? Icons.check_circle_outline : Icons.info_outline,
                      color: state.isCreditApplied ? colors.success : colors.mutedFg,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Returned Credit: ${rupees(state.customer.credit)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.foreground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            state.isCreditApplied
                                ? 'Applying ${rupees(state.appliedCreditAmount)} credit towards this purchase.'
                                : 'Apply this credit to reduce outstanding balance.',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.mutedFg,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(saleControllerProvider(widget.customerId).notifier)
                            .toggleApplyCredit(!state.isCreditApplied);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.isCreditApplied ? colors.danger : colors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(state.isCreditApplied ? 'Remove' : 'Apply'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            _buildDatePickerRow(context, ref, state.selectedDate),
            const SizedBox(height: AppSpacing.md),
            _buildToggleBar(context, ref, state),
            const SizedBox(height: AppSpacing.lg),

            if (!state.isLend) ...[
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
            ] else ...[
              // Lend Amount input field
              Text(
                'Lend Amount (₹) *',
                style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _lendAmountController,
                keyboardType: TextInputType.number,
                style: AppTypography.currencyMedium.copyWith(color: colors.foreground),
                onTap: () {
                  if (_lendAmountController.text == '0') {
                    _lendAmountController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _lendAmountController.text.length),
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
                    _lendAmountController.value = TextEditingValue(
                      text: sanitized,
                      selection: TextSelection.collapsed(offset: sanitized.length),
                    );
                  }
                  final amount = int.tryParse(sanitized) ?? 0;
                  ref.read(saleControllerProvider(widget.customerId).notifier).updateLendAmount(amount);
                },
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  hintText: 'Enter principal amount to lend',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            if (!state.isLend) ...[
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
            ],

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
            const SizedBox(height: AppSpacing.lg),

            if (!state.isLend) ...[
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
            ],

            if (!state.isLend && state.lineItems.length > 1) ...[
              _buildSaleAllocationSection(context, ref, state),
              const SizedBox(height: AppSpacing.lg),
            ],

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
            const SizedBox(height: AppSpacing.xl),

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
                        Text(state.isLend ? 'Principal Lent Amount' : 'Total Purchase Value', style: AppTypography.bodyMedium),
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
                    if (state.advanceAmount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Down Payment (Cash)', style: AppTypography.bodyMedium.copyWith(color: colors.success)),
                          Text('- ${rupees(state.advanceAmount)}', style: AppTypography.currencySmall.copyWith(color: colors.success)),
                        ],
                      ),
                    ],
                    if (state.appliedCreditAmount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Applied Returned Credit', style: AppTypography.bodyMedium.copyWith(color: colors.success)),
                          Text('- ${rupees(state.appliedCreditAmount)}', style: AppTypography.currencySmall.copyWith(color: colors.success)),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(state.isLend ? 'Credit Added' : 'Credit Added (Financed)', style: AppTypography.bodyMedium.copyWith(color: colors.danger)),
                        Text('+ ${rupees(creditAdded)}', style: AppTypography.currencySmall.copyWith(color: colors.danger)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(state.isLend ? 'Classification' : 'Sale Type Classification', style: AppTypography.bodyMedium),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: state.isLend || state.saleType == 'CREDIT'
                                ? colors.warning.withValues(alpha: 0.12)
                                : colors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            state.isLend ? 'LEND' : state.saleType,
                            style: AppTypography.labelSmall.copyWith(
                              color: state.isLend || state.saleType == 'CREDIT' ? colors.warning : colors.success,
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
        customerId: widget.customerId,
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

  Widget _buildDatePickerRow(BuildContext context, WidgetRef ref, DateTime selectedDate) {
    final colors = context.colors;
    final dateStr = DateFormat('dd MMM yyyy').format(selectedDate);

    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: colors.primary,
                  onPrimary: colors.primaryFg,
                  onSurface: colors.foreground,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          ref.read(saleControllerProvider(widget.customerId).notifier).updateDate(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: colors.primary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Date (Migration)',
                    style: AppTypography.labelSmall.copyWith(color: colors.mutedFg, fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_calendar_outlined, color: colors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBar(BuildContext context, WidgetRef ref, SaleScreenState state) {
    final colors = context.colors;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(saleControllerProvider(widget.customerId).notifier).setLendMode(false);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !state.isLend ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sale',
                  style: AppTypography.labelMedium.copyWith(
                    color: !state.isLend ? colors.primaryFg : colors.mutedFg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(saleControllerProvider(widget.customerId).notifier).setLendMode(true);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: state.isLend ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Lend',
                  style: AppTypography.labelMedium.copyWith(
                    color: state.isLend ? colors.primaryFg : colors.mutedFg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleAllocationSection(BuildContext context, WidgetRef ref, SaleScreenState state) {
    if (state.lineItems.length <= 1 || state.allocations.length <= 1) {
      return const SizedBox.shrink();
    }
    final colors = context.colors;
    final isIndividual = state.allocationType == 'INDIVIDUALLY';
    final totalAllocated = state.allocations.fold<int>(0, (sum, a) => sum + a.allocatedAmount);
    final targetPayment = state.advanceAmount + state.appliedCreditAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isIndividual ? colors.primary.withValues(alpha: 0.08) : colors.muted.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isIndividual ? colors.primary.withValues(alpha: 0.3) : colors.border.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.tune_rounded,
                color: isIndividual ? colors.primary : colors.mutedFg,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allocate Advance Individually',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isIndividual
                          ? 'Specify custom advance collected for each product'
                          : 'Evenly distributed across purchased products',
                      style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isIndividual,
                onChanged: (val) {
                  ref
                      .read(saleControllerProvider(widget.customerId).notifier)
                      .toggleAllocationType(val ? 'INDIVIDUALLY' : 'EQUALLY');
                },
                activeThumbColor: colors.primary,
              ),
            ],
          ),
        ),
        if (isIndividual && state.allocations.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildSaleTallyBanner(
            context,
            totalAllocated: totalAllocated,
            targetAmount: targetPayment,
            selectedProductId: _selectedProductId,
            allocations: state.allocations,
            onAutoBalance: () => ref.read(saleControllerProvider(widget.customerId).notifier).autoFillField(_selectedProductId),
            onSyncAmount: () => ref.read(saleControllerProvider(widget.customerId).notifier).syncAdvanceToAllocations(),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Advance Allocations',
              style: AppTypography.labelMedium.copyWith(
                color: colors.mutedFg,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isIndividual && state.allocations.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Auto-split equally',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...state.allocations.map((alloc) => _buildSaleAllocationItemRow(context, ref, state, alloc, totalAllocated, targetPayment)),
      ],
    );
  }

  Widget _buildSaleTallyBanner(
    BuildContext context, {
    required int totalAllocated,
    required int targetAmount,
    required String? selectedProductId,
    required List<SaleItemAllocation> allocations,
    required VoidCallback onAutoBalance,
    required VoidCallback onSyncAmount,
  }) {
    final colors = context.colors;
    final diff = targetAmount - totalAllocated;

    Color bg;
    Color border;
    Color fg;
    IconData icon;
    String message;

    if (diff == 0) {
      bg = colors.success.withValues(alpha: 0.1);
      border = colors.success.withValues(alpha: 0.3);
      fg = colors.success;
      icon = Icons.check_circle_outline_rounded;
      message = 'Allocations match total down payment (${rupees(totalAllocated)})';
    } else if (diff > 0) {
      bg = Colors.amber.withValues(alpha: 0.12);
      border = Colors.amber.withValues(alpha: 0.4);
      fg = Colors.amber.shade800;
      icon = Icons.info_outline_rounded;
      message = '${rupees(diff)} remaining to allocate (Allocated: ${rupees(totalAllocated)} / ${rupees(targetAmount)})';
    } else {
      bg = colors.danger.withValues(alpha: 0.1);
      border = colors.danger.withValues(alpha: 0.3);
      fg = colors.danger;
      icon = Icons.error_outline_rounded;
      message = 'Allocated advance (${rupees(totalAllocated)}) exceeds down payment (${rupees(targetAmount)}) by ${rupees(-diff)}';
    }

    SaleItemAllocation? selectedItem;
    if (selectedProductId != null) {
      for (final a in allocations) {
        if (a.productId == selectedProductId) {
          selectedItem = a;
          break;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: fg, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.labelSmall.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (diff != 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (diff > 0)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                      foregroundColor: fg,
                    ),
                    onPressed: onAutoBalance,
                    icon: const Icon(Icons.auto_fix_high_rounded, size: 14),
                    label: Text(
                      selectedItem != null ? 'Fill ${selectedItem.productName}' : 'Auto-fill remaining',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                    foregroundColor: fg,
                  ),
                  onPressed: onSyncAmount,
                  icon: const Icon(Icons.sync_rounded, size: 14),
                  label: Text('Sync to ${rupees(totalAllocated)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaleAllocationItemRow(
    BuildContext context,
    WidgetRef ref,
    SaleScreenState state,
    SaleItemAllocation alloc,
    int totalAllocated,
    int targetPayment,
  ) {
    final colors = context.colors;
    final isManual = state.allocationType == 'INDIVIDUALLY';
    final isSelected = _selectedProductId == alloc.productId;
    final diff = targetPayment - totalAllocated;
    final canFill = alloc.itemSaleCost - alloc.allocatedAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isSelected ? colors.primary.withValues(alpha: 0.06) : colors.muted.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isSelected ? colors.primary.withValues(alpha: 0.4) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alloc.productName,
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cost: ${rupees(alloc.itemSaleCost)}  •  Remaining Due: ${rupees(alloc.remainingDue)}',
                  style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (isManual) ...[
            if (diff > 0 && canFill > 0) ...[
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                onTap: () {
                  setState(() => _selectedProductId = alloc.productId);
                  ref.read(saleControllerProvider(widget.customerId).notifier).autoFillField(alloc.productId);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 12, color: colors.primary),
                      const SizedBox(width: 3),
                      Text(
                        'Fill',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            SaleIndividualAllocationInput(
              initialValue: alloc.allocatedAmount,
              maxValue: alloc.itemSaleCost,
              onTap: () => setState(() => _selectedProductId = alloc.productId),
              onChanged: (val) {
                setState(() => _selectedProductId = alloc.productId);
                ref
                    .read(saleControllerProvider(widget.customerId).notifier)
                    .updateIndividualAllocation(alloc.productId, val);
              },
            ),
          ] else ...[
            Text(
              rupees(alloc.allocatedAmount),
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: alloc.allocatedAmount > 0 ? colors.success : colors.mutedFg,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductPickerSheet extends ConsumerStatefulWidget {
  final List<Product> products;
  final String customerId;
  final ValueChanged<Product> onProductSelected;

  const _ProductPickerSheet({
    required this.products,
    required this.customerId,
    required this.onProductSelected,
  });

  @override
  ConsumerState<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  String _searchQuery = '';
  final Set<String> _selectedCategoryIds = {};

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(saleControllerProvider(widget.customerId));

    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? mockCategoriesList;

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
        final totalItems = state.lineItems.fold<int>(0, (sum, item) => sum + item.quantity);
        final showCartBar = state.lineItems.isNotEmpty;

        return Stack(
          children: [
            Column(
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
                    autofocus: false,
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
                      ...categories.map((c) {
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
                    padding: EdgeInsets.only(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: showCartBar ? 88.0 : 16.0,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      final outOfStock = product.stock <= 0;

                      final existingIndex = state.lineItems.indexWhere((item) => item.product.id == product.id);
                      final inCart = existingIndex != -1;

                      return InkWell(
                        onTap: outOfStock ? null : () => widget.onProductSelected(product),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      rupees(product.sellingPrice ~/ 100),
                                      style: AppTypography.currencySmall.copyWith(
                                        color: outOfStock ? colors.mutedFg : colors.primary,
                                        fontWeight: FontWeight.bold,
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
                                            fontSize: 8.5,
                                          ),
                                        ),
                                      ),
                                    ] else if (inCart) ...[
                                      const SizedBox(height: 4),
                                      Builder(
                                        builder: (context) {
                                          final cartItem = state.lineItems[existingIndex];
                                          return Container(
                                            height: 28,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
                                              borderRadius: BorderRadius.circular(6),
                                              color: colors.primary.withValues(alpha: 0.05),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: () {
                                                    AppHaptics.lightImpact();
                                                    ref
                                                        .read(saleControllerProvider(widget.customerId).notifier)
                                                        .updateQuantity(product.id, cartItem.quantity - 1);
                                                  },
                                                  child: Container(
                                                    width: 28,
                                                    height: 28,
                                                    alignment: Alignment.center,
                                                    child: Icon(Icons.remove, color: colors.primary, size: 12),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                  child: Text(
                                                    '${cartItem.quantity}',
                                                    style: AppTypography.labelSmall.copyWith(
                                                      color: colors.primary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: () {
                                                    AppHaptics.lightImpact();
                                                    ref
                                                        .read(saleControllerProvider(widget.customerId).notifier)
                                                        .updateQuantity(product.id, cartItem.quantity + 1);
                                                  },
                                                  child: Container(
                                                    width: 28,
                                                    height: 28,
                                                    alignment: Alignment.center,
                                                    child: Icon(Icons.add, color: colors.primary, size: 12),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ] else ...[
                                      const SizedBox(height: 4),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(64, 28),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          side: BorderSide(color: colors.primary),
                                        ),
                                        onPressed: () {
                                          AppHaptics.lightImpact();
                                          ref
                                              .read(saleControllerProvider(widget.customerId).notifier)
                                              .addProduct(product);
                                        },
                                        child: Text(
                                          'ADD',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: colors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9.5,
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
            ),
            
            // Floating Cart Bar Overlay
            if (showCartBar)
              Positioned(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$totalItems ITEM${totalItems > 1 ? 'S' : ''} ADDED',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Total: ${rupees(state.totalAmount)}',
                              style: AppTypography.labelMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'VIEW CART',
                              style: AppTypography.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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

class SaleIndividualAllocationInput extends StatefulWidget {
  const SaleIndividualAllocationInput({
    super.key,
    required this.initialValue,
    required this.maxValue,
    required this.onChanged,
    this.onTap,
  });

  final int initialValue;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final VoidCallback? onTap;

  @override
  State<SaleIndividualAllocationInput> createState() => _SaleIndividualAllocationInputState();
}

class _SaleIndividualAllocationInputState extends State<SaleIndividualAllocationInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void didUpdateWidget(SaleIndividualAllocationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != int.tryParse(_controller.text)) {
      _controller.text = widget.initialValue.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.end,
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        onTap: () {
          widget.onTap?.call();
          if (_controller.text == '0') {
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          }
        },
        decoration: const InputDecoration(
          prefixText: '₹ ',
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          isDense: true,
        ),
        onChanged: (val) {
          String sanitized = val.replaceAll(RegExp(r'[^0-9]'), '');
          sanitized = sanitized.replaceAll(RegExp(r'^0+'), '');
          if (sanitized.isEmpty) {
            sanitized = '0';
          }
          int parsed = int.tryParse(sanitized) ?? 0;
          if (parsed > widget.maxValue) {
            parsed = widget.maxValue;
            sanitized = parsed.toString();
          }
          if (sanitized != val) {
            _controller.value = TextEditingValue(
              text: sanitized,
              selection: TextSelection.collapsed(offset: sanitized.length),
            );
          }
          widget.onChanged(parsed);
        },
      ),
    );
  }
}

