// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerImpl _$$CustomerImplFromJson(Map<String, dynamic> json) =>
    _$CustomerImpl(
      id: json['id'] as String,
      customerCode: json['customerCode'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      alternatePhone: json['alternatePhone'] as String?,
      address: json['address'] as String,
      landmark: json['landmark'] as String?,
      profileUrl: json['profile_url'] as String?,
      locationUrl: json['locationUrl'] as String?,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      nominees: (json['nominees'] as List<dynamic>?)
              ?.map((e) => Nominee.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      idProofs: (json['idProofs'] as List<dynamic>?)
              ?.map((e) => IdProof.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      weekdayId: json['weekdayId'] as String,
      placeId: json['placeId'] as String,
      areaId: json['areaId'] as String,
      status: json['status'] as String,
      dob: json['dob'] as String?,
      occupation: json['occupation'] as String?,
      notes: json['notes'] as String?,
      credit: (json['credit'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CustomerImplToJson(_$CustomerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerCode': instance.customerCode,
      'name': instance.name,
      'phone': instance.phone,
      'alternatePhone': instance.alternatePhone,
      'address': instance.address,
      'landmark': instance.landmark,
      'profile_url': instance.profileUrl,
      'locationUrl': instance.locationUrl,
      'location': instance.location,
      'nominees': instance.nominees,
      'idProofs': instance.idProofs,
      'weekdayId': instance.weekdayId,
      'placeId': instance.placeId,
      'areaId': instance.areaId,
      'status': instance.status,
      'dob': instance.dob,
      'occupation': instance.occupation,
      'notes': instance.notes,
      'credit': instance.credit,
    };
