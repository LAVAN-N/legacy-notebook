// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Sale {

 String get id; String get customerId; DateTime get saleDatetime; String get saleType; int get totalAmount; int get advanceAmount; int get financedAmount; String get soldBy; String? get remarks;
/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleCopyWith<Sale> get copyWith => _$SaleCopyWithImpl<Sale>(this as Sale, _$identity);

  /// Serializes this Sale to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sale&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.saleDatetime, saleDatetime) || other.saleDatetime == saleDatetime)&&(identical(other.saleType, saleType) || other.saleType == saleType)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.advanceAmount, advanceAmount) || other.advanceAmount == advanceAmount)&&(identical(other.financedAmount, financedAmount) || other.financedAmount == financedAmount)&&(identical(other.soldBy, soldBy) || other.soldBy == soldBy)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,saleDatetime,saleType,totalAmount,advanceAmount,financedAmount,soldBy,remarks);

@override
String toString() {
  return 'Sale(id: $id, customerId: $customerId, saleDatetime: $saleDatetime, saleType: $saleType, totalAmount: $totalAmount, advanceAmount: $advanceAmount, financedAmount: $financedAmount, soldBy: $soldBy, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class $SaleCopyWith<$Res>  {
  factory $SaleCopyWith(Sale value, $Res Function(Sale) _then) = _$SaleCopyWithImpl;
@useResult
$Res call({
 String id, String customerId, DateTime saleDatetime, String saleType, int totalAmount, int advanceAmount, int financedAmount, String soldBy, String? remarks
});




}
/// @nodoc
class _$SaleCopyWithImpl<$Res>
    implements $SaleCopyWith<$Res> {
  _$SaleCopyWithImpl(this._self, this._then);

  final Sale _self;
  final $Res Function(Sale) _then;

/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerId = null,Object? saleDatetime = null,Object? saleType = null,Object? totalAmount = null,Object? advanceAmount = null,Object? financedAmount = null,Object? soldBy = null,Object? remarks = freezed,}) {
  return _then(Sale(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,saleDatetime: null == saleDatetime ? _self.saleDatetime : saleDatetime // ignore: cast_nullable_to_non_nullable
as DateTime,saleType: null == saleType ? _self.saleType : saleType // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,advanceAmount: null == advanceAmount ? _self.advanceAmount : advanceAmount // ignore: cast_nullable_to_non_nullable
as int,financedAmount: null == financedAmount ? _self.financedAmount : financedAmount // ignore: cast_nullable_to_non_nullable
as int,soldBy: null == soldBy ? _self.soldBy : soldBy // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Sale].
extension SalePatterns on Sale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sale value)  $default,){
final _that = this;
switch (_that) {
case _Sale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sale value)?  $default,){
final _that = this;
switch (_that) {
case _Sale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String customerId,  DateTime saleDatetime,  String saleType,  int totalAmount,  int advanceAmount,  int financedAmount,  String soldBy,  String? remarks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sale() when $default != null:
return $default(_that.id,_that.customerId,_that.saleDatetime,_that.saleType,_that.totalAmount,_that.advanceAmount,_that.financedAmount,_that.soldBy,_that.remarks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String customerId,  DateTime saleDatetime,  String saleType,  int totalAmount,  int advanceAmount,  int financedAmount,  String soldBy,  String? remarks)  $default,) {final _that = this;
switch (_that) {
case _Sale():
return $default(_that.id,_that.customerId,_that.saleDatetime,_that.saleType,_that.totalAmount,_that.advanceAmount,_that.financedAmount,_that.soldBy,_that.remarks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String customerId,  DateTime saleDatetime,  String saleType,  int totalAmount,  int advanceAmount,  int financedAmount,  String soldBy,  String? remarks)?  $default,) {final _that = this;
switch (_that) {
case _Sale() when $default != null:
return $default(_that.id,_that.customerId,_that.saleDatetime,_that.saleType,_that.totalAmount,_that.advanceAmount,_that.financedAmount,_that.soldBy,_that.remarks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sale implements Sale {
  const _Sale({required this.id, required this.customerId, required this.saleDatetime, required this.saleType, required this.totalAmount, required this.advanceAmount, required this.financedAmount, required this.soldBy, this.remarks});
  factory _Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);

@override final  String id;
@override final  String customerId;
@override final  DateTime saleDatetime;
@override final  String saleType;
@override final  int totalAmount;
@override final  int advanceAmount;
@override final  int financedAmount;
@override final  String soldBy;
@override final  String? remarks;

/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleCopyWith<_Sale> get copyWith => __$SaleCopyWithImpl<_Sale>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sale&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.saleDatetime, saleDatetime) || other.saleDatetime == saleDatetime)&&(identical(other.saleType, saleType) || other.saleType == saleType)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.advanceAmount, advanceAmount) || other.advanceAmount == advanceAmount)&&(identical(other.financedAmount, financedAmount) || other.financedAmount == financedAmount)&&(identical(other.soldBy, soldBy) || other.soldBy == soldBy)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,saleDatetime,saleType,totalAmount,advanceAmount,financedAmount,soldBy,remarks);

@override
String toString() {
  return 'Sale(id: $id, customerId: $customerId, saleDatetime: $saleDatetime, saleType: $saleType, totalAmount: $totalAmount, advanceAmount: $advanceAmount, financedAmount: $financedAmount, soldBy: $soldBy, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class _$SaleCopyWith<$Res> implements $SaleCopyWith<$Res> {
  factory _$SaleCopyWith(_Sale value, $Res Function(_Sale) _then) = __$SaleCopyWithImpl;
@override @useResult
$Res call({
 String id, String customerId, DateTime saleDatetime, String saleType, int totalAmount, int advanceAmount, int financedAmount, String soldBy, String? remarks
});




}
/// @nodoc
class __$SaleCopyWithImpl<$Res>
    implements _$SaleCopyWith<$Res> {
  __$SaleCopyWithImpl(this._self, this._then);

  final _Sale _self;
  final $Res Function(_Sale) _then;

/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerId = null,Object? saleDatetime = null,Object? saleType = null,Object? totalAmount = null,Object? advanceAmount = null,Object? financedAmount = null,Object? soldBy = null,Object? remarks = freezed,}) {
  return _then(_Sale(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,saleDatetime: null == saleDatetime ? _self.saleDatetime : saleDatetime // ignore: cast_nullable_to_non_nullable
as DateTime,saleType: null == saleType ? _self.saleType : saleType // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,advanceAmount: null == advanceAmount ? _self.advanceAmount : advanceAmount // ignore: cast_nullable_to_non_nullable
as int,financedAmount: null == financedAmount ? _self.financedAmount : financedAmount // ignore: cast_nullable_to_non_nullable
as int,soldBy: null == soldBy ? _self.soldBy : soldBy // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
