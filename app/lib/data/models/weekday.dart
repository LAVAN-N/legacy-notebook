import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekday.freezed.dart';
part 'weekday.g.dart';

@freezed
abstract class Weekday with _$Weekday {
  const factory Weekday({
    required String id,
    required String name,
    required int sortOrder,
  }) = _Weekday;

  factory Weekday.fromJson(Map<String, dynamic> json) => _$WeekdayFromJson(json);
}
