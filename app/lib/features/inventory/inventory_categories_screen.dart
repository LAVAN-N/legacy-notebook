import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/router/routes.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/product.dart';
import '../../data/models/category.dart';
import '../../data/providers.dart';
import 'widgets/add_product_sheet.dart';

class InventoryCategoriesScreen extends ConsumerStatefulWidget {
  const InventoryCategoriesScreen({super.key});

  @override
  ConsumerState<InventoryCategoriesScreen> createState() =>
      _InventoryCategoriesScreenState();
}

class _InventoryCategoriesScreenState
    extends ConsumerState<InventoryCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'All'; // All, In stock, Low stock, Out of stock
  bool _isFabVisible = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIconForCategory(String iconName) {
    final iconMap = {
      'frying-pan': Icons.kitchen,
      'shirt': Icons.checkroom,
      'speaker': Icons.speaker,
      'lightbulb': Icons.lightbulb,
      'wind': Icons.air,
      'shopping-bag': Icons.shopping_bag,
      'phone': Icons.phone_android,
      'laptop': Icons.laptop,
      'chair': Icons.chair,
      'tv': Icons.tv,
      'book': Icons.book,
      'toy': Icons.toys,
    };
    return iconMap[iconName] ?? Icons.inventory_2;
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

    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.value ?? mockCategoriesList;

    // Filter products based on stock filter
    var filteredProducts = allProducts.where((p) {
      if (_filterType == 'In stock') {
        return p.stock > p.minimumStock;
      } else if (_filterType == 'Low stock') {
        return p.stock > 0 && p.stock <= p.minimumStock;
      } else if (_filterType == 'Out of stock') {
        return p.stock == 0;
      }
      return true;
    }).toList();

    List<Product> displayProducts;
    List<Category> displayCategories;

    // Apply search to both categories and products
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      displayProducts = filteredProducts
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.brand.toLowerCase().contains(query) ||
              p.sku.toLowerCase().contains(query))
          .toList();

      displayCategories = categories
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              displayProducts.any((p) => p.categoryId == c.id))
          .map((c) {
        final count = displayProducts.where((p) => p.categoryId == c.id).length;
        return c.copyWith(productCount: count);
      }).toList();
    } else {
      displayProducts = filteredProducts;
      displayCategories = categories.map((c) {
        final count = displayProducts.where((p) => p.categoryId == c.id).length;
        return c.copyWith(productCount: count);
      }).toList();
    }

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final rawSafeAreaBottom = MediaQueryData.fromView(View.of(context)).padding.bottom;

    return AppScaffold(
      blendHeader: true,
      title: const Text('Inventory'),
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
                heroTag: 'categories_fab',
                onPressed: () => showAddProductSheet(context),
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
          // Filter pills & Search bar Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 38,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: AppTypography.labelMedium.copyWith(color: colors.mutedFg),
                      prefixIcon: Icon(Icons.search_rounded, color: colors.mutedFg, size: 16),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Icon(Icons.clear_rounded, color: colors.mutedFg, size: 16),
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    style: AppTypography.labelMedium.copyWith(color: colors.foreground),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...['All', 'In stock', 'Low stock', 'Out of stock'].map((type) {
                          final isSelected = _filterType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _filterType = type;
                                });
                              },
                              selectedColor: colors.primary.withValues(alpha: 0.15),
                              backgroundColor: colors.surface,
                              checkmarkColor: colors.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? colors.primary : colors.mutedFg,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isSelected ? colors.primary : colors.border,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Summary
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              _searchQuery.isNotEmpty
                  ? '${displayProducts.length} matching products found'
                  : '${displayCategories.length} categories · ${displayProducts.length} products',
              style: AppTypography.bodySmall.copyWith(color: colors.mutedFg),
            ),
          ),

          // Grid of Categories or Products
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(productsStreamProvider);
                ref.invalidate(categoriesStreamProvider);
                try {
                  await ref.read(productsStreamProvider.future);
                } catch (_) {}
              },
              color: colors.primary,
              child: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction == ScrollDirection.reverse) {
                    if (_isFabVisible) setState(() => _isFabVisible = false);
                  } else if (notification.direction == ScrollDirection.forward) {
                    if (!_isFabVisible) setState(() => _isFabVisible = true);
                  }
                  return false;
                },
                child: _searchQuery.isNotEmpty
                    ? (displayProducts.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                                parent: ClampingScrollPhysics()),
                            child: Container(
                              alignment: Alignment.center,
                              height: MediaQuery.of(context).size.height * 0.5,
                              padding: EdgeInsets.only(bottom: 88.0 + rawSafeAreaBottom),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 48, color: colors.mutedFg),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No products found matching "$_searchQuery"',
                                    style: AppTypography.bodyLarge.copyWith(color: colors.foreground),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                                parent: ClampingScrollPhysics()),
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
                            itemCount: displayProducts.length,
                            itemBuilder: (context, index) {
                              final product = displayProducts[index];
                              return _buildProductCard(context, product, colors, categories);
                            },
                          ))
                    : (displayCategories.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                                parent: ClampingScrollPhysics()),
                            child: Container(
                              alignment: Alignment.center,
                              height: MediaQuery.of(context).size.height * 0.5,
                              padding: EdgeInsets.only(bottom: 88.0 + rawSafeAreaBottom),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox, size: 48, color: colors.mutedFg),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No categories found',
                                    style: AppTypography.bodyLarge.copyWith(color: colors.foreground),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                                parent: ClampingScrollPhysics()),
                            padding: EdgeInsets.fromLTRB(
                              16,
                              16,
                              16,
                              16.0 + 88.0 + rawSafeAreaBottom,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1,
                            ),
                            itemCount: displayCategories.length,
                            itemBuilder: (context, index) {
                              final category = displayCategories[index];
                              return _buildCategoryCard(context, category, colors);
                            },
                          )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, Category category, AppColors colors) {
    return GestureDetector(
      onTap: () {
        context.go(Routes.inventoryCategory(category.id));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForCategory(category.icon),
                  color: colors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.foreground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.productCount} products',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.mutedFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context, Product product, AppColors colors, List<Category> categories) {
    final category = categories.firstWhere(
        (c) => c.id == product.categoryId,
        orElse: () => const Category(id: '', name: 'Unknown', icon: ''));

    return Card(
      child: InkWell(
        onTap: () {
          context.go(
              '${Routes.inventoryCategory(product.categoryId)}?productId=${product.id}');
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
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.muted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category.name,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.mutedFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Name
              Text(
                product.name,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.foreground,
                ),
                maxLines: 1,
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
              const SizedBox(height: 4),
              // Price and Stock badge Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '₹ ${(product.sellingPrice / 100).toStringAsFixed(2)}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
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
