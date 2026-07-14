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
    final state = ref.watch(collectControllerProvider(widget.customerId));

    // Update text fields if notifier defaults them
    ref.listen(collectControllerProvider(widget.customerId), (prev, next) {
      if (prev?.status != next.status) {
        _amountController.text = next.amount.toString();
        _notesController.clear();
      }
    });

    final currentOutstanding = state.outstanding.outstandingAmount;
    final newOutstanding = (currentOutstanding - state.amount).clamp(0, 99999999);

    return AppScaffold(
      showSyncIndicator: false,
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
                onChanged: (val) {
                  final amt = int.tryParse(val) ?? 0;
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
                color: colors.muted.withOpacity(0.4),
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

            // Save / Confirm Action Button
            ElevatedButton(
              onPressed: state.isSaving ? null : _onSave,
              child: state.isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SAVE VISIT RECORD'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
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

    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppHaptics.selectionClick();
          onTap();
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? Colors.white : colors.mutedFg,
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
      backgroundColor: colors.primary.withOpacity(0.08),
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
      selectedColor: colors.primary.withOpacity(0.15),
      labelStyle: AppTypography.labelSmall.copyWith(
        color: isSelected ? colors.primary : colors.mutedFg,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}
