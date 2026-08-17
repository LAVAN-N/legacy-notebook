import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/app_pull_to_refresh.dart';
import '../../core/utils/formatters.dart';
import '../../core/router/routes.dart';
import '../../data/models/activity.dart';
import 'controllers/customer_controller.dart';
import '../dashboard/controllers/dashboard_controller.dart';
import 'widgets/customer_context_card.dart';
import 'widgets/financial_summary_block.dart';
import 'widgets/timeline_entry_tile.dart';
import 'widgets/custom_calendar_view.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
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
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  bool _isCalendarView = false;
  int _activityLimit = 5;
  double _maxSafeAreaBottom = 0.0;

  void _showActivityDetailsPopUp(DateTime date, List<Activity> activities) {
    final colors = context.colors;
    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(date);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          elevation: 8,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.border.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pop-up header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Activities',
                              style: AppTypography.titleLarge.copyWith(
                                color: colors.foreground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.mutedFg,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        color: colors.mutedFg,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Activities List
                Flexible(
                  child: activities.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Center(
                            child: Text(
                              'No activities on this date.',
                              style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: activities.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.zero,
                              child: TimelineEntryTile(activity: activities[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentBottom = MediaQueryData.fromView(View.of(context)).padding.bottom;
    if (currentBottom > _maxSafeAreaBottom) {
      _maxSafeAreaBottom = currentBottom;
    }
    final rawSafeAreaBottom = _maxSafeAreaBottom > 0 ? _maxSafeAreaBottom : currentBottom;
    final detailState = ref.watch(customerDetailControllerProvider(widget.customerId));

    return detailState.when(
      loading: () => const AppScaffold(
        blendHeader: true,
        title: Text('Loading...'),
        body: SkeletonList(),
      ),
      error: (err, stack) => AppScaffold(
        blendHeader: true,
        title: const Text('Error'),
        body: ErrorState(
          message: err.toString(),
          onRetry: () =>
              ref.refresh(customerDetailControllerProvider(widget.customerId)),
        ),
      ),
      data: (data) {
        final customer = data.customer;
        final outstanding = data.outstanding;
        final timeline = data.timeline;

        // Extract and group sale activities by date (day)
        final groupedSalesMap = <DateTime, List<SaleActivity>>{};
        for (final activity in timeline) {
          if (activity is SaleActivity) {
            final dateOnly = DateTime(activity.at.year, activity.at.month, activity.at.day);
            groupedSalesMap.putIfAbsent(dateOnly, () => []).add(activity);
          }
        }
        
        final groupedSales = groupedSalesMap.entries.map((e) {
          final sales = e.value;
          final hasLend = sales.any((s) => s.saleType.toUpperCase() == 'LEND');
          final hasCredit = sales.any((s) => s.saleType.toUpperCase() == 'CREDIT');
          final derivedType = hasLend ? 'LEND' : (hasCredit ? 'CREDIT' : 'READY');
          return GroupedSales(
            date: e.key,
            saleType: derivedType,
            sales: sales,
          );
        }).toList();
        
        groupedSales.sort((a, b) => b.date.compareTo(a.date));

        // Group activities by date for calendar view
        final activitiesByDate = <DateTime, List<Activity>>{};
        for (final activity in timeline) {
          final dateOnly = DateTime(activity.at.year, activity.at.month, activity.at.day);
          activitiesByDate.putIfAbsent(dateOnly, () => []).add(activity);
        }

        final visibleTimeline = timeline.take(_activityLimit).toList();
        final hasMore = timeline.length > _activityLimit;

        return AppScaffold(
          extendBody: true,
          blendHeader: true,
          title: Text(
            customer.name,
            style:
                AppTypography.headlineMedium.copyWith(color: colors.foreground),
          ),
          body: Stack(
            children: [
              AppPullToRefresh(
                onRefresh: () => ref.refresh(customerDetailControllerProvider(widget.customerId).future),
                color: colors.primary,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       // Financial Block (Merged summary + purchased products)
                       FinancialSummaryBlock(
                         outstanding: outstanding,
                         groupedSales: groupedSales,
                         customer: customer,
                       ),
                       const SizedBox(height: AppSpacing.lg),

                       // Purchased Products Section
                       Card(
                         child: Padding(
                           padding: const EdgeInsets.all(AppSpacing.lg),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 'Purchased Products',
                                 style: AppTypography.titleSmall.copyWith(
                                   color: colors.foreground,
                                   fontWeight: FontWeight.w700,
                                 ),
                               ),
                               const SizedBox(height: AppSpacing.md),
                               if (data.purchasedProducts.isEmpty)
                                 Center(
                                   child: Padding(
                                     padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                                     child: Text(
                                       'No purchased products found.',
                                       style: AppTypography.bodyMedium.copyWith(color: colors.mutedFg),
                                     ),
                                   ),
                                 )
                               else
                                 ListView.separated(
                                   shrinkWrap: true,
                                   physics: const NeverScrollableScrollPhysics(),
                                   itemCount: data.purchasedProducts.length,
                                   separatorBuilder: (_, __) => const Divider(height: 24),
                                   itemBuilder: (context, index) {
                                     final item = data.purchasedProducts[index];
                                     final isReturned = item.status == 'returned';
                                     final isSettled = item.status == 'settled';
                                     final isPurchased = item.status == 'purchased';

                                     // Outstanding check
                                     final double oAmount = outstanding.outstandingAmount / 100;
                                     final canSettle = oAmount == 0.0 && isPurchased;

                                     return Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             Expanded(
                                               child: Column(
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 children: [
                                                   Text(
                                                     item.productName,
                                                     style: AppTypography.bodyMedium.copyWith(
                                                       color: colors.foreground,
                                                       fontWeight: FontWeight.bold,
                                                       decoration: isReturned ? TextDecoration.lineThrough : null,
                                                     ),
                                                   ),
                                                   const SizedBox(height: 2),
                                                   Text(
                                                     'SKU: ${item.productSku} • Qty: ${item.quantity}',
                                                     style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                                                   ),
                                                 ],
                                               ),
                                             ),
                                             const SizedBox(width: 8),
                                             // Status Badge
                                             Container(
                                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                               decoration: BoxDecoration(
                                                 color: isReturned
                                                     ? colors.danger.withValues(alpha: 0.1)
                                                     : isSettled
                                                         ? colors.success.withValues(alpha: 0.1)
                                                         : colors.primary.withValues(alpha: 0.1),
                                                 borderRadius: BorderRadius.circular(6),
                                               ),
                                               child: Text(
                                                 item.status.toUpperCase(),
                                                 style: AppTypography.labelSmall.copyWith(
                                                   color: isReturned
                                                       ? colors.danger
                                                       : isSettled
                                                           ? colors.success
                                                           : colors.primary,
                                                   fontWeight: FontWeight.bold,
                                                   fontSize: 9,
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ),
                                         const SizedBox(height: AppSpacing.sm),
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                 Text(
                                                   'Price: ${rupees(item.totalPrice)}',
                                                   style: AppTypography.bodySmall.copyWith(color: colors.mutedFg),
                                                 ),
                                                 if (isReturned)
                                                   Text(
                                                     'Credit Credited: ${rupees(item.collectedAmount)}',
                                                     style: AppTypography.bodySmall.copyWith(
                                                       color: colors.success,
                                                       fontWeight: FontWeight.bold,
                                                     ),
                                                   )
                                                 else
                                                   Text(
                                                     'Collected: ${rupees(item.collectedAmount)} / ${rupees(item.totalPrice)}',
                                                     style: AppTypography.bodySmall.copyWith(
                                                       color: isSettled ? colors.success : colors.mutedFg,
                                                       fontWeight: isSettled ? FontWeight.bold : null,
                                                     ),
                                                   ),
                                               ],
                                             ),
                                             // Actions
                                             if (isPurchased)
                                               Row(
                                                 children: [
                                                   if (canSettle) ...[
                                                     ElevatedButton(
                                                       onPressed: () async {
                                                         final notifier = ref.read(customerDetailControllerProvider(widget.customerId).notifier);
                                                         await notifier.settleProduct(item.saleItemId);
                                                         if (context.mounted) {
                                                           ScaffoldMessenger.of(context).showSnackBar(
                                                             SnackBar(
                                                              content: Text('${item.productName} marked as settled.'),
                                                              behavior: SnackBarBehavior.floating,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: colors.success,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                        minimumSize: Size.zero,
                                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      ),
                                                      child: const Text('Settle', style: TextStyle(fontSize: 10)),
                                                    ),
                                                    const SizedBox(width: 8),
                                                   ],
                                                   OutlinedButton(
                                                     onPressed: () {
                                                       showDialog(
                                                         context: context,
                                                         builder: (ctx) => AlertDialog(
                                                           title: const Text('Return Product'),
                                                           content: Text(
                                                             'Confirm returning ${item.productName}?\n\nThis will add the collected amount so far (${rupees(item.collectedAmount)}) to the customer\'s credit balance, and restock the product.',
                                                           ),
                                                           actions: [
                                                             TextButton(
                                                               onPressed: () => Navigator.pop(ctx),
                                                               child: const Text('Cancel'),
                                                             ),
                                                             ElevatedButton(
                                                               onPressed: () async {
                                                                 Navigator.pop(ctx);
                                                                 final notifier = ref.read(customerDetailControllerProvider(widget.customerId).notifier);
                                                                 await notifier.returnProduct(
                                                                   item.saleItemId,
                                                                   item.collectedAmount,
                                                                   'Owner',
                                                                 );
                                                                 if (context.mounted) {
                                                                   ScaffoldMessenger.of(context).showSnackBar(
                                                                     SnackBar(
                                                                       content: Text('${item.productName} returned successfully. Credit added.'),
                                                                       behavior: SnackBarBehavior.floating,
                                                                     ),
                                                                   );
                                                                 }
                                                               },
                                                               style: ElevatedButton.styleFrom(
                                                                 backgroundColor: colors.danger,
                                                                 foregroundColor: Colors.white,
                                                               ),
                                                               child: const Text('Confirm Return'),
                                                             ),
                                                           ],
                                                         ),
                                                       );
                                                     },
                                                     style: OutlinedButton.styleFrom(
                                                       foregroundColor: colors.danger,
                                                       side: BorderSide(color: colors.danger),
                                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                       minimumSize: Size.zero,
                                                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                     ),
                                                     child: const Text('Return', style: TextStyle(fontSize: 10)),
                                                   ),
                                                 ],
                                               ),
                                           ],
                                         ),
                                       ],
                                     );
                                   },
                                 ),
                             ],
                           ),
                         ),
                       ),
                       const SizedBox(height: AppSpacing.lg),

                      // Identity Block
                      CustomerContextCard(
                        customer: customer,
                        createdDate: () {
                          final sales = timeline.whereType<SaleActivity>();
                          if (sales.isNotEmpty) {
                            return sales.last.at;
                          }
                          return timeline.isNotEmpty ? timeline.last.at : null;
                        }(),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Timeline Section Header with Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SectionHeader(title: 'Unified Activity History'),
                          Container(
                            decoration: BoxDecoration(
                              color: colors.muted.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => _isCalendarView = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: !_isCalendarView ? colors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: Icon(
                                      Icons.list,
                                      size: 16,
                                      color: !_isCalendarView ? colors.primaryFg : colors.mutedFg,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _isCalendarView = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _isCalendarView ? colors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: _isCalendarView ? colors.primaryFg : colors.mutedFg,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      if (_isCalendarView)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: CustomCalendarView(
                              activitiesByDate: activitiesByDate,
                              onDateTapped: (date, activities) {
                                _showActivityDetailsPopUp(date, activities);
                              },
                            ),
                          ),
                        )
                      else ...[
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
                              style: AppTypography.bodyMedium
                                  .copyWith(color: colors.mutedFg),
                            ),
                          )
                        else
                          Card(
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              itemCount: visibleTimeline.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                return TimelineEntryTile(activity: visibleTimeline[index]);
                              },
                            ),
                          ),
                        if (hasMore) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _activityLimit += 10;
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('LOAD MORE'),
                              style: TextButton.styleFrom(
                                foregroundColor: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                      SizedBox(height: 172 + rawSafeAreaBottom), // spacer for sticky bottom actions
                    ],
                  ),
                ),
              ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 88 + rawSafeAreaBottom,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Opacity(
                          opacity: 0.85,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final source = GoRouterState.of(context)
                                  .uri
                                  .queryParameters['source'];
                              final suffix = source != null ? '?source=$source' : '';
                              await context.push(
                                  '${Routes.sale(widget.weekday, widget.placeId, widget.areaId, widget.customerId)}$suffix');
                              if (mounted) {
                                ref.invalidate(customerDetailControllerProvider(widget.customerId));
                                ref.invalidate(dashboardControllerProvider);
                              }
                            },
                            icon: const Icon(Icons.shopping_bag),
                            label: const Text('NEW SALE'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.surface,
                              foregroundColor: colors.primary,
                              elevation: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: outstanding.outstandingAmount <= 0
                              ? null
                              : () async {
                                  final source = GoRouterState.of(context)
                                      .uri
                                      .queryParameters['source'];
                                  final suffix = source != null ? '?source=$source' : '';
                                  await context.push(
                                      '${Routes.collect(widget.weekday, widget.placeId, widget.areaId, widget.customerId)}$suffix');
                                  if (mounted) {
                                    ref.invalidate(customerDetailControllerProvider(widget.customerId));
                                    ref.invalidate(dashboardControllerProvider);
                                  }
                                },
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
              ),
            ],
          ),
        );
      },
    );
  }
}


