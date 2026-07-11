import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Stream<List<Product>> watchProducts();
  Future<Product?> getProductById(String id);
}
