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
import 'controllers/collect_controller.dart';

class CollectScreen extends ConsumerStatefulWidget {
  const CollectScreen({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<CollectScreen> createState() => _CollectScreenState();
}

class _CollectScreenState extends ConsumerState<CollectScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedSaleItemId;

  bool get _isDirty {
    final state = ref.read(collectControllerProvider(widget.customerId));
    if (state.status != 'PAYMENT') {
      return true;
    }
    if (_amountController.text != '0' && _amountController.text.isNotEmpty) {
      return true;
    }
    if (_notesController.text.isNotEmpty) {
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
          content: const Text('Are you sure you want to discard this visit record?'),
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
    Future.microtask(() {
      final state = ref.read(collectControllerProvider(widget.customerId));
      _amountController.text = state.amount.toString();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() async {
    AppHaptics.mediumImpact();
    final notifier = ref.read(collectControllerProvider(widget.customerId).notifier);
    final success = await notifier.saveCollection();

    if (success && mounted) {
      final state = ref.read(collectControllerProvider(widget.customerId));
      final customerName = state.customer.name;

      ConfirmSnackbar.show(
        context,
        message: 'Collected ${rupees(state.amount)} for $customerName',
        onUndo: () {
          // Simply call undo on the mock repo or display undo alert
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction undo requested.')),
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
    final state = ref.watch(collectControllerProvider(widget.customerId));

    // Update text fields if notifier defaults them
    ref.listen(collectControllerProvider(widget.customerId), (prev, next) {
      if (prev?.status != next.status || prev?.collectionTarget != next.collectionTarget) {
        _amountController.text = next.amount.toString();
        _notesController.clear();
      } else if (prev?.amount != next.amount) {
        if (next.allocationType == 'INDIVIDUALLY' || _amountController.text != next.amount.toString()) {
          _amountController.text = next.amount.toString();
        }
      }
    });

    final currentOutstanding = state.collectionTarget == 'LEND'
        ? state.outstanding.lendOutstanding
        : state.outstanding.saleOutstanding;
    final newOutstanding = (currentOutstanding - state.amount).clamp(0, 99999999);

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
          'New Collection Visit',
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
                  'Outstanding Dues: ${rupees(currentOutstanding)}',
                  style: AppTypography.labelSmall.copyWith(color: colors.danger, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
             _buildDatePickerRow(context, ref, state.selectedDate),
            const SizedBox(height: AppSpacing.lg),

            // Segmented Target selector (Sale vs Lend)
            Text(
              'Collection Target',
              style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: colors.border.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _SegmentButton(
                    label: 'Product Sale',
                    isSelected: state.collectionTarget == 'SALE',
                    enabled: state.outstanding.saleOutstanding > 0 || (state.outstanding.saleOutstanding <= 0 && state.outstanding.lendOutstanding <= 0),
                    onTap: () => ref
                        .read(collectControllerProvider(widget.customerId).notifier)
                        .updateCollectionTarget('SALE'),
                  ),
                  _SegmentButton(
                    label: 'Cash Loan / Lend',
                    isSelected: state.collectionTarget == 'LEND',
                    enabled: state.outstanding.lendOutstanding > 0,
                    onTap: () => ref
                        .read(collectControllerProvider(widget.customerId).notifier)
                        .updateCollectionTarget('LEND'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Segmented Status selector
            Text(
              'Visit Status / Outcome',
              style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: colors.muted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _SegmentButton(
                    label: 'Payment',
                    isSelected: state.status == 'PAYMENT',
                    onTap: () => ref
                        .read(collectControllerProvider(widget.customerId).notifier)
                        .updateStatus('PAYMENT'),
                  ),
                  _SegmentButton(
                    label: 'Partial',
                    isSelected: state.status == 'PARTIAL_PAYMENT',
                    onTap: () => ref
                        .read(collectControllerProvider(widget.customerId).notifier)
                        .updateStatus('PARTIAL_PAYMENT'),
                  ),
                  _SegmentButton(
                    label: 'Carry Fwd',
                    isSelected: state.status == 'CARRY_FORWARD',
                    onTap: () => ref
                        .read(collectControllerProvider(widget.customerId).notifier)
                        .updateStatus('CARRY_FORWARD'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // If PAYMENT or PARTIAL, show amount
            if (state.status != 'CARRY_FORWARD') ...[
              Text(
                'Collection Amount (₹)',
                style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: AppTypography.currencyMedium.copyWith(color: colors.foreground),
                onTap: () {
                  if (_amountController.text == '0') {
                    _amountController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _amountController.text.length),
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
                    _amountController.value = TextEditingValue(
                      text: sanitized,
                      selection: TextSelection.collapsed(offset: sanitized.length),
                    );
                  }
                  final amt = int.tryParse(sanitized) ?? 0;
                  ref.read(collectControllerProvider(widget.customerId).notifier).updateAmount(amt);
                },
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  hintText: 'Enter collected cash',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Quick amount chips
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  _QuickAmountChip(
                    label: '+ ₹100',
                    onTap: () {
                      final current = int.tryParse(_amountController.text) ?? 0;
                      final nextVal = current + 100;
                      _amountController.text = nextVal.toString();
                      ref
                          .read(collectControllerProvider(widget.customerId).notifier)
                          .updateAmount(nextVal);
                    },
                  ),
                  _QuickAmountChip(
                    label: '+ ₹500',
                    onTap: () {
                      final current = int.tryParse(_amountController.text) ?? 0;
                      final nextVal = current + 500;
                      _amountController.text = nextVal.toString();
                      ref
                          .read(collectControllerProvider(widget.customerId).notifier)
                          .updateAmount(nextVal);
                    },
                  ),
                  _QuickAmountChip(
                    label: '+ ₹1,000',
                    onTap: () {
                      final current = int.tryParse(_amountController.text) ?? 0;
                      final nextVal = current + 1000;
                      _amountController.text = nextVal.toString();
                      ref
                          .read(collectControllerProvider(widget.customerId).notifier)
                          .updateAmount(nextVal);
                    },
                  ),
                  _QuickAmountChip(
                    label: 'Clear',
                    onTap: () {
                      _amountController.text = '0';
                      ref
                          .read(collectControllerProvider(widget.customerId).notifier)
                          .updateAmount(0);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state.collectionTarget == 'SALE' && state.allocations.isNotEmpty) ...[
                _buildAllocationSelector(context, ref, state),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],

            // If CARRY_FORWARD, show reason chips
            if (state.status == 'CARRY_FORWARD') ...[
              Text(
                'Select Standard Reason',
                style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _QuickReasonChip(
                    label: 'Not at Home',
                    isSelected: state.notes == 'Not at Home',
                    onTap: () {
                      _notesController.text = 'Not at Home';
                      ref
                          .read(collectControllerProvider(widget.customerId).notifier)
                          .updateNotes('Not at Home');
                    },
                  ),
                  _QuickReasonChip(
                    label: 'Will pay in evening',
                    isSelected: state.notes == 'Will pay in evening',
                    onTap: () {
                      _notesController.text = 'Will pay in evening';
                      ref
                          .read(collectControllerProvider(widget.customerId).notifier)
                          .updateNotes('Will pay in evening');
                    },
                  ),
                  _QuickReasonChip(
                    label: 'No Cash Available',
                    isSelected: state.notes == 'No Cash Available',
                    onTap: () {
                      _notesController.text = 'No Cash Available';
                      ref
                          .read(collectControllerProvider(widget.customerId).notifier)
                          .updateNotes('No Cash Available');
                    },
                  ),
                  _QuickReasonChip(
                    label: 'Shop Closed',
                    isSelected: state.notes == 'Shop Closed',
                    onTap: () {
                      _notesController.text = 'Shop Closed';
                      ref
                          .read(collectControllerProvider(widget.customerId).notifier)
                          .updateNotes('Shop Closed');
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Notes / Remarks field
            Text(
              state.status == 'CARRY_FORWARD' ? 'Detailed Reason / Notes' : 'Remarks / Notes (Optional)',
              style: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              onChanged: (val) => ref
                  .read(collectControllerProvider(widget.customerId).notifier)
                  .updateNotes(val),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: state.status == 'CARRY_FORWARD'
                    ? 'Enter why the payment was carried forward...'
                    : 'Add notes about this collection visit...',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Live Outstanding Preview block
            if (state.status != 'CARRY_FORWARD') ...[
              Card(
                color: colors.muted.withValues(alpha: 0.4),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Outstanding Preview',
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Current Outstanding', style: AppTypography.bodyMedium),
                          AmountText(amount: currentOutstanding, style: AppTypography.currencySmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Collected Cash', style: AppTypography.bodyMedium.copyWith(color: colors.success)),
                          Text('- ${rupees(state.amount)}', style: AppTypography.currencySmall.copyWith(color: colors.success)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('New Running Balance', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                          AmountText(
                            amount: newOutstanding,
                            style: AppTypography.currencySmall.copyWith(
                              color: newOutstanding > 0 ? colors.danger : colors.success,
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
            ],

            // Error warnings
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

            // Save / Confirm Action Button
            ElevatedButton(
              onPressed: state.isSaving ? null : _onSave,
              child: state.isSaving
                  ? const WaveDotLoader(color: Colors.white, dotSize: 6, spacing: 4)
                  : const Text('SAVE VISIT RECORD'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
          ref.read(collectControllerProvider(widget.customerId).notifier).updateDate(picked);
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

  Widget _buildAllocationSelector(BuildContext context, WidgetRef ref, CollectScreenState state) {
    final colors = context.colors;
    final isIndividual = state.allocationType == 'INDIVIDUALLY';
    final totalAllocated = state.allocations.fold<int>(0, (sum, a) => sum + a.allocatedAmount);

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
                      'Allocate Individually',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isIndividual
                          ? 'Specify custom amount for each product'
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
                      .read(collectControllerProvider(widget.customerId).notifier)
                      .toggleAllocationType(val ? 'INDIVIDUALLY' : 'EQUALLY');
                },
                activeThumbColor: colors.primary,
              ),
            ],
          ),
        ),
        if (isIndividual && state.allocations.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildTallyBanner(
            context,
            totalAllocated: totalAllocated,
            targetAmount: state.amount,
            selectedSaleItemId: _selectedSaleItemId,
            allocations: state.allocations,
            onAutoBalance: () => ref.read(collectControllerProvider(widget.customerId).notifier).autoFillField(_selectedSaleItemId),
            onSyncAmount: () => ref.read(collectControllerProvider(widget.customerId).notifier).syncAmountToAllocations(),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Allocations',
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
        ...state.allocations.map((alloc) => _buildAllocationItemRow(context, ref, state, alloc, totalAllocated)),
      ],
    );
  }

  Widget _buildTallyBanner(
    BuildContext context, {
    required int totalAllocated,
    required int targetAmount,
    required String? selectedSaleItemId,
    required List<ProductAllocation> allocations,
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
      message = 'Allocations match collected amount (${rupees(totalAllocated)})';
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
      message = 'Allocated sum (${rupees(totalAllocated)}) exceeds collect amount (${rupees(targetAmount)}) by ${rupees(-diff)}';
    }

    ProductAllocation? selectedItem;
    if (selectedSaleItemId != null) {
      for (final a in allocations) {
        if (a.saleItemId == selectedSaleItemId) {
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

  Widget _buildAllocationItemRow(
    BuildContext context,
    WidgetRef ref,
    CollectScreenState state,
    ProductAllocation alloc,
    int totalAllocated,
  ) {
    final colors = context.colors;
    final isManual = state.allocationType == 'INDIVIDUALLY';
    final isSelected = _selectedSaleItemId == alloc.saleItemId;
    final diff = state.amount - totalAllocated;
    final canFill = alloc.outstanding - alloc.allocatedAmount;

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
                  'Outstanding: ${rupees(alloc.outstanding)} (Paid: ${rupees(alloc.collectedAmount)})',
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
                  setState(() => _selectedSaleItemId = alloc.saleItemId);
                  ref.read(collectControllerProvider(widget.customerId).notifier).autoFillField(alloc.saleItemId);
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
            IndividualAllocationInput(
              initialValue: alloc.allocatedAmount,
              maxValue: alloc.outstanding,
              onTap: () => setState(() => _selectedSaleItemId = alloc.saleItemId),
              onChanged: (val) {
                setState(() => _selectedSaleItemId = alloc.saleItemId);
                ref
                    .read(collectControllerProvider(widget.customerId).notifier)
                    .updateIndividualAllocation(alloc.saleItemId, val);
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

class IndividualAllocationInput extends StatefulWidget {
  const IndividualAllocationInput({
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
  State<IndividualAllocationInput> createState() => _IndividualAllocationInputState();
}

class _IndividualAllocationInputState extends State<IndividualAllocationInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void didUpdateWidget(IndividualAllocationInput oldWidget) {
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

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: GestureDetector(
        onTap: enabled
            ? () {
                AppHaptics.selectionClick();
                onTap();
              }
            : null,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected 
                ? (enabled ? colors.primary : colors.muted) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected 
                  ? (enabled ? Colors.white : colors.mutedFg) 
                  : (enabled ? colors.mutedFg : colors.mutedFg.withValues(alpha: 0.4)),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ActionChip(
      label: Text(label),
      labelStyle: AppTypography.labelSmall.copyWith(color: colors.primary),
      backgroundColor: colors.primary.withValues(alpha: 0.08),
      onPressed: () {
        AppHaptics.selectionClick();
        onTap();
      },
    );
  }
}

class _QuickReasonChip extends StatelessWidget {
  const _QuickReasonChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        AppHaptics.selectionClick();
        onTap();
      },
      selectedColor: colors.primary.withValues(alpha: 0.15),
      labelStyle: AppTypography.labelSmall.copyWith(
        color: isSelected ? colors.primary : colors.mutedFg,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}
