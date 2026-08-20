// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'id_proof.freezed.dart';
part 'id_proof.g.dart';

@freezed
abstract class IdProofDocument with _$IdProofDocument {
  const factory IdProofDocument({
    required String filename,
    required String mimeType,
    required int sizeBytes,
    required String localUri,
  }) = _IdProofDocument;

  factory IdProofDocument.fromJson(Map<String, dynamic> json) => _$IdProofDocumentFromJson(json);
}

@freezed
abstract class IdProof with _$IdProof {
  const factory IdProof({
    required String id,
    required String type, // 'Aadhaar' | 'Voter' | 'DL' | 'PAN' | 'Other'
    @JsonKey(name: 'proof_url') required String proofUrl,
    IdProofDocument? document,
  }) = _IdProof;

  factory IdProof.fromJson(Map<String, dynamic> json) => _$IdProofFromJson(json);

  static IdProof fromJsonCustom(Map<String, dynamic> json) {
    final proof = IdProof.fromJson(json);
    if (proof.document == null && proof.proofUrl.isNotEmpty) {
      final decodedUrl = Uri.decodeFull(proof.proofUrl);
      return proof.copyWith(
        document: IdProofDocument(
          filename: decodedUrl.split('/').last.split('?').first,
          mimeType: proof.proofUrl.toLowerCase().contains('.pdf') ? 'application/pdf' : 'image/jpeg',
          sizeBytes: 0,
          localUri: proof.proofUrl,
        ),
      );
    }
    return proof;
  }
}
