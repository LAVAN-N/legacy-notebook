// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentActivityImpl _$$PaymentActivityImplFromJson(
        Map<String, dynamic> json) =>
    _$PaymentActivityImpl(
      id: json['id'] as String,
      at: DateTime.parse(json['at'] as String),
      amount: (json['amount'] as num).toInt(),
      note: json['note'] as String?,
      collectorName: json['collectorName'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PaymentActivityImplToJson(
        _$PaymentActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'at': instance.at.toIso8601String(),
      'amount': instance.amount,
      'note': instance.note,
      'collectorName': instance.collectorName,
      'runtimeType': instance.$type,
    };

_$PartialPaymentActivityImpl _$$PartialPaymentActivityImplFromJson(
        Map<String, dynamic> json) =>
    _$PartialPaymentActivityImpl(
      id: json['id'] as String,
      at: DateTime.parse(json['at'] as String),
      amount: (json['amount'] as num).toInt(),
      note: json['note'] as String,
      collectorName: json['collectorName'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PartialPaymentActivityImplToJson(
        _$PartialPaymentActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'at': instance.at.toIso8601String(),
      'amount': instance.amount,
      'note': instance.note,
      'collectorName': instance.collectorName,
      'runtimeType': instance.$type,
    };

_$CarryForwardActivityImpl _$$CarryForwardActivityImplFromJson(
        Map<String, dynamic> json) =>
    _$CarryForwardActivityImpl(
      id: json['id'] as String,
      at: DateTime.parse(json['at'] as String),
      note: json['note'] as String,
      collectorName: json['collectorName'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CarryForwardActivityImplToJson(
        _$CarryForwardActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'at': instance.at.toIso8601String(),
      'note': instance.note,
      'collectorName': instance.collectorName,
      'runtimeType': instance.$type,
    };

_$SaleActivityImpl _$$SaleActivityImplFromJson(Map<String, dynamic> json) =>
    _$SaleActivityImpl(
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

Map<String, dynamic> _$$SaleActivityImplToJson(_$SaleActivityImpl instance) =>
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

_$SaleItemDetailImpl _$$SaleItemDetailImplFromJson(Map<String, dynamic> json) =>
    _$SaleItemDetailImpl(
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toInt(),
    );

Map<String, dynamic> _$$SaleItemDetailImplToJson(
        _$SaleItemDetailImpl instance) =>
    <String, dynamic>{
      'productName': instance.productName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
    };
