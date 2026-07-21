import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
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
  String _searchQuery = '';
  String _filterType = 'All'; // All, In stock, Low stock, Out of stock

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    final productsAsync = ref.watch(productsStreamProvider);
    final allProducts = productsAsync.value ?? [];

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

      displayCategories = mockCategoriesList
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              displayProducts.any((p) => p.categoryId == c.id))
          .map((c) {
            final count = displayProducts.where((p) => p.categoryId == c.id).length;
            return c.copyWith(productCount: count);
          })
          .toList();
    } else {
      displayProducts = filteredProducts;
      displayCategories = mockCategoriesList.map((c) {
        final count =
            displayProducts.where((p) => p.categoryId == c.id).length;
        return c.copyWith(productCount: count);
      }).toList();
    }

    return AppScaffold(
      blendHeader: true,
      title: const Text('Inventory'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddProductSheet(context),
        child: const Icon(Icons.add),
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
                hintText: 'Search categories, products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'In stock', 'Low stock', 'Out of stock']
                  .map((filter) {
                final isSelected = _filterType == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _filterType = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Summary
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              _searchQuery.isNotEmpty
                  ? '${displayProducts.length} matching products found'
                  : '${displayCategories.length} categories · ${displayProducts.length} products',
              style: theme.textTheme.bodySmall,
            ),
          ),

          // Grid of Categories or Products
          Expanded(
            child: _searchQuery.isNotEmpty
                ? (displayProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 48, color: colors.mutedFg),
                            const SizedBox(height: 16),
                            Text(
                              'No products found matching "$_searchQuery"',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 280,
                        ),
                        itemCount: displayProducts.length,
                        itemBuilder: (context, index) {
                          final product = displayProducts[index];
                          return _buildProductCard(context, product, colors);
                        },
                      ))
                : (displayCategories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 48, color: colors.mutedFg),
                            const SizedBox(height: 16),
                            Text(
                              'No categories found',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
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
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, Category category, AppColors colors) {
    final theme = Theme.of(context);

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
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.productCount} products',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.mutedFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, AppColors colors) {
    final theme = Theme.of(context);
    final category = mockCategoriesList.firstWhere(
      (c) => c.id == product.categoryId, 
      orElse: () => const Category(id: '', name: 'Unknown', icon: '')
    );

    return Card(
      child: InkWell(
        onTap: () {
          context.go('${Routes.inventoryCategory(product.categoryId)}?productId=${product.id}');
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
                    image: product.imageUrl != null && product.imageUrl!.isNotEmpty
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
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.mutedFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Name
              Text(
                product.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Brand
              Text(
                product.brand,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.mutedFg,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Price
              Text(
                '₹ ${(product.price / 100).toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
