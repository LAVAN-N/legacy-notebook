// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Customer {

 String get id; String get customerCode; String get name; String get phone; String? get alternatePhone; String get address; String? get landmark;@JsonKey(name: 'profile_url') String? get profileUrl; String? get locationUrl; Location? get location; List<Nominee> get nominees; List<IdProof> get idProofs; String get weekdayId; String get placeId; String get areaId; String get status; String? get dob; String? get occupation; String? get notes; int get credit;
/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerCopyWith<Customer> get copyWith => _$CustomerCopyWithImpl<Customer>(this as Customer, _$identity);

  /// Serializes this Customer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Customer&&(identical(other.id, id) || other.id == id)&&(identical(other.customerCode, customerCode) || other.customerCode == customerCode)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.alternatePhone, alternatePhone) || other.alternatePhone == alternatePhone)&&(identical(other.address, address) || other.address == address)&&(identical(other.landmark, landmark) || other.landmark == landmark)&&(identical(other.profileUrl, profileUrl) || other.profileUrl == profileUrl)&&(identical(other.locationUrl, locationUrl) || other.locationUrl == locationUrl)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.nominees, nominees)&&const DeepCollectionEquality().equals(other.idProofs, idProofs)&&(identical(other.weekdayId, weekdayId) || other.weekdayId == weekdayId)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.areaId, areaId) || other.areaId == areaId)&&(identical(other.status, status) || other.status == status)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.credit, credit) || other.credit == credit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,customerCode,name,phone,alternatePhone,address,landmark,profileUrl,locationUrl,location,const DeepCollectionEquality().hash(nominees),const DeepCollectionEquality().hash(idProofs),weekdayId,placeId,areaId,status,dob,occupation,notes,credit]);

@override
String toString() {
  return 'Customer(id: $id, customerCode: $customerCode, name: $name, phone: $phone, alternatePhone: $alternatePhone, address: $address, landmark: $landmark, profileUrl: $profileUrl, locationUrl: $locationUrl, location: $location, nominees: $nominees, idProofs: $idProofs, weekdayId: $weekdayId, placeId: $placeId, areaId: $areaId, status: $status, dob: $dob, occupation: $occupation, notes: $notes, credit: $credit)';
}


}

/// @nodoc
abstract mixin class $CustomerCopyWith<$Res>  {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) _then) = _$CustomerCopyWithImpl;
@useResult
$Res call({
 String id, String customerCode, String name, String phone, String? alternatePhone, String address, String? landmark,@JsonKey(name: 'profile_url') String? profileUrl, String? locationUrl, Location? location, List<Nominee> nominees, List<IdProof> idProofs, String weekdayId, String placeId, String areaId, String status, String? dob, String? occupation, String? notes, int credit
});


$LocationCopyWith<$Res>? get location;

}
/// @nodoc
class _$CustomerCopyWithImpl<$Res>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._self, this._then);

  final Customer _self;
  final $Res Function(Customer) _then;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerCode = null,Object? name = null,Object? phone = null,Object? alternatePhone = freezed,Object? address = null,Object? landmark = freezed,Object? profileUrl = freezed,Object? locationUrl = freezed,Object? location = freezed,Object? nominees = null,Object? idProofs = null,Object? weekdayId = null,Object? placeId = null,Object? areaId = null,Object? status = null,Object? dob = freezed,Object? occupation = freezed,Object? notes = freezed,Object? credit = null,}) {
  return _then(Customer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerCode: null == customerCode ? _self.customerCode : customerCode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,alternatePhone: freezed == alternatePhone ? _self.alternatePhone : alternatePhone // ignore: cast_nullable_to_non_nullable
as String?,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,landmark: freezed == landmark ? _self.landmark : landmark // ignore: cast_nullable_to_non_nullable
as String?,profileUrl: freezed == profileUrl ? _self.profileUrl : profileUrl // ignore: cast_nullable_to_non_nullable
as String?,locationUrl: freezed == locationUrl ? _self.locationUrl : locationUrl // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,nominees: null == nominees ? _self.nominees : nominees // ignore: cast_nullable_to_non_nullable
as List<Nominee>,idProofs: null == idProofs ? _self.idProofs : idProofs // ignore: cast_nullable_to_non_nullable
as List<IdProof>,weekdayId: null == weekdayId ? _self.weekdayId : weekdayId // ignore: cast_nullable_to_non_nullable
as String,placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,areaId: null == areaId ? _self.areaId : areaId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as String?,occupation: freezed == occupation ? _self.occupation : occupation // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [Customer].
extension CustomerPatterns on Customer {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Customer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Customer value)  $default,){
final _that = this;
switch (_that) {
case _Customer():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Customer value)?  $default,){
final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String customerCode,  String name,  String phone,  String? alternatePhone,  String address,  String? landmark, @JsonKey(name: 'profile_url')  String? profileUrl,  String? locationUrl,  Location? location,  List<Nominee> nominees,  List<IdProof> idProofs,  String weekdayId,  String placeId,  String areaId,  String status,  String? dob,  String? occupation,  String? notes,  int credit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that.id,_that.customerCode,_that.name,_that.phone,_that.alternatePhone,_that.address,_that.landmark,_that.profileUrl,_that.locationUrl,_that.location,_that.nominees,_that.idProofs,_that.weekdayId,_that.placeId,_that.areaId,_that.status,_that.dob,_that.occupation,_that.notes,_that.credit);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String customerCode,  String name,  String phone,  String? alternatePhone,  String address,  String? landmark, @JsonKey(name: 'profile_url')  String? profileUrl,  String? locationUrl,  Location? location,  List<Nominee> nominees,  List<IdProof> idProofs,  String weekdayId,  String placeId,  String areaId,  String status,  String? dob,  String? occupation,  String? notes,  int credit)  $default,) {final _that = this;
switch (_that) {
case _Customer():
return $default(_that.id,_that.customerCode,_that.name,_that.phone,_that.alternatePhone,_that.address,_that.landmark,_that.profileUrl,_that.locationUrl,_that.location,_that.nominees,_that.idProofs,_that.weekdayId,_that.placeId,_that.areaId,_that.status,_that.dob,_that.occupation,_that.notes,_that.credit);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String customerCode,  String name,  String phone,  String? alternatePhone,  String address,  String? landmark, @JsonKey(name: 'profile_url')  String? profileUrl,  String? locationUrl,  Location? location,  List<Nominee> nominees,  List<IdProof> idProofs,  String weekdayId,  String placeId,  String areaId,  String status,  String? dob,  String? occupation,  String? notes,  int credit)?  $default,) {final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that.id,_that.customerCode,_that.name,_that.phone,_that.alternatePhone,_that.address,_that.landmark,_that.profileUrl,_that.locationUrl,_that.location,_that.nominees,_that.idProofs,_that.weekdayId,_that.placeId,_that.areaId,_that.status,_that.dob,_that.occupation,_that.notes,_that.credit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Customer implements Customer {
  const _Customer({required this.id, required this.customerCode, required this.name, required this.phone, this.alternatePhone, required this.address, this.landmark, @JsonKey(name: 'profile_url') this.profileUrl, this.locationUrl, this.location,  List<Nominee> nominees = const [],  List<IdProof> idProofs = const [], required this.weekdayId, required this.placeId, required this.areaId, required this.status, this.dob, this.occupation, this.notes, this.credit = 0}): _nominees = nominees,_idProofs = idProofs;
  factory _Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);

@override final  String id;
@override final  String customerCode;
@override final  String name;
@override final  String phone;
@override final  String? alternatePhone;
@override final  String address;
@override final  String? landmark;
@override@JsonKey(name: 'profile_url') final  String? profileUrl;
@override final  String? locationUrl;
@override final  Location? location;
 final  List<Nominee> _nominees;
@override@JsonKey() List<Nominee> get nominees {
  if (_nominees is EqualUnmodifiableListView) return _nominees;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nominees);
}

 final  List<IdProof> _idProofs;
@override@JsonKey() List<IdProof> get idProofs {
  if (_idProofs is EqualUnmodifiableListView) return _idProofs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_idProofs);
}

@override final  String weekdayId;
@override final  String placeId;
@override final  String areaId;
@override final  String status;
@override final  String? dob;
@override final  String? occupation;
@override final  String? notes;
@override@JsonKey() final  int credit;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerCopyWith<_Customer> get copyWith => __$CustomerCopyWithImpl<_Customer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Customer&&(identical(other.id, id) || other.id == id)&&(identical(other.customerCode, customerCode) || other.customerCode == customerCode)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.alternatePhone, alternatePhone) || other.alternatePhone == alternatePhone)&&(identical(other.address, address) || other.address == address)&&(identical(other.landmark, landmark) || other.landmark == landmark)&&(identical(other.profileUrl, profileUrl) || other.profileUrl == profileUrl)&&(identical(other.locationUrl, locationUrl) || other.locationUrl == locationUrl)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._nominees, _nominees)&&const DeepCollectionEquality().equals(other._idProofs, _idProofs)&&(identical(other.weekdayId, weekdayId) || other.weekdayId == weekdayId)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.areaId, areaId) || other.areaId == areaId)&&(identical(other.status, status) || other.status == status)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.credit, credit) || other.credit == credit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,customerCode,name,phone,alternatePhone,address,landmark,profileUrl,locationUrl,location,const DeepCollectionEquality().hash(_nominees),const DeepCollectionEquality().hash(_idProofs),weekdayId,placeId,areaId,status,dob,occupation,notes,credit]);

@override
String toString() {
  return 'Customer(id: $id, customerCode: $customerCode, name: $name, phone: $phone, alternatePhone: $alternatePhone, address: $address, landmark: $landmark, profileUrl: $profileUrl, locationUrl: $locationUrl, location: $location, nominees: $nominees, idProofs: $idProofs, weekdayId: $weekdayId, placeId: $placeId, areaId: $areaId, status: $status, dob: $dob, occupation: $occupation, notes: $notes, credit: $credit)';
}


}

/// @nodoc
abstract mixin class _$CustomerCopyWith<$Res> implements $CustomerCopyWith<$Res> {
  factory _$CustomerCopyWith(_Customer value, $Res Function(_Customer) _then) = __$CustomerCopyWithImpl;
@override @useResult
$Res call({
 String id, String customerCode, String name, String phone, String? alternatePhone, String address, String? landmark,@JsonKey(name: 'profile_url') String? profileUrl, String? locationUrl, Location? location, List<Nominee> nominees, List<IdProof> idProofs, String weekdayId, String placeId, String areaId, String status, String? dob, String? occupation, String? notes, int credit
});


@override $LocationCopyWith<$Res>? get location;

}
/// @nodoc
class __$CustomerCopyWithImpl<$Res>
    implements _$CustomerCopyWith<$Res> {
  __$CustomerCopyWithImpl(this._self, this._then);

  final _Customer _self;
  final $Res Function(_Customer) _then;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerCode = null,Object? name = null,Object? phone = null,Object? alternatePhone = freezed,Object? address = null,Object? landmark = freezed,Object? profileUrl = freezed,Object? locationUrl = freezed,Object? location = freezed,Object? nominees = null,Object? idProofs = null,Object? weekdayId = null,Object? placeId = null,Object? areaId = null,Object? status = null,Object? dob = freezed,Object? occupation = freezed,Object? notes = freezed,Object? credit = null,}) {
  return _then(_Customer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerCode: null == customerCode ? _self.customerCode : customerCode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,alternatePhone: freezed == alternatePhone ? _self.alternatePhone : alternatePhone // ignore: cast_nullable_to_non_nullable
as String?,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,landmark: freezed == landmark ? _self.landmark : landmark // ignore: cast_nullable_to_non_nullable
as String?,profileUrl: freezed == profileUrl ? _self.profileUrl : profileUrl // ignore: cast_nullable_to_non_nullable
as String?,locationUrl: freezed == locationUrl ? _self.locationUrl : locationUrl // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,nominees: null == nominees ? _self._nominees : nominees // ignore: cast_nullable_to_non_nullable
as List<Nominee>,idProofs: null == idProofs ? _self._idProofs : idProofs // ignore: cast_nullable_to_non_nullable
as List<IdProof>,weekdayId: null == weekdayId ? _self.weekdayId : weekdayId // ignore: cast_nullable_to_non_nullable
as String,placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,areaId: null == areaId ? _self.areaId : areaId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as String?,occupation: freezed == occupation ? _self.occupation : occupation // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,credit: null == credit ? _self.credit : credit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

// dart format on
