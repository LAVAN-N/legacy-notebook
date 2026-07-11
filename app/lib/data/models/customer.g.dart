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
      photoUrl: json['photoUrl'] as String?,
      locationUrl: json['locationUrl'] as String?,
      weekdayId: json['weekdayId'] as String,
      placeId: json['placeId'] as String,
      areaId: json['areaId'] as String,
      sequenceNumber: (json['sequenceNumber'] as num).toInt(),
      status: json['status'] as String,
      guardianName: json['guardianName'] as String?,
      dob: json['dob'] as String?,
      occupation: json['occupation'] as String?,
      notes: json['notes'] as String?,
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
      'photoUrl': instance.photoUrl,
      'locationUrl': instance.locationUrl,
      'weekdayId': instance.weekdayId,
      'placeId': instance.placeId,
      'areaId': instance.areaId,
      'sequenceNumber': instance.sequenceNumber,
      'status': instance.status,
      'guardianName': instance.guardianName,
      'dob': instance.dob,
      'occupation': instance.occupation,
      'notes': instance.notes,
    };
