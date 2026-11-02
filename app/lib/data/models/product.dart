import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String sku,
    required String name,
    required String brand,
    required String categoryId,
    required int minimumStock,
    required int stock, // Current stock quantity
    required int costPrice, // Cost price in paise (₹ × 100)
    required int sellingPrice, // Selling price in paise (₹ × 100)
    required int mrp, // Maximum Retail Price in paise (₹ × 100)
    String? imageUrl,
    String? imageUrl2,
    String? description,
    @Default('JAN 2026') String mfgDate,
    @Default(0.0) double warranty,
    String? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}
