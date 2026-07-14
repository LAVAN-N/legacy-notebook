import 'package:freezed_annotation/freezed_annotation.dart';

part 'id_proof.freezed.dart';
part 'id_proof.g.dart';

@freezed
class IdProofDocument with _$IdProofDocument {
  const factory IdProofDocument({
    required String filename,
    required String mimeType,
    required int sizeBytes,
    required String localUri,
  }) = _IdProofDocument;

  factory IdProofDocument.fromJson(Map<String, dynamic> json) => _$IdProofDocumentFromJson(json);
}

@freezed
class IdProof with _$IdProof {
  const factory IdProof({
    required String id,
    required String type, // 'Aadhaar' | 'Voter' | 'DL' | 'PAN' | 'Other'
    required String number,
    IdProofDocument? document,
  }) = _IdProof;

  factory IdProof.fromJson(Map<String, dynamic> json) => _$IdProofFromJson(json);
}
