import 'package:freezed_annotation/freezed_annotation.dart';
import 'collection.dart';
import 'sale.dart';
import 'sale_item.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

@freezed
class Activity with _$Activity {
  const factory Activity.payment({
    required String id,
    required DateTime at,
    required int amount,
    String? note,
    required String collectorName,
  }) = PaymentActivity;

  const factory Activity.partialPayment({
    required String id,
    required DateTime at,
    required int amount,
    required String note,
    required String collectorName,
  }) = PartialPaymentActivity;

  const factory Activity.carryForward({
    required String id,
    required DateTime at,
    required String note,
    required String collectorName,
  }) = CarryForwardActivity;

  const factory Activity.sale({
    required String id,
    required DateTime at,
    required List<SaleItemDetail> items,
    required int total,
    required int advance,
    required int creditAdded,
    required String saleType, // READY or CREDIT
    required String collectorName,
    String? note,
  }) = SaleActivity;

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);
}

@freezed
class SaleItemDetail with _$SaleItemDetail {
  const factory SaleItemDetail({
    required String productName,
    required int quantity,
    required int unitPrice,
  }) = _SaleItemDetail;

  factory SaleItemDetail.fromJson(Map<String, dynamic> json) => _$SaleItemDetailFromJson(json);
}
