import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _category = mockCategoriesList
        .firstWhere((c) => c.id == widget.categoryId,
            orElse: () => Category(id: widget.categoryId, name: 'Products', icon: ''));
            
    if (widget.initialProductId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final productsAsync = ref.read(productsStreamProvider);
        final allProducts = productsAsync.value ?? [];
        try {
          final product = allProducts.firstWhere((p) => p.id == widget.initialProductId);
          showEditProductSheet(context, product);
        } catch (_) {}
      });
    }
  }

  String _getStockStatus(Product product) {
    if (product.stock == 0) {
      return 'Out of stock';
    } else if (product.stock <= product.minimumStock) {
      return 'Low stock';
    }
    return 'In stock';
  }

  Color _getStockColor(Product product) {
    if (product.stock == 0) {
      return Colors.red;
    } else if (product.stock <= product.minimumStock) {
      return Colors.amber;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    final productsAsync = ref.watch(productsStreamProvider);
    final allProducts = productsAsync.value ?? [];

    var products = allProducts
        .where((p) => p.categoryId == widget.categoryId)
        .toList();

    // Apply stock filter
    if (_filterType == 'In stock') {
      products = products.where((p) => p.stock > p.minimumStock).toList();
    } else if (_filterType == 'Low stock') {
      products =
          products.where((p) => p.stock > 0 && p.stock <= p.minimumStock).toList();
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
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price ↓':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Name A-Z':
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Newest':
      default:
        // Keep original order (newest first)
        break;
    }

    return AppScaffold(
      blendHeader: true,
      title: Text(_category.name),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddProductSheet(context, initialCategoryId: widget.categoryId);
        },
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
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _filterType = filter;
                        });
                      },
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
                          child: Text(choice),
                        );
                      }).toList();
                    },
                    child: Chip(
                      label: Text('Sort: $_sortType'),
                      onDeleted: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox,
                            size: 48, color: colors.mutedFg),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
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
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, AppColors colors) {
    final theme = Theme.of(context);

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
              // Name
              Text(
                product.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
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
              const SizedBox(height: 6),
              // Price
              Text(
                CurrencyFormatter.format(product.price),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 6),
              // Stock badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStockColor(product).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getStockStatus(product),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getStockColor(product),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
