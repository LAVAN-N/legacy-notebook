// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekday.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Weekday _$WeekdayFromJson(Map<String, dynamic> json) {
  return _Weekday.fromJson(json);
}

/// @nodoc
mixin _$Weekday {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;

  /// Serializes this Weekday to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Weekday
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeekdayCopyWith<Weekday> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeekdayCopyWith<$Res> {
  factory $WeekdayCopyWith(Weekday value, $Res Function(Weekday) then) =
      _$WeekdayCopyWithImpl<$Res, Weekday>;
  @useResult
  $Res call({String id, String name, int sortOrder});
}

/// @nodoc
class _$WeekdayCopyWithImpl<$Res, $Val extends Weekday>
    implements $WeekdayCopyWith<$Res> {
  _$WeekdayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Weekday
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sortOrder = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeekdayImplCopyWith<$Res> implements $WeekdayCopyWith<$Res> {
  factory _$$WeekdayImplCopyWith(
          _$WeekdayImpl value, $Res Function(_$WeekdayImpl) then) =
      __$$WeekdayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, int sortOrder});
}

/// @nodoc
class __$$WeekdayImplCopyWithImpl<$Res>
    extends _$WeekdayCopyWithImpl<$Res, _$WeekdayImpl>
    implements _$$WeekdayImplCopyWith<$Res> {
  __$$WeekdayImplCopyWithImpl(
      _$WeekdayImpl _value, $Res Function(_$WeekdayImpl) _then)
      : super(_value, _then);

  /// Create a copy of Weekday
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sortOrder = null,
  }) {
    return _then(_$WeekdayImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeekdayImpl implements _Weekday {
  const _$WeekdayImpl(
      {required this.id, required this.name, required this.sortOrder});

  factory _$WeekdayImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeekdayImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int sortOrder;

  @override
  String toString() {
    return 'Weekday(id: $id, name: $name, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeekdayImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, sortOrder);

  /// Create a copy of Weekday
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeekdayImplCopyWith<_$WeekdayImpl> get copyWith =>
      __$$WeekdayImplCopyWithImpl<_$WeekdayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeekdayImplToJson(
      this,
    );
  }
}

abstract class _Weekday implements Weekday {
  const factory _Weekday(
      {required final String id,
      required final String name,
      required final int sortOrder}) = _$WeekdayImpl;

  factory _Weekday.fromJson(Map<String, dynamic> json) = _$WeekdayImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get sortOrder;

  /// Create a copy of Weekday
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeekdayImplCopyWith<_$WeekdayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
