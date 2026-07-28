import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/product.dart';
import '../../data/models/category.dart';
import '../../data/providers.dart';
import 'widgets/add_product_sheet.dart';

class InventoryProductsScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String? initialProductId;

  const InventoryProductsScreen({
    super.key,
    required this.categoryId,
    this.initialProductId,
  });

  @override
  ConsumerState<InventoryProductsScreen> createState() =>
      _InventoryProductsScreenState();
}

class _InventoryProductsScreenState
    extends ConsumerState<InventoryProductsScreen> {
  String _searchQuery = '';
  String _filterType = 'All';
  String _sortType = 'Newest';
  late Category _category;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _category = mockCategoriesList.firstWhere((c) => c.id == widget.categoryId,
        orElse: () =>
            Category(id: widget.categoryId, name: 'Products', icon: ''));

    if (widget.initialProductId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final productsAsync = ref.read(productsStreamProvider);
        final allProducts = productsAsync.value ?? [];
        try {
          final product =
              allProducts.firstWhere((p) => p.id == widget.initialProductId);
          showEditProductSheet(context, product);
        } catch (_) {}
      });
    }
  }
  Color _getStockColor(Product product, AppColors colors) {
    if (product.stock == 0) {
      return colors.danger;
    } else if (product.stock <= product.minimumStock) {
      return colors.warning;
    }
    return colors.success;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    final productsAsync = ref.watch(productsStreamProvider);
    final allProducts = productsAsync.value ?? [];

    var products =
        allProducts.where((p) => p.categoryId == widget.categoryId).toList();

    // Apply stock filter
    if (_filterType == 'In stock') {
      products = products.where((p) => p.stock > p.minimumStock).toList();
    } else if (_filterType == 'Low stock') {
      products = products
          .where((p) => p.stock > 0 && p.stock <= p.minimumStock)
          .toList();
    } else if (_filterType == 'Out of stock') {
      products = products.where((p) => p.stock == 0).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.brand.toLowerCase().contains(query) ||
              p.sku.toLowerCase().contains(query))
          .toList();
    }

    // Apply sort
    switch (_sortType) {
      case 'Price ↑':
        products.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
      case 'Price ↓':
        products.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case 'Name A-Z':
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Newest':
      default:
        // Keep original order (newest first)
        break;
    }
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final rawSafeAreaBottom = MediaQueryData.fromView(View.of(context)).padding.bottom;

    return AppScaffold(
      blendHeader: true,
      title: Text(
        _category.name,
        style: AppTypography.headlineMedium.copyWith(color: colors.foreground),
      ),
      floatingActionButton: IgnorePointer(
        ignoring: !_isFabVisible,
        child: AnimatedScale(
          scale: _isFabVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: isKeyboardOpen ? 16.0 : 88.0 + rawSafeAreaBottom,
            ),
            child: Opacity(
              opacity: 0.85,
              child: FloatingActionButton(
                onPressed: () {
                  showAddProductSheet(context, initialCategoryId: widget.categoryId);
                },
                shape: const CircleBorder(),
                backgroundColor: colors.primary,
                foregroundColor: colors.primaryFg,
                child: const Icon(Icons.add_box_rounded),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search_rounded, color: colors.mutedFg),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // Filter and sort chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ...[
                  'All',
                  'In stock',
                  'Low stock',
                  'Out of stock',
                ].map((filter) {
                  final isSelected = _filterType == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        filter,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected ? colors.primary : colors.mutedFg,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _filterType = filter;
                        });
                      },
                      selectedColor: colors.primary.withValues(alpha: 0.15),
                      backgroundColor: colors.surface,
                      checkmarkColor: colors.primary,
                      side: BorderSide(
                        color: isSelected ? colors.primary : colors.border,
                      ),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: PopupMenuButton<String>(
                    initialValue: _sortType,
                    onSelected: (value) {
                      setState(() {
                        _sortType = value;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        'Newest',
                        'Price ↑',
                        'Price ↓',
                        'Name A-Z',
                      ].map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(
                            choice,
                            style: AppTypography.bodyMedium.copyWith(color: colors.foreground),
                          ),
                        );
                      }).toList();
                    },
                    child: Chip(
                      label: Text(
                        'Sort: $_sortType',
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: colors.surface,
                      side: BorderSide(color: colors.border),
                      deleteIcon: Icon(Icons.arrow_drop_down,
                          color: colors.mutedFg, size: 18),
                      onDeleted: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.reverse) {
                  if (_isFabVisible) setState(() => _isFabVisible = false);
                } else if (notification.direction == ScrollDirection.forward) {
                  if (!_isFabVisible) setState(() => _isFabVisible = true);
                }
                return false;
              },
              child: products.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 88.0 + rawSafeAreaBottom),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 48, color: colors.mutedFg),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: AppTypography.bodyLarge.copyWith(color: colors.foreground),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16.0 + 88.0 + rawSafeAreaBottom,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 280,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(
                        context,
                        products[index],
                        colors,
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context, Product product, AppColors colors) {
    return Card(
      child: InkWell(
        onTap: () {
          showEditProductSheet(context, product);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    image: product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty
                        ? (product.imageUrl!.startsWith('assets/')
                            ? DecorationImage(
                                image: AssetImage(product.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : (product.imageUrl!.startsWith('http')
                                ? DecorationImage(
                                    image: NetworkImage(product.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: FileImage(File(product.imageUrl!)),
                                    fit: BoxFit.cover,
                                  )))
                        : null,
                  ),
                  child: product.imageUrl == null || product.imageUrl!.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.inventory_2,
                            color: colors.primary,
                            size: 40,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 6),
              // Name
              Text(
                product.name,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.foreground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Brand
              Text(
                product.brand,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.mutedFg,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Price and Stock badge Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              CurrencyFormatter.format(product.sellingPrice),
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'x${product.costPrice > 0 ? (((product.sellingPrice - product.costPrice) / product.costPrice) * 100).round() : 0}%',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              'MRP: ${CurrencyFormatter.format(product.mrp)}',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.mutedFg,
                                fontSize: 9,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              'Cost: ${CurrencyFormatter.format(product.costPrice)}',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.mutedFg,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStockColor(product, colors),
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
            ],
          ),
        ),
      ),
    );
  }
}
