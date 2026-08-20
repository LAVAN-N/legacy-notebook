// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Collection _$CollectionFromJson(Map<String, dynamic> json) => _Collection(
  id: json['id'] as String,
  customerId: json['customerId'] as String,
  visitDatetime: DateTime.parse(json['visitDatetime'] as String),
  status: json['status'] as String,
  amount: (json['amount'] as num).toDouble(),
  reason: json['reason'] as String?,
  collectedBy: json['collectedBy'] as String,
);

Map<String, dynamic> _$CollectionToJson(_Collection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'visitDatetime': instance.visitDatetime.toIso8601String(),
      'status': instance.status,
      'amount': instance.amount,
      'reason': instance.reason,
      'collectedBy': instance.collectedBy,
    };
