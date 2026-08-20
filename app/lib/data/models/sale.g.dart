// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Sale _$SaleFromJson(Map<String, dynamic> json) => _Sale(
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

Map<String, dynamic> _$SaleToJson(_Sale instance) => <String, dynamic>{
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
