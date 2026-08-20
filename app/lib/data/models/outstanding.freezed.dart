// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outstanding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Outstanding {

 String get customerId; int get totalFinanced; int get totalCollected; int get outstandingAmount; int get totalLendFinanced; int get totalLendCollected; int get totalSaleFinanced; int get totalSaleCollected;
/// Create a copy of Outstanding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutstandingCopyWith<Outstanding> get copyWith => _$OutstandingCopyWithImpl<Outstanding>(this as Outstanding, _$identity);

  /// Serializes this Outstanding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Outstanding&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.totalFinanced, totalFinanced) || other.totalFinanced == totalFinanced)&&(identical(other.totalCollected, totalCollected) || other.totalCollected == totalCollected)&&(identical(other.outstandingAmount, outstandingAmount) || other.outstandingAmount == outstandingAmount)&&(identical(other.totalLendFinanced, totalLendFinanced) || other.totalLendFinanced == totalLendFinanced)&&(identical(other.totalLendCollected, totalLendCollected) || other.totalLendCollected == totalLendCollected)&&(identical(other.totalSaleFinanced, totalSaleFinanced) || other.totalSaleFinanced == totalSaleFinanced)&&(identical(other.totalSaleCollected, totalSaleCollected) || other.totalSaleCollected == totalSaleCollected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customerId,totalFinanced,totalCollected,outstandingAmount,totalLendFinanced,totalLendCollected,totalSaleFinanced,totalSaleCollected);

@override
String toString() {
  return 'Outstanding(customerId: $customerId, totalFinanced: $totalFinanced, totalCollected: $totalCollected, outstandingAmount: $outstandingAmount, totalLendFinanced: $totalLendFinanced, totalLendCollected: $totalLendCollected, totalSaleFinanced: $totalSaleFinanced, totalSaleCollected: $totalSaleCollected)';
}


}

/// @nodoc
abstract mixin class $OutstandingCopyWith<$Res>  {
  factory $OutstandingCopyWith(Outstanding value, $Res Function(Outstanding) _then) = _$OutstandingCopyWithImpl;
@useResult
$Res call({
 String customerId, int totalFinanced, int totalCollected, int outstandingAmount, int totalLendFinanced, int totalLendCollected, int totalSaleFinanced, int totalSaleCollected
});




}
/// @nodoc
class _$OutstandingCopyWithImpl<$Res>
    implements $OutstandingCopyWith<$Res> {
  _$OutstandingCopyWithImpl(this._self, this._then);

  final Outstanding _self;
  final $Res Function(Outstanding) _then;

/// Create a copy of Outstanding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? totalFinanced = null,Object? totalCollected = null,Object? outstandingAmount = null,Object? totalLendFinanced = null,Object? totalLendCollected = null,Object? totalSaleFinanced = null,Object? totalSaleCollected = null,}) {
  return _then(Outstanding(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,totalFinanced: null == totalFinanced ? _self.totalFinanced : totalFinanced // ignore: cast_nullable_to_non_nullable
as int,totalCollected: null == totalCollected ? _self.totalCollected : totalCollected // ignore: cast_nullable_to_non_nullable
as int,outstandingAmount: null == outstandingAmount ? _self.outstandingAmount : outstandingAmount // ignore: cast_nullable_to_non_nullable
as int,totalLendFinanced: null == totalLendFinanced ? _self.totalLendFinanced : totalLendFinanced // ignore: cast_nullable_to_non_nullable
as int,totalLendCollected: null == totalLendCollected ? _self.totalLendCollected : totalLendCollected // ignore: cast_nullable_to_non_nullable
as int,totalSaleFinanced: null == totalSaleFinanced ? _self.totalSaleFinanced : totalSaleFinanced // ignore: cast_nullable_to_non_nullable
as int,totalSaleCollected: null == totalSaleCollected ? _self.totalSaleCollected : totalSaleCollected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Outstanding].
extension OutstandingPatterns on Outstanding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Outstanding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Outstanding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Outstanding value)  $default,){
final _that = this;
switch (_that) {
case _Outstanding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Outstanding value)?  $default,){
final _that = this;
switch (_that) {
case _Outstanding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String customerId,  int totalFinanced,  int totalCollected,  int outstandingAmount,  int totalLendFinanced,  int totalLendCollected,  int totalSaleFinanced,  int totalSaleCollected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Outstanding() when $default != null:
return $default(_that.customerId,_that.totalFinanced,_that.totalCollected,_that.outstandingAmount,_that.totalLendFinanced,_that.totalLendCollected,_that.totalSaleFinanced,_that.totalSaleCollected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String customerId,  int totalFinanced,  int totalCollected,  int outstandingAmount,  int totalLendFinanced,  int totalLendCollected,  int totalSaleFinanced,  int totalSaleCollected)  $default,) {final _that = this;
switch (_that) {
case _Outstanding():
return $default(_that.customerId,_that.totalFinanced,_that.totalCollected,_that.outstandingAmount,_that.totalLendFinanced,_that.totalLendCollected,_that.totalSaleFinanced,_that.totalSaleCollected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String customerId,  int totalFinanced,  int totalCollected,  int outstandingAmount,  int totalLendFinanced,  int totalLendCollected,  int totalSaleFinanced,  int totalSaleCollected)?  $default,) {final _that = this;
switch (_that) {
case _Outstanding() when $default != null:
return $default(_that.customerId,_that.totalFinanced,_that.totalCollected,_that.outstandingAmount,_that.totalLendFinanced,_that.totalLendCollected,_that.totalSaleFinanced,_that.totalSaleCollected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Outstanding extends Outstanding {
  const _Outstanding({required this.customerId, required this.totalFinanced, required this.totalCollected, required this.outstandingAmount, this.totalLendFinanced = 0, this.totalLendCollected = 0, this.totalSaleFinanced = 0, this.totalSaleCollected = 0}): super._();
  factory _Outstanding.fromJson(Map<String, dynamic> json) => _$OutstandingFromJson(json);

@override final  String customerId;
@override final  int totalFinanced;
@override final  int totalCollected;
@override final  int outstandingAmount;
@override@JsonKey() final  int totalLendFinanced;
@override@JsonKey() final  int totalLendCollected;
@override@JsonKey() final  int totalSaleFinanced;
@override@JsonKey() final  int totalSaleCollected;

/// Create a copy of Outstanding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutstandingCopyWith<_Outstanding> get copyWith => __$OutstandingCopyWithImpl<_Outstanding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutstandingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Outstanding&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.totalFinanced, totalFinanced) || other.totalFinanced == totalFinanced)&&(identical(other.totalCollected, totalCollected) || other.totalCollected == totalCollected)&&(identical(other.outstandingAmount, outstandingAmount) || other.outstandingAmount == outstandingAmount)&&(identical(other.totalLendFinanced, totalLendFinanced) || other.totalLendFinanced == totalLendFinanced)&&(identical(other.totalLendCollected, totalLendCollected) || other.totalLendCollected == totalLendCollected)&&(identical(other.totalSaleFinanced, totalSaleFinanced) || other.totalSaleFinanced == totalSaleFinanced)&&(identical(other.totalSaleCollected, totalSaleCollected) || other.totalSaleCollected == totalSaleCollected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customerId,totalFinanced,totalCollected,outstandingAmount,totalLendFinanced,totalLendCollected,totalSaleFinanced,totalSaleCollected);

@override
String toString() {
  return 'Outstanding(customerId: $customerId, totalFinanced: $totalFinanced, totalCollected: $totalCollected, outstandingAmount: $outstandingAmount, totalLendFinanced: $totalLendFinanced, totalLendCollected: $totalLendCollected, totalSaleFinanced: $totalSaleFinanced, totalSaleCollected: $totalSaleCollected)';
}


}

/// @nodoc
abstract mixin class _$OutstandingCopyWith<$Res> implements $OutstandingCopyWith<$Res> {
  factory _$OutstandingCopyWith(_Outstanding value, $Res Function(_Outstanding) _then) = __$OutstandingCopyWithImpl;
@override @useResult
$Res call({
 String customerId, int totalFinanced, int totalCollected, int outstandingAmount, int totalLendFinanced, int totalLendCollected, int totalSaleFinanced, int totalSaleCollected
});




}
/// @nodoc
class __$OutstandingCopyWithImpl<$Res>
    implements _$OutstandingCopyWith<$Res> {
  __$OutstandingCopyWithImpl(this._self, this._then);

  final _Outstanding _self;
  final $Res Function(_Outstanding) _then;

/// Create a copy of Outstanding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? totalFinanced = null,Object? totalCollected = null,Object? outstandingAmount = null,Object? totalLendFinanced = null,Object? totalLendCollected = null,Object? totalSaleFinanced = null,Object? totalSaleCollected = null,}) {
  return _then(_Outstanding(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,totalFinanced: null == totalFinanced ? _self.totalFinanced : totalFinanced // ignore: cast_nullable_to_non_nullable
as int,totalCollected: null == totalCollected ? _self.totalCollected : totalCollected // ignore: cast_nullable_to_non_nullable
as int,outstandingAmount: null == outstandingAmount ? _self.outstandingAmount : outstandingAmount // ignore: cast_nullable_to_non_nullable
as int,totalLendFinanced: null == totalLendFinanced ? _self.totalLendFinanced : totalLendFinanced // ignore: cast_nullable_to_non_nullable
as int,totalLendCollected: null == totalLendCollected ? _self.totalLendCollected : totalLendCollected // ignore: cast_nullable_to_non_nullable
as int,totalSaleFinanced: null == totalSaleFinanced ? _self.totalSaleFinanced : totalSaleFinanced // ignore: cast_nullable_to_non_nullable
as int,totalSaleCollected: null == totalSaleCollected ? _self.totalSaleCollected : totalSaleCollected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
