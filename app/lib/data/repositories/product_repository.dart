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
    required double costPrice,
    required double sellingPrice,
    required double mrp,
    required int stock,
    required String categoryId,
    required int minimumStock,
    String? description,
    String? imageUrl,
  });
  Future<void> updateProduct(Product product);
}
