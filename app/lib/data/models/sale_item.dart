import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale_item.freezed.dart';
part 'sale_item.g.dart';

@freezed
abstract class SaleItem with _$SaleItem {
  const factory SaleItem({
    required String id,
    required String saleId,
    required String productId,
    required int quantity,
    required int unitPrice,
    required int totalPrice,
    @Default('purchased') String status,
    @Default(0) int collectedAmount,
  }) = _SaleItem;

  factory SaleItem.fromJson(Map<String, dynamic> json) => _$SaleItemFromJson(json);
}
