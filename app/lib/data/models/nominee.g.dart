// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nominee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Nominee _$NomineeFromJson(Map<String, dynamic> json) => _Nominee(
  id: json['id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  relation: json['relation'] as String?,
  dob: json['dob'] as String?,
);

Map<String, dynamic> _$NomineeToJson(_Nominee instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'relation': instance.relation,
  'dob': instance.dob,
};
