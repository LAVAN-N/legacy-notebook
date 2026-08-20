// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outstanding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Outstanding _$OutstandingFromJson(Map<String, dynamic> json) => _Outstanding(
  customerId: json['customerId'] as String,
  totalFinanced: (json['totalFinanced'] as num).toInt(),
  totalCollected: (json['totalCollected'] as num).toInt(),
  outstandingAmount: (json['outstandingAmount'] as num).toInt(),
  totalLendFinanced: (json['totalLendFinanced'] as num?)?.toInt() ?? 0,
  totalLendCollected: (json['totalLendCollected'] as num?)?.toInt() ?? 0,
  totalSaleFinanced: (json['totalSaleFinanced'] as num?)?.toInt() ?? 0,
  totalSaleCollected: (json['totalSaleCollected'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OutstandingToJson(_Outstanding instance) =>
    <String, dynamic>{
      'customerId': instance.customerId,
      'totalFinanced': instance.totalFinanced,
      'totalCollected': instance.totalCollected,
      'outstandingAmount': instance.outstandingAmount,
      'totalLendFinanced': instance.totalLendFinanced,
      'totalLendCollected': instance.totalLendCollected,
      'totalSaleFinanced': instance.totalSaleFinanced,
      'totalSaleCollected': instance.totalSaleCollected,
    };
