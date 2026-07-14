import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/router/routes.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/product.dart';
import '../../data/models/category.dart';
import 'widgets/add_product_sheet.dart';

class InventoryCategoriesScreen extends ConsumerStatefulWidget {
  const InventoryCategoriesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InventoryCategoriesScreen> createState() =>
      _InventoryCategoriesScreenState();
}

class _InventoryCategoriesScreenState
    extends ConsumerState<InventoryCategoriesScreen> {
  String _searchQuery = '';
  String _filterType = 'All'; // All, In stock, Low stock, Out of stock

  late List<Category> _displayCategories;
  late List<Product> _displayProducts;

  @override
  void initState() {
    super.initState();
    _updateDisplay();
  }

  void _updateDisplay() {
    // Filter products based on stock filter
    var filteredProducts = mockProductsList.where((p) {
      if (_filterType == 'In stock') {
        return p.stock > p.minimumStock;
      } else if (_filterType == 'Low stock') {
        return p.stock > 0 && p.stock <= p.minimumStock;
      } else if (_filterType == 'Out of stock') {
        return p.stock == 0;
      }
      return true;
    }).toList();

    // Apply search to both categories and products
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      _displayProducts = filteredProducts
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.brand.toLowerCase().contains(query) ||
              p.sku.toLowerCase().contains(query))
          .toList();

      _displayCategories = mockCategoriesList
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              _displayProducts.any((p) => p.categoryId == c.id))
          .map((c) {
            final count = _displayProducts.where((p) => p.categoryId == c.id).length;
            return c.copyWith(productCount: count);
          })
          .toList();
    } else {
      _displayProducts = filteredProducts;
      _displayCategories = mockCategoriesList.map((c) {
        final count =
            _displayProducts.where((p) => p.categoryId == c.id).length;
        return c.copyWith(productCount: count);
      }).toList();
    }
  }

  IconData _getIconForCategory(String iconName) {
    final iconMap = {
      'frying-pan': Icons.kitchen,
      'shirt': Icons.checkroom,
      'speaker': Icons.speaker,
      'lightbulb': Icons.lightbulb,
      'wind': Icons.air,
    };
    return iconMap[iconName] ?? Icons.inventory_2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

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
                  _updateDisplay();
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
                        _updateDisplay();
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
              '${_displayCategories.length} categories · ${_displayProducts.length} products',
              style: theme.textTheme.bodySmall,
            ),
          ),

          // Grid
          Expanded(
            child: _displayCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox,
                            size: 48, color: colors.mutedFg),
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
                    itemCount: _displayCategories.length,
                    itemBuilder: (context, index) {
                      final category = _displayCategories[index];
                      return _buildCategoryCard(context, category, colors);
                    },
                  ),
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
                  color: colors.primary.withOpacity(0.1),
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
}

extension on Category {
  Category copyWith({int? productCount}) {
    return Category(
      id: id,
      name: name,
      icon: icon,
      productCount: productCount ?? this.productCount,
    );
  }
}
