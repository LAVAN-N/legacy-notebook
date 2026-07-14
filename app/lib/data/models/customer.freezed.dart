// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return _Customer.fromJson(json);
}

/// @nodoc
mixin _$Customer {
  String get id => throw _privateConstructorUsedError;
  String get customerCode => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String? get alternatePhone => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get landmark => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get locationUrl => throw _privateConstructorUsedError;
  Location? get location => throw _privateConstructorUsedError;
  List<Nominee> get nominees => throw _privateConstructorUsedError;
  List<IdProof> get idProofs => throw _privateConstructorUsedError;
  String get weekdayId => throw _privateConstructorUsedError;
  String get placeId => throw _privateConstructorUsedError;
  String get areaId => throw _privateConstructorUsedError;
  int get sequenceNumber => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'ACTIVE' or 'INACTIVE' or 'DO_NOT_VISIT'
  String? get guardianName => throw _privateConstructorUsedError;
  String? get dob => throw _privateConstructorUsedError;
  String? get occupation => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Customer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerCopyWith<Customer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerCopyWith<$Res> {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) then) =
      _$CustomerCopyWithImpl<$Res, Customer>;
  @useResult
  $Res call(
      {String id,
      String customerCode,
      String name,
      String phone,
      String? alternatePhone,
      String address,
      String? landmark,
      String? photoUrl,
      String? locationUrl,
      Location? location,
      List<Nominee> nominees,
      List<IdProof> idProofs,
      String weekdayId,
      String placeId,
      String areaId,
      int sequenceNumber,
      String status,
      String? guardianName,
      String? dob,
      String? occupation,
      String? notes});

  $LocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$CustomerCopyWithImpl<$Res, $Val extends Customer>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerCode = null,
    Object? name = null,
    Object? phone = null,
    Object? alternatePhone = freezed,
    Object? address = null,
    Object? landmark = freezed,
    Object? photoUrl = freezed,
    Object? locationUrl = freezed,
    Object? location = freezed,
    Object? nominees = null,
    Object? idProofs = null,
    Object? weekdayId = null,
    Object? placeId = null,
    Object? areaId = null,
    Object? sequenceNumber = null,
    Object? status = null,
    Object? guardianName = freezed,
    Object? dob = freezed,
    Object? occupation = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerCode: null == customerCode
          ? _value.customerCode
          : customerCode // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      alternatePhone: freezed == alternatePhone
          ? _value.alternatePhone
          : alternatePhone // ignore: cast_nullable_to_non_nullable
              as String?,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      landmark: freezed == landmark
          ? _value.landmark
          : landmark // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      locationUrl: freezed == locationUrl
          ? _value.locationUrl
          : locationUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location?,
      nominees: null == nominees
          ? _value.nominees
          : nominees // ignore: cast_nullable_to_non_nullable
              as List<Nominee>,
      idProofs: null == idProofs
          ? _value.idProofs
          : idProofs // ignore: cast_nullable_to_non_nullable
              as List<IdProof>,
      weekdayId: null == weekdayId
          ? _value.weekdayId
          : weekdayId // ignore: cast_nullable_to_non_nullable
              as String,
      placeId: null == placeId
          ? _value.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String,
      areaId: null == areaId
          ? _value.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as String,
      sequenceNumber: null == sequenceNumber
          ? _value.sequenceNumber
          : sequenceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      guardianName: freezed == guardianName
          ? _value.guardianName
          : guardianName // ignore: cast_nullable_to_non_nullable
              as String?,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      occupation: freezed == occupation
          ? _value.occupation
          : occupation // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $LocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CustomerImplCopyWith<$Res>
    implements $CustomerCopyWith<$Res> {
  factory _$$CustomerImplCopyWith(
          _$CustomerImpl value, $Res Function(_$CustomerImpl) then) =
      __$$CustomerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String customerCode,
      String name,
      String phone,
      String? alternatePhone,
      String address,
      String? landmark,
      String? photoUrl,
      String? locationUrl,
      Location? location,
      List<Nominee> nominees,
      List<IdProof> idProofs,
      String weekdayId,
      String placeId,
      String areaId,
      int sequenceNumber,
      String status,
      String? guardianName,
      String? dob,
      String? occupation,
      String? notes});

  @override
  $LocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$CustomerImplCopyWithImpl<$Res>
    extends _$CustomerCopyWithImpl<$Res, _$CustomerImpl>
    implements _$$CustomerImplCopyWith<$Res> {
  __$$CustomerImplCopyWithImpl(
      _$CustomerImpl _value, $Res Function(_$CustomerImpl) _then)
      : super(_value, _then);

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerCode = null,
    Object? name = null,
    Object? phone = null,
    Object? alternatePhone = freezed,
    Object? address = null,
    Object? landmark = freezed,
    Object? photoUrl = freezed,
    Object? locationUrl = freezed,
    Object? location = freezed,
    Object? nominees = null,
    Object? idProofs = null,
    Object? weekdayId = null,
    Object? placeId = null,
    Object? areaId = null,
    Object? sequenceNumber = null,
    Object? status = null,
    Object? guardianName = freezed,
    Object? dob = freezed,
    Object? occupation = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$CustomerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerCode: null == customerCode
          ? _value.customerCode
          : customerCode // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      alternatePhone: freezed == alternatePhone
          ? _value.alternatePhone
          : alternatePhone // ignore: cast_nullable_to_non_nullable
              as String?,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      landmark: freezed == landmark
          ? _value.landmark
          : landmark // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      locationUrl: freezed == locationUrl
          ? _value.locationUrl
          : locationUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location?,
      nominees: null == nominees
          ? _value._nominees
          : nominees // ignore: cast_nullable_to_non_nullable
              as List<Nominee>,
      idProofs: null == idProofs
          ? _value._idProofs
          : idProofs // ignore: cast_nullable_to_non_nullable
              as List<IdProof>,
      weekdayId: null == weekdayId
          ? _value.weekdayId
          : weekdayId // ignore: cast_nullable_to_non_nullable
              as String,
      placeId: null == placeId
          ? _value.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String,
      areaId: null == areaId
          ? _value.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as String,
      sequenceNumber: null == sequenceNumber
          ? _value.sequenceNumber
          : sequenceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      guardianName: freezed == guardianName
          ? _value.guardianName
          : guardianName // ignore: cast_nullable_to_non_nullable
              as String?,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      occupation: freezed == occupation
          ? _value.occupation
          : occupation // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerImpl implements _Customer {
  const _$CustomerImpl(
      {required this.id,
      required this.customerCode,
      required this.name,
      required this.phone,
      this.alternatePhone,
      required this.address,
      this.landmark,
      this.photoUrl,
      this.locationUrl,
      this.location,
      final List<Nominee> nominees = const [],
      final List<IdProof> idProofs = const [],
      required this.weekdayId,
      required this.placeId,
      required this.areaId,
      required this.sequenceNumber,
      required this.status,
      this.guardianName,
      this.dob,
      this.occupation,
      this.notes})
      : _nominees = nominees,
        _idProofs = idProofs;

  factory _$CustomerImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerImplFromJson(json);

  @override
  final String id;
  @override
  final String customerCode;
  @override
  final String name;
  @override
  final String phone;
  @override
  final String? alternatePhone;
  @override
  final String address;
  @override
  final String? landmark;
  @override
  final String? photoUrl;
  @override
  final String? locationUrl;
  @override
  final Location? location;
  final List<Nominee> _nominees;
  @override
  @JsonKey()
  List<Nominee> get nominees {
    if (_nominees is EqualUnmodifiableListView) return _nominees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nominees);
  }

  final List<IdProof> _idProofs;
  @override
  @JsonKey()
  List<IdProof> get idProofs {
    if (_idProofs is EqualUnmodifiableListView) return _idProofs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_idProofs);
  }

  @override
  final String weekdayId;
  @override
  final String placeId;
  @override
  final String areaId;
  @override
  final int sequenceNumber;
  @override
  final String status;
// 'ACTIVE' or 'INACTIVE' or 'DO_NOT_VISIT'
  @override
  final String? guardianName;
  @override
  final String? dob;
  @override
  final String? occupation;
  @override
  final String? notes;

  @override
  String toString() {
    return 'Customer(id: $id, customerCode: $customerCode, name: $name, phone: $phone, alternatePhone: $alternatePhone, address: $address, landmark: $landmark, photoUrl: $photoUrl, locationUrl: $locationUrl, location: $location, nominees: $nominees, idProofs: $idProofs, weekdayId: $weekdayId, placeId: $placeId, areaId: $areaId, sequenceNumber: $sequenceNumber, status: $status, guardianName: $guardianName, dob: $dob, occupation: $occupation, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerCode, customerCode) ||
                other.customerCode == customerCode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.alternatePhone, alternatePhone) ||
                other.alternatePhone == alternatePhone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.landmark, landmark) ||
                other.landmark == landmark) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.locationUrl, locationUrl) ||
                other.locationUrl == locationUrl) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._nominees, _nominees) &&
            const DeepCollectionEquality().equals(other._idProofs, _idProofs) &&
            (identical(other.weekdayId, weekdayId) ||
                other.weekdayId == weekdayId) &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.areaId, areaId) || other.areaId == areaId) &&
            (identical(other.sequenceNumber, sequenceNumber) ||
                other.sequenceNumber == sequenceNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.guardianName, guardianName) ||
                other.guardianName == guardianName) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.occupation, occupation) ||
                other.occupation == occupation) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        customerCode,
        name,
        phone,
        alternatePhone,
        address,
        landmark,
        photoUrl,
        locationUrl,
        location,
        const DeepCollectionEquality().hash(_nominees),
        const DeepCollectionEquality().hash(_idProofs),
        weekdayId,
        placeId,
        areaId,
        sequenceNumber,
        status,
        guardianName,
        dob,
        occupation,
        notes
      ]);

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      __$$CustomerImplCopyWithImpl<_$CustomerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerImplToJson(
      this,
    );
  }
}

abstract class _Customer implements Customer {
  const factory _Customer(
      {required final String id,
      required final String customerCode,
      required final String name,
      required final String phone,
      final String? alternatePhone,
      required final String address,
      final String? landmark,
      final String? photoUrl,
      final String? locationUrl,
      final Location? location,
      final List<Nominee> nominees,
      final List<IdProof> idProofs,
      required final String weekdayId,
      required final String placeId,
      required final String areaId,
      required final int sequenceNumber,
      required final String status,
      final String? guardianName,
      final String? dob,
      final String? occupation,
      final String? notes}) = _$CustomerImpl;

  factory _Customer.fromJson(Map<String, dynamic> json) =
      _$CustomerImpl.fromJson;

  @override
  String get id;
  @override
  String get customerCode;
  @override
  String get name;
  @override
  String get phone;
  @override
  String? get alternatePhone;
  @override
  String get address;
  @override
  String? get landmark;
  @override
  String? get photoUrl;
  @override
  String? get locationUrl;
  @override
  Location? get location;
  @override
  List<Nominee> get nominees;
  @override
  List<IdProof> get idProofs;
  @override
  String get weekdayId;
  @override
  String get placeId;
  @override
  String get areaId;
  @override
  int get sequenceNumber;
  @override
  String get status; // 'ACTIVE' or 'INACTIVE' or 'DO_NOT_VISIT'
  @override
  String? get guardianName;
  @override
  String? get dob;
  @override
  String? get occupation;
  @override
  String? get notes;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
