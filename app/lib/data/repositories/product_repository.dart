import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Stream<List<Product>> watchProducts();
  Future<Product?> getProductById(String id);
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
  });
  Future<void> updateProduct(Product product);
}
