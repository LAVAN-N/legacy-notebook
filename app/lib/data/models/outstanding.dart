import 'package:freezed_annotation/freezed_annotation.dart';

part 'outstanding.freezed.dart';
part 'outstanding.g.dart';

@freezed
class Outstanding with _$Outstanding {
  const factory Outstanding({
    required String customerId,
    required int totalFinanced,
    required int totalCollected,
    required int outstandingAmount, // totalFinanced - totalCollected
  }) = _Outstanding;

  factory Outstanding.fromJson(Map<String, dynamic> json) => _$OutstandingFromJson(json);
}
