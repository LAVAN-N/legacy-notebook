// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaleImpl _$$SaleImplFromJson(Map<String, dynamic> json) => _$SaleImpl(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      saleDatetime: DateTime.parse(json['saleDatetime'] as String),
      saleType: json['saleType'] as String,
      totalAmount: (json['totalAmount'] as num).toInt(),
      advanceAmount: (json['advanceAmount'] as num).toInt(),
      financedAmount: (json['financedAmount'] as num).toInt(),
      soldBy: json['soldBy'] as String,
      remarks: json['remarks'] as String?,
    );

Map<String, dynamic> _$$SaleImplToJson(_$SaleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'saleDatetime': instance.saleDatetime.toIso8601String(),
      'saleType': instance.saleType,
      'totalAmount': instance.totalAmount,
      'advanceAmount': instance.advanceAmount,
      'financedAmount': instance.financedAmount,
      'soldBy': instance.soldBy,
      'remarks': instance.remarks,
    };
