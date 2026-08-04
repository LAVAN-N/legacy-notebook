// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outstanding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OutstandingImpl _$$OutstandingImplFromJson(Map<String, dynamic> json) =>
    _$OutstandingImpl(
      customerId: json['customerId'] as String,
      totalFinanced: (json['totalFinanced'] as num).toInt(),
      totalCollected: (json['totalCollected'] as num).toInt(),
      outstandingAmount: (json['outstandingAmount'] as num).toInt(),
      totalLendFinanced: (json['totalLendFinanced'] as num?)?.toInt() ?? 0,
      totalLendCollected: (json['totalLendCollected'] as num?)?.toInt() ?? 0,
      totalSaleFinanced: (json['totalSaleFinanced'] as num?)?.toInt() ?? 0,
      totalSaleCollected: (json['totalSaleCollected'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$OutstandingImplToJson(_$OutstandingImpl instance) =>
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
