// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentActivity _$PaymentActivityFromJson(Map<String, dynamic> json) =>
    PaymentActivity(
      id: json['id'] as String,
      at: DateTime.parse(json['at'] as String),
      amount: (json['amount'] as num).toInt(),
      note: json['note'] as String?,
      collectorName: json['collectorName'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$PaymentActivityToJson(PaymentActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'at': instance.at.toIso8601String(),
      'amount': instance.amount,
      'note': instance.note,
      'collectorName': instance.collectorName,
      'runtimeType': instance.$type,
    };

PartialPaymentActivity _$PartialPaymentActivityFromJson(
  Map<String, dynamic> json,
) => PartialPaymentActivity(
  id: json['id'] as String,
  at: DateTime.parse(json['at'] as String),
  amount: (json['amount'] as num).toInt(),
  note: json['note'] as String,
  collectorName: json['collectorName'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$PartialPaymentActivityToJson(
  PartialPaymentActivity instance,
) => <String, dynamic>{
  'id': instance.id,
  'at': instance.at.toIso8601String(),
  'amount': instance.amount,
  'note': instance.note,
  'collectorName': instance.collectorName,
  'runtimeType': instance.$type,
};

CarryForwardActivity _$CarryForwardActivityFromJson(
  Map<String, dynamic> json,
) => CarryForwardActivity(
  id: json['id'] as String,
  at: DateTime.parse(json['at'] as String),
  note: json['note'] as String,
  collectorName: json['collectorName'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CarryForwardActivityToJson(
  CarryForwardActivity instance,
) => <String, dynamic>{
  'id': instance.id,
  'at': instance.at.toIso8601String(),
  'note': instance.note,
  'collectorName': instance.collectorName,
  'runtimeType': instance.$type,
};

SaleActivity _$SaleActivityFromJson(Map<String, dynamic> json) => SaleActivity(
  id: json['id'] as String,
  at: DateTime.parse(json['at'] as String),
  items: (json['items'] as List<dynamic>)
      .map((e) => SaleItemDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  advance: (json['advance'] as num).toInt(),
  creditAdded: (json['creditAdded'] as num).toInt(),
  saleType: json['saleType'] as String,
  collectorName: json['collectorName'] as String,
  note: json['note'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$SaleActivityToJson(SaleActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'at': instance.at.toIso8601String(),
      'items': instance.items,
      'total': instance.total,
      'advance': instance.advance,
      'creditAdded': instance.creditAdded,
      'saleType': instance.saleType,
      'collectorName': instance.collectorName,
      'note': instance.note,
      'runtimeType': instance.$type,
    };

_SaleItemDetail _$SaleItemDetailFromJson(Map<String, dynamic> json) =>
    _SaleItemDetail(
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toInt(),
    );

Map<String, dynamic> _$SaleItemDetailToJson(_SaleItemDetail instance) =>
    <String, dynamic>{
      'productName': instance.productName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
    };
