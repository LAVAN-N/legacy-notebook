import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String sku,
    required String name,
    required String brand,
    required String category,
    required int minimumStock,
    required int stock, // Current stock quantity
    required int price, // Default sales price (rupees)
    String? imageUrl,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}
