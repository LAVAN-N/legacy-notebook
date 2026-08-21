import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/outstanding.dart';
import '../controllers/customer_controller.dart';

class PurchasedProductGroupCard extends ConsumerStatefulWidget {
  const PurchasedProductGroupCard({
    super.key,
    required this.groupItems,
    required this.outstanding,
    required this.allPurchasedProducts,
    required this.customerId,
    this.initiallyExpanded = false,
  });

  final List<PurchasedProductItem> groupItems;
  final Outstanding outstanding;
  final List<PurchasedProductItem> allPurchasedProducts;
  final String customerId;
  final bool initiallyExpanded;

  @override
  ConsumerState<PurchasedProductGroupCard> createState() => _PurchasedProductGroupCardState();
}

class _PurchasedProductGroupCardState extends ConsumerState<PurchasedProductGroupCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5));
  }

  @override
  void didUpdateWidget(covariant PurchasedProductGroupCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupItems != widget.groupItems) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final firstItem = widget.groupItems.first;
    final hasMultiple = widget.groupItems.length > 1;

    final totalGroupPrice = widget.groupItems.fold<int>(0, (sum, i) => sum + i.totalPrice);
    final totalGroupCollected = widget.groupItems.fold<int>(0, (sum, i) => sum + i.collectedAmount);
    final allSettled = widget.groupItems.every((i) => i.status == 'settled');
    final allReturned = widget.groupItems.every((i) => i.status == 'returned');
    final hasReturned = widget.groupItems.any((i) => i.status == 'returned');

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _isExpanded
              ? colors.primary.withValues(alpha: 0.3)
              : colors.border.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tappable Header (Fold / Unfold Toggle)
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                firstItem.productName,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: colors.foreground,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Subtitle: SKU • Quantity • Summary Price
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Text(
                              'SKU: ${firstItem.productSku}',
                              style: AppTypography.labelSmall.copyWith(color: colors.mutedFg),
                            ),
                            Text('•', style: TextStyle(color: colors.mutedFg, fontSize: 10)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${widget.groupItems.length} ${widget.groupItems.length > 1 ? "Units / Purchases" : "Unit"}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9.5,
                                ),
                              ),
                            ),
                            if (!_isExpanded) ...[
                              Text('•', style: TextStyle(color: colors.mutedFg, fontSize: 10)),
                              Text(
                                'Collected: ${rupees(totalGroupCollected)} / ${rupees(totalGroupPrice)}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: allSettled
                                      ? colors.success
                                      : colors.mutedFg,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Overall Status Pill (when folded)
                  if (!_isExpanded) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: allReturned
                            ? const Color(0xFFFDE047).withValues(alpha: 0.2)
                            : allSettled
                                ? colors.success.withValues(alpha: 0.1)
                                : hasReturned
                                    ? const Color(0xFFFDE047).withValues(alpha: 0.15)
                                    : colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        allReturned
                            ? 'RETURNED'
                            : allSettled
                                ? 'SETTLED'
                                : hasReturned
                                    ? 'PARTIAL RETURN'
                                    : 'ACTIVE',
                        style: AppTypography.labelSmall.copyWith(
                          color: (allReturned || hasReturned)
                              ? const Color(0xFF854D0E)
                              : allSettled
                                  ? colors.success
                                  : colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 8.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],

                  // Chevron Rotate Icon
                  RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colors.mutedFg,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content (Standalone Units)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 12),
                  const SizedBox(height: 4),

                  // List of standalone instances
                  ...widget.groupItems.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final isReturned = item.status == 'returned';
                    final isSettled = item.status == 'settled';
                    final isPurchased = item.status == 'purchased';
                    final double oAmount = widget.outstanding.outstandingAmount / 100;
                    final canSettle = oAmount == 0.0 && isPurchased;

                    final label = item.unitLabel ??
                        (hasMultiple ? 'Purchase #${widget.groupItems.length - idx}' : null);

                    return Container(
                      margin: EdgeInsets.only(bottom: idx == widget.groupItems.length - 1 ? 0 : 8),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: isReturned
                              ? const Color(0xFFFDE047).withValues(alpha: 0.6)
                              : colors.border.withValues(alpha: 0.5),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Standalone Top Row: Date, Unit Label, Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 12, color: colors.mutedFg),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(item.purchaseDate),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: colors.foreground,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (label != null) ...[
                                    const SizedBox(width: 6),
                                    Text('•', style: TextStyle(color: colors.mutedFg, fontSize: 10)),
                                    const SizedBox(width: 6),
                                    Text(
                                      label,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.mutedFg,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isReturned
                                      ? const Color(0xFFFDE047).withValues(alpha: 0.2)
                                      : isSettled
                                          ? colors.success.withValues(alpha: 0.1)
                                          : colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: isReturned
                                        ? const Color(0xFFFDE047)
                                        : isSettled
                                            ? colors.success.withValues(alpha: 0.4)
                                            : colors.primary.withValues(alpha: 0.4),
                                    width: 0.75,
                                  ),
                                ),
                                child: Text(
                                  item.status.toUpperCase(),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isReturned
                                        ? const Color(0xFF854D0E)
                                        : isSettled
                                            ? colors.success
                                            : colors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Standalone Bottom Row: Price, Collected & Action Buttons
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Price: ${rupees(item.totalPrice)}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: colors.mutedFg,
                                        decoration: isReturned ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (isReturned)
                                      Text(
                                        'Credit Credited: ${rupees(item.collectedAmount)}',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: const Color(0xFF854D0E),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    else
                                      Text(
                                        'Collected: ${rupees(item.collectedAmount)} / ${rupees(item.totalPrice)}',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: isSettled ? colors.success : colors.mutedFg,
                                          fontWeight: isSettled ? FontWeight.bold : FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Settle and Return Action Buttons
                              if (isPurchased) ...[
                                const SizedBox(width: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  alignment: WrapAlignment.end,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    if (canSettle)
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
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('Settle', style: TextStyle(fontSize: 10)),
                                      ),
                                    OutlinedButton(
                                      onPressed: () {
                                        _showReturnDialog(context, item);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: colors.danger,
                                        side: BorderSide(color: colors.danger),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('Return', style: TextStyle(fontSize: 10)),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  void _showReturnDialog(BuildContext context, PurchasedProductItem item) {
    final colors = context.colors;
    final otherOutstandingProducts = widget.allPurchasedProducts.where((p) =>
      p.saleItemId != item.saleItemId &&
      p.status == 'purchased' &&
      (p.totalPrice - p.collectedAmount) > 0
    ).toList();

    bool tallyOut = otherOutstandingProducts.isNotEmpty;
    String? selectedTallySaleItemId = otherOutstandingProducts.isNotEmpty ? otherOutstandingProducts.first.saleItemId : null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final hasOtherOutstandings = otherOutstandingProducts.isNotEmpty;
            PurchasedProductItem? selectedTallyProduct;
            if (selectedTallySaleItemId != null) {
              for (final p in otherOutstandingProducts) {
                if (p.saleItemId == selectedTallySaleItemId) {
                  selectedTallyProduct = p;
                  break;
                }
              }
            }
            if (selectedTallyProduct == null && otherOutstandingProducts.isNotEmpty) {
              selectedTallyProduct = otherOutstandingProducts.first;
              selectedTallySaleItemId = selectedTallyProduct.saleItemId;
            }

            int tallyAmount = 0;
            int remainder = item.collectedAmount;

            if (tallyOut && selectedTallyProduct != null) {
              final outstandingAmount = selectedTallyProduct.totalPrice - selectedTallyProduct.collectedAmount;
              tallyAmount = item.collectedAmount < outstandingAmount ? item.collectedAmount : outstandingAmount;
              remainder = item.collectedAmount - tallyAmount;
            }

            return AlertDialog(
              title: const Text('Return Product'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm returning ${item.productName}${item.unitLabel != null ? " (${item.unitLabel})" : ""}?\n\nThis will restock the product. Return Credit: ${rupees(item.collectedAmount)}.',
                    style: AppTypography.bodyMedium.copyWith(color: colors.foreground),
                  ),
                  const SizedBox(height: 12),
                  if (hasOtherOutstandings) ...[
                    SwitchListTile(
                      value: tallyOut,
                      title: const Text('Tally out with outstanding', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Deduct credit from other active product outstandings instead of keeping as pure credit', style: TextStyle(fontSize: 11)),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (val) {
                        setState(() => tallyOut = val);
                      },
                    ),
                    if (tallyOut && selectedTallyProduct != null) ...[
                      const SizedBox(height: 12),
                      Text('Select product to apply credit to:', style: AppTypography.labelSmall.copyWith(color: colors.mutedFg)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedTallySaleItemId,
                            isExpanded: true,
                            dropdownColor: colors.background,
                            style: AppTypography.bodyMedium.copyWith(color: colors.foreground),
                            items: otherOutstandingProducts.map((p) {
                              final outstandingAmount = p.totalPrice - p.collectedAmount;
                              return DropdownMenuItem<String>(
                                value: p.saleItemId,
                                child: Text('${p.productName} (${dateShort(p.purchaseDate)}) - Outstanding: ${rupees(outstandingAmount)}'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => selectedTallySaleItemId = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${rupees(tallyAmount)} will be applied to ${selectedTallyProduct.productName}.\n${remainder > 0 ? "${rupees(remainder)} will be kept as pure credit." : "No credit remainder."}',
                        style: AppTypography.labelSmall.copyWith(color: colors.success, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ] else ...[
                    Text(
                      'No other outstanding products found. Return credit of ${rupees(item.collectedAmount)} will be saved as pure credit for future purchases.',
                      style: AppTypography.bodySmall.copyWith(color: colors.mutedFg),
                    ),
                  ],
                ],
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
                      tallyOut: tallyOut,
                      tallySaleItemId: tallyOut && selectedTallyProduct != null ? selectedTallyProduct.saleItemId : null,
                      tallyProductName: tallyOut && selectedTallyProduct != null ? selectedTallyProduct.productName : null,
                      tallyAmount: tallyOut ? tallyAmount : null,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tallyOut
                                ? '${item.productName} returned. Credit applied to outstanding.'
                                : '${item.productName} returned. Saved to returned credit.',
                          ),
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
            );
          },
        );
      },
    );
  }
}
