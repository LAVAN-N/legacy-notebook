import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Stream<List<Product>> watchProducts();
  Future<Product?> getProductById(String id);
  Future<List<String>> getBrandsByCategory(String categoryId);
  Stream<List<String>> watchBrandsByCategory(String categoryId);
  Future<Product> addProduct({
    required String name,
    required String brand,
    required String sku,
    required int costPrice,
    required int sellingPrice,
    required int mrp,
    required int stock,
    required String categoryId,
    required int minimumStock,
    String? description,
    String? imageUrl,
    String? imageUrl2,
    String mfgDate = 'JAN 2026',
    double warranty = 0.0,
    String? updatedAt,
  });
  Future<void> updateProduct(Product product);
  Future<void> renameBrand(String oldBrand, String newBrand);
}
