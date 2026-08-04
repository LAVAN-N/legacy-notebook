// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outstanding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Outstanding _$OutstandingFromJson(Map<String, dynamic> json) {
  return _Outstanding.fromJson(json);
}

/// @nodoc
mixin _$Outstanding {
  String get customerId => throw _privateConstructorUsedError;
  int get totalFinanced => throw _privateConstructorUsedError;
  int get totalCollected => throw _privateConstructorUsedError;
  int get outstandingAmount =>
      throw _privateConstructorUsedError; // totalFinanced - totalCollected
  int get totalLendFinanced => throw _privateConstructorUsedError;
  int get totalLendCollected => throw _privateConstructorUsedError;
  int get totalSaleFinanced => throw _privateConstructorUsedError;
  int get totalSaleCollected => throw _privateConstructorUsedError;

  /// Serializes this Outstanding to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Outstanding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OutstandingCopyWith<Outstanding> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutstandingCopyWith<$Res> {
  factory $OutstandingCopyWith(
          Outstanding value, $Res Function(Outstanding) then) =
      _$OutstandingCopyWithImpl<$Res, Outstanding>;
  @useResult
  $Res call(
      {String customerId,
      int totalFinanced,
      int totalCollected,
      int outstandingAmount,
      int totalLendFinanced,
      int totalLendCollected,
      int totalSaleFinanced,
      int totalSaleCollected});
}

/// @nodoc
class _$OutstandingCopyWithImpl<$Res, $Val extends Outstanding>
    implements $OutstandingCopyWith<$Res> {
  _$OutstandingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Outstanding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? totalFinanced = null,
    Object? totalCollected = null,
    Object? outstandingAmount = null,
    Object? totalLendFinanced = null,
    Object? totalLendCollected = null,
    Object? totalSaleFinanced = null,
    Object? totalSaleCollected = null,
  }) {
    return _then(_value.copyWith(
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      totalFinanced: null == totalFinanced
          ? _value.totalFinanced
          : totalFinanced // ignore: cast_nullable_to_non_nullable
              as int,
      totalCollected: null == totalCollected
          ? _value.totalCollected
          : totalCollected // ignore: cast_nullable_to_non_nullable
              as int,
      outstandingAmount: null == outstandingAmount
          ? _value.outstandingAmount
          : outstandingAmount // ignore: cast_nullable_to_non_nullable
              as int,
      totalLendFinanced: null == totalLendFinanced
          ? _value.totalLendFinanced
          : totalLendFinanced // ignore: cast_nullable_to_non_nullable
              as int,
      totalLendCollected: null == totalLendCollected
          ? _value.totalLendCollected
          : totalLendCollected // ignore: cast_nullable_to_non_nullable
              as int,
      totalSaleFinanced: null == totalSaleFinanced
          ? _value.totalSaleFinanced
          : totalSaleFinanced // ignore: cast_nullable_to_non_nullable
              as int,
      totalSaleCollected: null == totalSaleCollected
          ? _value.totalSaleCollected
          : totalSaleCollected // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OutstandingImplCopyWith<$Res>
    implements $OutstandingCopyWith<$Res> {
  factory _$$OutstandingImplCopyWith(
          _$OutstandingImpl value, $Res Function(_$OutstandingImpl) then) =
      __$$OutstandingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String customerId,
      int totalFinanced,
      int totalCollected,
      int outstandingAmount,
      int totalLendFinanced,
      int totalLendCollected,
      int totalSaleFinanced,
      int totalSaleCollected});
}

/// @nodoc
class __$$OutstandingImplCopyWithImpl<$Res>
    extends _$OutstandingCopyWithImpl<$Res, _$OutstandingImpl>
    implements _$$OutstandingImplCopyWith<$Res> {
  __$$OutstandingImplCopyWithImpl(
      _$OutstandingImpl _value, $Res Function(_$OutstandingImpl) _then)
      : super(_value, _then);

  /// Create a copy of Outstanding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? totalFinanced = null,
    Object? totalCollected = null,
    Object? outstandingAmount = null,
    Object? totalLendFinanced = null,
    Object? totalLendCollected = null,
    Object? totalSaleFinanced = null,
    Object? totalSaleCollected = null,
  }) {
    return _then(_$OutstandingImpl(
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      totalFinanced: null == totalFinanced
          ? _value.totalFinanced
          : totalFinanced // ignore: cast_nullable_to_non_nullable
              as int,
      totalCollected: null == totalCollected
          ? _value.totalCollected
          : totalCollected // ignore: cast_nullable_to_non_nullable
              as int,
      outstandingAmount: null == outstandingAmount
          ? _value.outstandingAmount
          : outstandingAmount // ignore: cast_nullable_to_non_nullable
              as int,
      totalLendFinanced: null == totalLendFinanced
          ? _value.totalLendFinanced
          : totalLendFinanced // ignore: cast_nullable_to_non_nullable
              as int,
      totalLendCollected: null == totalLendCollected
          ? _value.totalLendCollected
          : totalLendCollected // ignore: cast_nullable_to_non_nullable
              as int,
      totalSaleFinanced: null == totalSaleFinanced
          ? _value.totalSaleFinanced
          : totalSaleFinanced // ignore: cast_nullable_to_non_nullable
              as int,
      totalSaleCollected: null == totalSaleCollected
          ? _value.totalSaleCollected
          : totalSaleCollected // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OutstandingImpl extends _Outstanding {
  const _$OutstandingImpl(
      {required this.customerId,
      required this.totalFinanced,
      required this.totalCollected,
      required this.outstandingAmount,
      this.totalLendFinanced = 0,
      this.totalLendCollected = 0,
      this.totalSaleFinanced = 0,
      this.totalSaleCollected = 0})
      : super._();

  factory _$OutstandingImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutstandingImplFromJson(json);

  @override
  final String customerId;
  @override
  final int totalFinanced;
  @override
  final int totalCollected;
  @override
  final int outstandingAmount;
// totalFinanced - totalCollected
  @override
  @JsonKey()
  final int totalLendFinanced;
  @override
  @JsonKey()
  final int totalLendCollected;
  @override
  @JsonKey()
  final int totalSaleFinanced;
  @override
  @JsonKey()
  final int totalSaleCollected;

  @override
  String toString() {
    return 'Outstanding(customerId: $customerId, totalFinanced: $totalFinanced, totalCollected: $totalCollected, outstandingAmount: $outstandingAmount, totalLendFinanced: $totalLendFinanced, totalLendCollected: $totalLendCollected, totalSaleFinanced: $totalSaleFinanced, totalSaleCollected: $totalSaleCollected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutstandingImpl &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.totalFinanced, totalFinanced) ||
                other.totalFinanced == totalFinanced) &&
            (identical(other.totalCollected, totalCollected) ||
                other.totalCollected == totalCollected) &&
            (identical(other.outstandingAmount, outstandingAmount) ||
                other.outstandingAmount == outstandingAmount) &&
            (identical(other.totalLendFinanced, totalLendFinanced) ||
                other.totalLendFinanced == totalLendFinanced) &&
            (identical(other.totalLendCollected, totalLendCollected) ||
                other.totalLendCollected == totalLendCollected) &&
            (identical(other.totalSaleFinanced, totalSaleFinanced) ||
                other.totalSaleFinanced == totalSaleFinanced) &&
            (identical(other.totalSaleCollected, totalSaleCollected) ||
                other.totalSaleCollected == totalSaleCollected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      customerId,
      totalFinanced,
      totalCollected,
      outstandingAmount,
      totalLendFinanced,
      totalLendCollected,
      totalSaleFinanced,
      totalSaleCollected);

  /// Create a copy of Outstanding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OutstandingImplCopyWith<_$OutstandingImpl> get copyWith =>
      __$$OutstandingImplCopyWithImpl<_$OutstandingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutstandingImplToJson(
      this,
    );
  }
}

abstract class _Outstanding extends Outstanding {
  const factory _Outstanding(
      {required final String customerId,
      required final int totalFinanced,
      required final int totalCollected,
      required final int outstandingAmount,
      final int totalLendFinanced,
      final int totalLendCollected,
      final int totalSaleFinanced,
      final int totalSaleCollected}) = _$OutstandingImpl;
  const _Outstanding._() : super._();

  factory _Outstanding.fromJson(Map<String, dynamic> json) =
      _$OutstandingImpl.fromJson;

  @override
  String get customerId;
  @override
  int get totalFinanced;
  @override
  int get totalCollected;
  @override
  int get outstandingAmount; // totalFinanced - totalCollected
  @override
  int get totalLendFinanced;
  @override
  int get totalLendCollected;
  @override
  int get totalSaleFinanced;
  @override
  int get totalSaleCollected;

  /// Create a copy of Outstanding
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OutstandingImplCopyWith<_$OutstandingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
