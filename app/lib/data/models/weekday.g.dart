// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekday.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Weekday _$WeekdayFromJson(Map<String, dynamic> json) => _Weekday(
  id: json['id'] as String,
  name: json['name'] as String,
  sortOrder: (json['sortOrder'] as num).toInt(),
);

Map<String, dynamic> _$WeekdayToJson(_Weekday instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sortOrder': instance.sortOrder,
};
