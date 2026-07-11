// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CollectionImpl _$$CollectionImplFromJson(Map<String, dynamic> json) =>
    _$CollectionImpl(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      visitDatetime: DateTime.parse(json['visitDatetime'] as String),
      status: json['status'] as String,
      amount: (json['amount'] as num).toInt(),
      reason: json['reason'] as String?,
      collectedBy: json['collectedBy'] as String,
    );

Map<String, dynamic> _$$CollectionImplToJson(_$CollectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'visitDatetime': instance.visitDatetime.toIso8601String(),
      'status': instance.status,
      'amount': instance.amount,
      'reason': instance.reason,
      'collectedBy': instance.collectedBy,
    };
