import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String customerCode,
    required String name,
    required String phone,
    String? alternatePhone,
    required String address,
    String? landmark,
    String? photoUrl,
    String? locationUrl,
    required String weekdayId,
    required String placeId,
    required String areaId,
    required int sequenceNumber,
    required String status, // 'ACTIVE' or 'INACTIVE' or 'DO_NOT_VISIT'
    String? guardianName,
    String? dob,
    String? occupation,
    String? notes,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
}
