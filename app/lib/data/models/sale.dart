import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale.freezed.dart';
part 'sale.g.dart';

@freezed
abstract class Sale with _$Sale {
  const factory Sale({
    required String id,
    required String customerId,
    required DateTime saleDatetime,
    required String saleType, // 'READY' or 'CREDIT'
    required int totalAmount,
    required int advanceAmount,
    required int financedAmount, // Credit Added: totalAmount - advanceAmount
    required String soldBy,
    String? remarks,
  }) = _Sale;

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);
}
