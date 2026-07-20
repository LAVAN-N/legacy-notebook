// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nominee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NomineeImpl _$$NomineeImplFromJson(Map<String, dynamic> json) =>
    _$NomineeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      relation: json['relation'] as String?,
      phone: json['phone'] as String?,
      dob: json['dob'] as String?,
    );

Map<String, dynamic> _$$NomineeImplToJson(_$NomineeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'relation': instance.relation,
      'phone': instance.phone,
      'dob': instance.dob,
    };
