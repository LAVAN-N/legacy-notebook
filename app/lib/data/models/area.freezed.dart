// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'area.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Area _$AreaFromJson(Map<String, dynamic> json) {
  return _Area.fromJson(json);
}

/// @nodoc
mixin _$Area {
  String get id => throw _privateConstructorUsedError;
  String get placeId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this Area to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Area
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AreaCopyWith<Area> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AreaCopyWith<$Res> {
  factory $AreaCopyWith(Area value, $Res Function(Area) then) =
      _$AreaCopyWithImpl<$Res, Area>;
  @useResult
  $Res call({String id, String placeId, String name});
}

/// @nodoc
class _$AreaCopyWithImpl<$Res, $Val extends Area>
    implements $AreaCopyWith<$Res> {
  _$AreaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Area
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? placeId = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      placeId: null == placeId
          ? _value.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AreaImplCopyWith<$Res> implements $AreaCopyWith<$Res> {
  factory _$$AreaImplCopyWith(
          _$AreaImpl value, $Res Function(_$AreaImpl) then) =
      __$$AreaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String placeId, String name});
}

/// @nodoc
class __$$AreaImplCopyWithImpl<$Res>
    extends _$AreaCopyWithImpl<$Res, _$AreaImpl>
    implements _$$AreaImplCopyWith<$Res> {
  __$$AreaImplCopyWithImpl(_$AreaImpl _value, $Res Function(_$AreaImpl) _then)
      : super(_value, _then);

  /// Create a copy of Area
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? placeId = null,
    Object? name = null,
  }) {
    return _then(_$AreaImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      placeId: null == placeId
          ? _value.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AreaImpl implements _Area {
  const _$AreaImpl(
      {required this.id, required this.placeId, required this.name});

  factory _$AreaImpl.fromJson(Map<String, dynamic> json) =>
      _$$AreaImplFromJson(json);

  @override
  final String id;
  @override
  final String placeId;
  @override
  final String name;

  @override
  String toString() {
    return 'Area(id: $id, placeId: $placeId, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AreaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, placeId, name);

  /// Create a copy of Area
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AreaImplCopyWith<_$AreaImpl> get copyWith =>
      __$$AreaImplCopyWithImpl<_$AreaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AreaImplToJson(
      this,
    );
  }
}

abstract class _Area implements Area {
  const factory _Area(
      {required final String id,
      required final String placeId,
      required final String name}) = _$AreaImpl;

  factory _Area.fromJson(Map<String, dynamic> json) = _$AreaImpl.fromJson;

  @override
  String get id;
  @override
  String get placeId;
  @override
  String get name;

  /// Create a copy of Area
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AreaImplCopyWith<_$AreaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
