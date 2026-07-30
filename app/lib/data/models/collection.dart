import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection.freezed.dart';
part 'collection.g.dart';

@freezed
class Collection with _$Collection {
  const factory Collection({
    required String id,
    required String customerId,
    required DateTime visitDatetime,
    required String status, // 'PAYMENT', 'PARTIAL_PAYMENT', 'CARRY_FORWARD'
    required double amount,
    String? reason,
    required String collectedBy,
  }) = _Collection;

  factory Collection.fromJson(Map<String, dynamic> json) => _$CollectionFromJson(json);
}
