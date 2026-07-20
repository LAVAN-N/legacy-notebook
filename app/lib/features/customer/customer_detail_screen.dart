import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/confirm_snackbar.dart';
import '../../core/router/routes.dart';
import 'controllers/customer_controller.dart';
import 'widgets/customer_context_card.dart';
import 'widgets/financial_summary_block.dart';
import 'widgets/timeline_entry_tile.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({
    super.key, 
    required this.customerId,
    this.weekday = 'Monday',
    this.placeId = '',
    this.areaId = '',
  });

  final String customerId;
  final String weekday;
  final String placeId;
  final String areaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final detailState = ref.watch(customerDetailControllerProvider(customerId));

    return detailState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: ErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(customerDetailControllerProvider(customerId)),
        ),
      ),
      data: (data) {
        final customer = data.customer;
        final outstanding = data.outstanding;
        final timeline = data.timeline;

        return AppScaffold(
          title: Text(
            customer.name,
            style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identity Block
                  CustomerContextCard(
                    customer: customer,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Financial Block
                  FinancialSummaryBlock(outstanding: outstanding),
                  const SizedBox(height: AppSpacing.lg),



                  // Timeline Section
                  const SectionHeader(title: 'Unified Activity History'),
                  const SizedBox(height: AppSpacing.sm),

                  if (timeline.isEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      alignment: Alignment.center,
                      child: Text(
                        'No activities recorded yet.',
                        style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg),
                      ),
                    )
                  else
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: timeline.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          return TimelineEntryTile(activity: timeline[index]);
                        },
                      ),
                    ),
                  const SizedBox(height: 80), // spacer for sticky bottom actions
                ],
              ),
            ),
          ),
          bottomSheetSlot: Container(
            color: colors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(Routes.sale(weekday, placeId, areaId, customerId)),
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('NEW SALE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(Routes.collect(weekday, placeId, areaId, customerId)),
                    icon: const Icon(Icons.wallet_giftcard),
                    label: const Text('COLLECT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.primaryFg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddNomineeSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final colors = context.colors;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Nominee / Guarantor',
                style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nominee Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relationController,
                decoration: const InputDecoration(labelText: 'Relationship (e.g. Spouse, Brother)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  final relation = relationController.text.trim();

                  if (name.isNotEmpty && phone.isNotEmpty && relation.isNotEmpty) {
                    await ref
                        .read(customerDetailControllerProvider(customerId).notifier)
                        .addNominee(name, phone, relation);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nominee details recorded successfully')),
                    );
                  }
                },
                child: const Text('SAVE NOMINEE'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }


}
