import 'package:freezed_annotation/freezed_annotation.dart';

part 'nominee.freezed.dart';
part 'nominee.g.dart';

@freezed
class Nominee with _$Nominee {
  const factory Nominee({
    required String id,
    required String name,
    required String phone,
    String? relation,
    String? dob,
  }) = _Nominee;

  factory Nominee.fromJson(Map<String, dynamic> json) => _$NomineeFromJson(json);
}
