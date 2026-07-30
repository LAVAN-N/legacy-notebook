// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id_proof.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IdProofDocumentImpl _$$IdProofDocumentImplFromJson(
        Map<String, dynamic> json) =>
    _$IdProofDocumentImpl(
      filename: json['filename'] as String,
      mimeType: json['mimeType'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      localUri: json['localUri'] as String,
    );

Map<String, dynamic> _$$IdProofDocumentImplToJson(
        _$IdProofDocumentImpl instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'mimeType': instance.mimeType,
      'sizeBytes': instance.sizeBytes,
      'localUri': instance.localUri,
    };

_$IdProofImpl _$$IdProofImplFromJson(Map<String, dynamic> json) =>
    _$IdProofImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      proofUrl: json['proof_url'] as String,
      document: json['document'] == null
          ? null
          : IdProofDocument.fromJson(json['document'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$IdProofImplToJson(_$IdProofImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'proof_url': instance.proofUrl,
      'document': instance.document,
    };
