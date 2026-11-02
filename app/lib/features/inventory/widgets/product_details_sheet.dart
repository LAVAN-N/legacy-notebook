import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/config/category_icons.dart';
import '../../../data/models/product.dart';
import '../../../data/models/category.dart';
import '../../../data/providers.dart';
import 'add_product_sheet.dart';

/// Opens the neat Product Details modal bottom sheet.
void showProductDetailsSheet(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ProductDetailsSheet(product: product),
  );
}

class _ProductDetailsSheet extends ConsumerWidget {
  final Product product;
  const _ProductDetailsSheet({required this.product});

  Color _getStockStatusColor(Product product, AppColors colors) {
    if (product.stock == 0) {
      return colors.danger;
    } else if (product.stock <= product.minimumStock) {
      return colors.warning;
    }
    return colors.success;
  }

  Map<String, String> _formatDetailsDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return {'date': 'Recent', 'time': ''};
    final dt = DateTime.tryParse(raw);
    if (dt == null) return {'date': raw, 'time': ''};
    final local = dt.toLocal();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return {
      'date': '${local.day} ${months[local.month - 1]} ${local.year}',
      'time': '$hour:$minute $ampm',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? [];
    final category = categories.cast<Category?>().firstWhere(
          (c) => c?.id == product.categoryId,
          orElse: () => null,
        );

    final rawSafeAreaBottom = MediaQuery.of(context).padding.bottom;
    final marginPercent = product.costPrice > 0
        ? (((product.sellingPrice - product.costPrice) / product.costPrice) * 100).round()
        : 0;

    final imageList = <String>[];
    if (product.imageUrl != null && product.imageUrl!.trim().isNotEmpty) {
      imageList.add(product.imageUrl!.trim());
    }
    if (product.imageUrl2 != null && product.imageUrl2!.trim().isNotEmpty) {
      imageList.add(product.imageUrl2!.trim());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: colors.muted.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Top Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  // Category Tag
                  if (category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CategoryIcons.getIcon(category.icon),
                            size: 14,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.name,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  // Close Button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: colors.mutedFg),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // Scrollable Details Body
            Flexible(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Carousel / Card
                    _ProductImageCarousel(images: imageList, colors: colors),

                    const SizedBox(height: 16),

                    // Product Name & SKU
                    Text(
                      product.name,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.foreground,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Brand, SKU & Stock Pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.brand,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.muted.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SKU: ${product.sku}',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.mutedFg,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStockStatusColor(product, colors),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.stock}/${product.minimumStock}',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Meta Row: Mfg Date, Warranty, Updated At
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.muted.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_month_outlined, size: 13, color: colors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Mfg Date',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.mutedFg,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  product.mfgDate.isNotEmpty ? product.mfgDate : 'JAN 2026',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 38, color: colors.border),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.verified_outlined, size: 13, color: colors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Warranty',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: colors.mutedFg,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${product.warranty > 0 ? (product.warranty % 1 == 0 ? product.warranty.toInt() : product.warranty) : '0'} Yrs',
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(width: 1, height: 38, color: colors.border),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded, size: 13, color: colors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Updated At',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: colors.mutedFg,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Builder(
                                    builder: (context) {
                                      final dtInfo = _formatDetailsDateTime(product.updatedAt);
                                      return Wrap(
                                        direction: Axis.vertical,
                                        spacing: 1,
                                        children: [
                                          Text(
                                            dtInfo['date']!,
                                            style: AppTypography.bodySmall.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: colors.foreground,
                                              fontSize: 10.5,
                                            ),
                                          ),
                                          if (dtInfo['time']!.isNotEmpty)
                                            Text(
                                              dtInfo['time']!,
                                              style: AppTypography.labelSmall.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: colors.mutedFg,
                                                fontSize: 9.5,
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description Section (if present)
                    if (product.description != null &&
                        product.description!.trim().isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.muted.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 15,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Product Description',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description!.trim(),
                              style: AppTypography.bodyMedium.copyWith(
                                color: colors.foreground,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Financial & Pricing Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pricing Details',
                                style: AppTypography.labelMedium.copyWith(
                                  color: colors.mutedFg,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+$marginPercent% Margin',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Cost Price (Left)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cost Price',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.mutedFg,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      CurrencyFormatter.format(product.costPrice),
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: colors.foreground,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // MRP (Middle)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'MRP',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.mutedFg,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      CurrencyFormatter.format(product.mrp),
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: colors.mutedFg,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Selling Price (Right)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Selling Price',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.mutedFg,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      CurrencyFormatter.format(product.sellingPrice),
                                      style: AppTypography.titleLarge.copyWith(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                12 + rawSafeAreaBottom,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  top: BorderSide(
                    color: colors.border.withValues(alpha: 0.6),
                  ),
                ),
              ),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  showEditProductSheet(context, product);
                },
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text(
                  'Edit Product',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final AppColors colors;

  const _ProductImageCarousel({
    required this.images,
    required this.colors,
  });

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showElevatedImage(BuildContext context, String imagePath, String title) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (dialogContext) {
        return Dialog(
          elevation: 24,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.zoom_in_rounded, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Navigator.pop(dialogContext),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              // Elevated interactive view
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(dialogContext).size.height * 0.72,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 30,
                        spreadRadius: 6,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Center(
                      child: _buildSingleImage(imagePath, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSingleImage(String path, {BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else {
      return Image.file(
        File(path),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: widget.colors.muted.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: widget.colors.mutedFg,
          size: 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.colors.muted.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.colors.border.withValues(alpha: 0.6),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: widget.colors.mutedFg,
                  size: 48,
                ),
                const SizedBox(height: 6),
                Text(
                  'No Image Available',
                  style: AppTypography.labelSmall.copyWith(
                    color: widget.colors.mutedFg,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Side-by-side showcase for 2 images: 1st landscape (16:9) + 2nd portrait (9:16)
    if (widget.images.length == 2) {
      final img1 = widget.images[0];
      final img2 = widget.images[1];
      return SizedBox(
        height: 190,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo 1 (16:9 Landscape - flex 16)
            Expanded(
              flex: 16,
              child: GestureDetector(
                onTap: () => _showElevatedImage(
                  context,
                  img1,
                  'Photo 1 • Landscape (16:9)',
                ),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: widget.colors.muted.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.colors.border.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildSingleImage(img1, fit: BoxFit.cover),
                      // 16:9 Badge top left
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.crop_16_9, size: 11, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                '16:9 Landscape',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Elevate button bottom right
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fullscreen_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Photo 2 (9:16 Portrait contrast - flex 10)
            Expanded(
              flex: 10,
              child: GestureDetector(
                onTap: () => _showElevatedImage(
                  context,
                  img2,
                  'Photo 2 • Portrait (9:16)',
                ),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: widget.colors.muted.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.colors.border.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildSingleImage(img2, fit: BoxFit.cover),
                      // 9:16 Badge top left
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.crop_portrait, size: 11, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                '9:16 Portrait',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Elevate button bottom right
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fullscreen_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.images.length == 1) {
      final img = widget.images.first;
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: GestureDetector(
          onTap: () => _showElevatedImage(
            context,
            img,
            'Photo • Landscape (16:9)',
          ),
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: widget.colors.muted.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.colors.border.withValues(alpha: 0.6),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildSingleImage(img, fit: BoxFit.cover),
                // Elevate button bottom right
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fullscreen_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Elevate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: widget.colors.muted.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.colors.border.withValues(alpha: 0.6),
          ),
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (idx) {
                setState(() => _currentIndex = idx);
              },
              itemBuilder: (context, index) {
                final curPath = widget.images[index];
                return GestureDetector(
                  onTap: () => _showElevatedImage(
                    context,
                    curPath,
                    'Photo ${index + 1}',
                  ),
                  child: _buildSingleImage(curPath),
                );
              },
            ),
            // Page Indicator Badge
            Positioned(
              bottom: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Dots indicator at center bottom
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (idx) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentIndex == idx ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentIndex == idx
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
