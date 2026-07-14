import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/category.dart';

void showAddProductSheet(BuildContext context, {String? initialCategoryId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return const _AddProductSheet();
    },
  );
}

class _AddProductSheet extends StatefulWidget {
  const _AddProductSheet({Key? key}) : super(key: key);

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  String? _selectedCategoryId;
  
  void _showAddCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add new category', style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Category name *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Icon (e.g. shirt, speaker)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Category created (Mock)')),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Product',
                      style: theme.textTheme.titleLarge,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: mockCategoriesList.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => _showAddCategorySheet(context),
                    child: const Text('+ Add new category'),
                  ),
                ),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Brand *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'SKU *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Price (₹) *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: '0',
                        decoration: InputDecoration(
                          labelText: 'Stock *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(icon: const Icon(Icons.remove), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                        ],
                      ),
                    ),
                  ],
                ),
                // Photo placeholder
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.inventory_2, size: 40, color: colors.primary),
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colors.surface,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.camera_alt, size: 16),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product added · UNDO'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Add product'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
