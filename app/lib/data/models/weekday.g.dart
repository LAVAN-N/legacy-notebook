// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekday.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeekdayImpl _$$WeekdayImplFromJson(Map<String, dynamic> json) =>
    _$WeekdayImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
    );

Map<String, dynamic> _$$WeekdayImplToJson(_$WeekdayImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sortOrder': instance.sortOrder,
    };
