// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Sale _$SaleFromJson(Map<String, dynamic> json) {
  return _Sale.fromJson(json);
}

/// @nodoc
mixin _$Sale {
  String get id => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  DateTime get saleDatetime => throw _privateConstructorUsedError;
  String get saleType =>
      throw _privateConstructorUsedError; // 'READY' or 'CREDIT'
  int get totalAmount => throw _privateConstructorUsedError;
  int get advanceAmount => throw _privateConstructorUsedError;
  int get financedAmount =>
      throw _privateConstructorUsedError; // Credit Added: totalAmount - advanceAmount
  String get soldBy => throw _privateConstructorUsedError;
  String? get remarks => throw _privateConstructorUsedError;

  /// Serializes this Sale to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Sale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SaleCopyWith<Sale> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaleCopyWith<$Res> {
  factory $SaleCopyWith(Sale value, $Res Function(Sale) then) =
      _$SaleCopyWithImpl<$Res, Sale>;
  @useResult
  $Res call(
      {String id,
      String customerId,
      DateTime saleDatetime,
      String saleType,
      int totalAmount,
      int advanceAmount,
      int financedAmount,
      String soldBy,
      String? remarks});
}

/// @nodoc
class _$SaleCopyWithImpl<$Res, $Val extends Sale>
    implements $SaleCopyWith<$Res> {
  _$SaleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Sale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? saleDatetime = null,
    Object? saleType = null,
    Object? totalAmount = null,
    Object? advanceAmount = null,
    Object? financedAmount = null,
    Object? soldBy = null,
    Object? remarks = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      saleDatetime: null == saleDatetime
          ? _value.saleDatetime
          : saleDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      saleType: null == saleType
          ? _value.saleType
          : saleType // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as int,
      advanceAmount: null == advanceAmount
          ? _value.advanceAmount
          : advanceAmount // ignore: cast_nullable_to_non_nullable
              as int,
      financedAmount: null == financedAmount
          ? _value.financedAmount
          : financedAmount // ignore: cast_nullable_to_non_nullable
              as int,
      soldBy: null == soldBy
          ? _value.soldBy
          : soldBy // ignore: cast_nullable_to_non_nullable
              as String,
      remarks: freezed == remarks
          ? _value.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SaleImplCopyWith<$Res> implements $SaleCopyWith<$Res> {
  factory _$$SaleImplCopyWith(
          _$SaleImpl value, $Res Function(_$SaleImpl) then) =
      __$$SaleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String customerId,
      DateTime saleDatetime,
      String saleType,
      int totalAmount,
      int advanceAmount,
      int financedAmount,
      String soldBy,
      String? remarks});
}

/// @nodoc
class __$$SaleImplCopyWithImpl<$Res>
    extends _$SaleCopyWithImpl<$Res, _$SaleImpl>
    implements _$$SaleImplCopyWith<$Res> {
  __$$SaleImplCopyWithImpl(_$SaleImpl _value, $Res Function(_$SaleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Sale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? saleDatetime = null,
    Object? saleType = null,
    Object? totalAmount = null,
    Object? advanceAmount = null,
    Object? financedAmount = null,
    Object? soldBy = null,
    Object? remarks = freezed,
  }) {
    return _then(_$SaleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      saleDatetime: null == saleDatetime
          ? _value.saleDatetime
          : saleDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      saleType: null == saleType
          ? _value.saleType
          : saleType // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as int,
      advanceAmount: null == advanceAmount
          ? _value.advanceAmount
          : advanceAmount // ignore: cast_nullable_to_non_nullable
              as int,
      financedAmount: null == financedAmount
          ? _value.financedAmount
          : financedAmount // ignore: cast_nullable_to_non_nullable
              as int,
      soldBy: null == soldBy
          ? _value.soldBy
          : soldBy // ignore: cast_nullable_to_non_nullable
              as String,
      remarks: freezed == remarks
          ? _value.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SaleImpl implements _Sale {
  const _$SaleImpl(
      {required this.id,
      required this.customerId,
      required this.saleDatetime,
      required this.saleType,
      required this.totalAmount,
      required this.advanceAmount,
      required this.financedAmount,
      required this.soldBy,
      this.remarks});

  factory _$SaleImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaleImplFromJson(json);

  @override
  final String id;
  @override
  final String customerId;
  @override
  final DateTime saleDatetime;
  @override
  final String saleType;
// 'READY' or 'CREDIT'
  @override
  final int totalAmount;
  @override
  final int advanceAmount;
  @override
  final int financedAmount;
// Credit Added: totalAmount - advanceAmount
  @override
  final String soldBy;
  @override
  final String? remarks;

  @override
  String toString() {
    return 'Sale(id: $id, customerId: $customerId, saleDatetime: $saleDatetime, saleType: $saleType, totalAmount: $totalAmount, advanceAmount: $advanceAmount, financedAmount: $financedAmount, soldBy: $soldBy, remarks: $remarks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.saleDatetime, saleDatetime) ||
                other.saleDatetime == saleDatetime) &&
            (identical(other.saleType, saleType) ||
                other.saleType == saleType) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.advanceAmount, advanceAmount) ||
                other.advanceAmount == advanceAmount) &&
            (identical(other.financedAmount, financedAmount) ||
                other.financedAmount == financedAmount) &&
            (identical(other.soldBy, soldBy) || other.soldBy == soldBy) &&
            (identical(other.remarks, remarks) || other.remarks == remarks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, customerId, saleDatetime,
      saleType, totalAmount, advanceAmount, financedAmount, soldBy, remarks);

  /// Create a copy of Sale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SaleImplCopyWith<_$SaleImpl> get copyWith =>
      __$$SaleImplCopyWithImpl<_$SaleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaleImplToJson(
      this,
    );
  }
}

abstract class _Sale implements Sale {
  const factory _Sale(
      {required final String id,
      required final String customerId,
      required final DateTime saleDatetime,
      required final String saleType,
      required final int totalAmount,
      required final int advanceAmount,
      required final int financedAmount,
      required final String soldBy,
      final String? remarks}) = _$SaleImpl;

  factory _Sale.fromJson(Map<String, dynamic> json) = _$SaleImpl.fromJson;

  @override
  String get id;
  @override
  String get customerId;
  @override
  DateTime get saleDatetime;
  @override
  String get saleType; // 'READY' or 'CREDIT'
  @override
  int get totalAmount;
  @override
  int get advanceAmount;
  @override
  int get financedAmount; // Credit Added: totalAmount - advanceAmount
  @override
  String get soldBy;
  @override
  String? get remarks;

  /// Create a copy of Sale
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SaleImplCopyWith<_$SaleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
