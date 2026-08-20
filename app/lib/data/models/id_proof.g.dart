// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id_proof.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IdProofDocument _$IdProofDocumentFromJson(Map<String, dynamic> json) =>
    _IdProofDocument(
      filename: json['filename'] as String,
      mimeType: json['mimeType'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      localUri: json['localUri'] as String,
    );

Map<String, dynamic> _$IdProofDocumentToJson(_IdProofDocument instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'mimeType': instance.mimeType,
      'sizeBytes': instance.sizeBytes,
      'localUri': instance.localUri,
    };

_IdProof _$IdProofFromJson(Map<String, dynamic> json) => _IdProof(
  id: json['id'] as String,
  type: json['type'] as String,
  proofUrl: json['proof_url'] as String,
  document: json['document'] == null
      ? null
      : IdProofDocument.fromJson(json['document'] as Map<String, dynamic>),
);

Map<String, dynamic> _$IdProofToJson(_IdProof instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'proof_url': instance.proofUrl,
  'document': instance.document,
};
