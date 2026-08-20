// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekday.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Weekday {

 String get id; String get name; int get sortOrder;
/// Create a copy of Weekday
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeekdayCopyWith<Weekday> get copyWith => _$WeekdayCopyWithImpl<Weekday>(this as Weekday, _$identity);

  /// Serializes this Weekday to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Weekday&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sortOrder);

@override
String toString() {
  return 'Weekday(id: $id, name: $name, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $WeekdayCopyWith<$Res>  {
  factory $WeekdayCopyWith(Weekday value, $Res Function(Weekday) _then) = _$WeekdayCopyWithImpl;
@useResult
$Res call({
 String id, String name, int sortOrder
});




}
/// @nodoc
class _$WeekdayCopyWithImpl<$Res>
    implements $WeekdayCopyWith<$Res> {
  _$WeekdayCopyWithImpl(this._self, this._then);

  final Weekday _self;
  final $Res Function(Weekday) _then;

/// Create a copy of Weekday
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sortOrder = null,}) {
  return _then(Weekday(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Weekday].
extension WeekdayPatterns on Weekday {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Weekday value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Weekday() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Weekday value)  $default,){
final _that = this;
switch (_that) {
case _Weekday():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Weekday value)?  $default,){
final _that = this;
switch (_that) {
case _Weekday() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Weekday() when $default != null:
return $default(_that.id,_that.name,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _Weekday():
return $default(_that.id,_that.name,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _Weekday() when $default != null:
return $default(_that.id,_that.name,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Weekday implements Weekday {
  const _Weekday({required this.id, required this.name, required this.sortOrder});
  factory _Weekday.fromJson(Map<String, dynamic> json) => _$WeekdayFromJson(json);

@override final  String id;
@override final  String name;
@override final  int sortOrder;

/// Create a copy of Weekday
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeekdayCopyWith<_Weekday> get copyWith => __$WeekdayCopyWithImpl<_Weekday>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeekdayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Weekday&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sortOrder);

@override
String toString() {
  return 'Weekday(id: $id, name: $name, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$WeekdayCopyWith<$Res> implements $WeekdayCopyWith<$Res> {
  factory _$WeekdayCopyWith(_Weekday value, $Res Function(_Weekday) _then) = __$WeekdayCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int sortOrder
});




}
/// @nodoc
class __$WeekdayCopyWithImpl<$Res>
    implements _$WeekdayCopyWith<$Res> {
  __$WeekdayCopyWithImpl(this._self, this._then);

  final _Weekday _self;
  final $Res Function(_Weekday) _then;

/// Create a copy of Weekday
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sortOrder = null,}) {
  return _then(_Weekday(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
