// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Activity _$ActivityFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'payment':
      return PaymentActivity.fromJson(json);
    case 'partialPayment':
      return PartialPaymentActivity.fromJson(json);
    case 'carryForward':
      return CarryForwardActivity.fromJson(json);
    case 'sale':
      return SaleActivity.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'Activity',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$Activity {
  String get id => throw _privateConstructorUsedError;
  DateTime get at => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String get collectorName => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime at, int amount, String? note,
            String collectorName)
        payment,
    required TResult Function(String id, DateTime at, int amount, String note,
            String collectorName)
        partialPayment,
    required TResult Function(
            String id, DateTime at, String note, String collectorName)
        carryForward,
    required TResult Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)
        sale,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime at, int amount, String? note,
            String collectorName)?
        payment,
    TResult? Function(String id, DateTime at, int amount, String note,
            String collectorName)?
        partialPayment,
    TResult? Function(
            String id, DateTime at, String note, String collectorName)?
        carryForward,
    TResult? Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)?
        sale,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime at, int amount, String? note,
            String collectorName)?
        payment,
    TResult Function(String id, DateTime at, int amount, String note,
            String collectorName)?
        partialPayment,
    TResult Function(String id, DateTime at, String note, String collectorName)?
        carryForward,
    TResult Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)?
        sale,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentActivity value) payment,
    required TResult Function(PartialPaymentActivity value) partialPayment,
    required TResult Function(CarryForwardActivity value) carryForward,
    required TResult Function(SaleActivity value) sale,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentActivity value)? payment,
    TResult? Function(PartialPaymentActivity value)? partialPayment,
    TResult? Function(CarryForwardActivity value)? carryForward,
    TResult? Function(SaleActivity value)? sale,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentActivity value)? payment,
    TResult Function(PartialPaymentActivity value)? partialPayment,
    TResult Function(CarryForwardActivity value)? carryForward,
    TResult Function(SaleActivity value)? sale,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this Activity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityCopyWith<Activity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityCopyWith<$Res> {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) then) =
      _$ActivityCopyWithImpl<$Res, Activity>;
  @useResult
  $Res call({String id, DateTime at, String note, String collectorName});
}

/// @nodoc
class _$ActivityCopyWithImpl<$Res, $Val extends Activity>
    implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? at = null,
    Object? note = null,
    Object? collectorName = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      at: null == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: null == note
          ? _value.note!
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      collectorName: null == collectorName
          ? _value.collectorName
          : collectorName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentActivityImplCopyWith<$Res>
    implements $ActivityCopyWith<$Res> {
  factory _$$PaymentActivityImplCopyWith(_$PaymentActivityImpl value,
          $Res Function(_$PaymentActivityImpl) then) =
      __$$PaymentActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, DateTime at, int amount, String? note, String collectorName});
}

/// @nodoc
class __$$PaymentActivityImplCopyWithImpl<$Res>
    extends _$ActivityCopyWithImpl<$Res, _$PaymentActivityImpl>
    implements _$$PaymentActivityImplCopyWith<$Res> {
  __$$PaymentActivityImplCopyWithImpl(
      _$PaymentActivityImpl _value, $Res Function(_$PaymentActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? at = null,
    Object? amount = null,
    Object? note = freezed,
    Object? collectorName = null,
  }) {
    return _then(_$PaymentActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      at: null == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      collectorName: null == collectorName
          ? _value.collectorName
          : collectorName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentActivityImpl implements PaymentActivity {
  const _$PaymentActivityImpl(
      {required this.id,
      required this.at,
      required this.amount,
      this.note,
      required this.collectorName,
      final String? $type})
      : $type = $type ?? 'payment';

  factory _$PaymentActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentActivityImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime at;
  @override
  final int amount;
  @override
  final String? note;
  @override
  final String collectorName;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'Activity.payment(id: $id, at: $at, amount: $amount, note: $note, collectorName: $collectorName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.at, at) || other.at == at) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.collectorName, collectorName) ||
                other.collectorName == collectorName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, at, amount, note, collectorName);

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentActivityImplCopyWith<_$PaymentActivityImpl> get copyWith =>
      __$$PaymentActivityImplCopyWithImpl<_$PaymentActivityImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime at, int amount, String? note,
            String collectorName)
        payment,
    required TResult Function(String id, DateTime at, int amount, String note,
            String collectorName)
        partialPayment,
    required TResult Function(
            String id, DateTime at, String note, String collectorName)
        carryForward,
    required TResult Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)
        sale,
  }) {
    return payment(id, at, amount, note, collectorName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime at, int amount, String? note,
            String collectorName)?
        payment,
    TResult? Function(String id, DateTime at, int amount, String note,
            String collectorName)?
        partialPayment,
    TResult? Function(
            String id, DateTime at, String note, String collectorName)?
        carryForward,
    TResult? Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)?
        sale,
  }) {
    return payment?.call(id, at, amount, note, collectorName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime at, int amount, String? note,
            String collectorName)?
        payment,
    TResult Function(String id, DateTime at, int amount, String note,
            String collectorName)?
        partialPayment,
    TResult Function(String id, DateTime at, String note, String collectorName)?
        carryForward,
    TResult Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)?
        sale,
    required TResult orElse(),
  }) {
    if (payment != null) {
      return payment(id, at, amount, note, collectorName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentActivity value) payment,
    required TResult Function(PartialPaymentActivity value) partialPayment,
    required TResult Function(CarryForwardActivity value) carryForward,
    required TResult Function(SaleActivity value) sale,
  }) {
    return payment(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentActivity value)? payment,
    TResult? Function(PartialPaymentActivity value)? partialPayment,
    TResult? Function(CarryForwardActivity value)? carryForward,
    TResult? Function(SaleActivity value)? sale,
  }) {
    return payment?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentActivity value)? payment,
    TResult Function(PartialPaymentActivity value)? partialPayment,
    TResult Function(CarryForwardActivity value)? carryForward,
    TResult Function(SaleActivity value)? sale,
    required TResult orElse(),
  }) {
    if (payment != null) {
      return payment(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentActivityImplToJson(
      this,
    );
  }
}

abstract class PaymentActivity implements Activity {
  const factory PaymentActivity(
      {required final String id,
      required final DateTime at,
      required final int amount,
      final String? note,
      required final String collectorName}) = _$PaymentActivityImpl;

  factory PaymentActivity.fromJson(Map<String, dynamic> json) =
      _$PaymentActivityImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get at;
  int get amount;
  @override
  String? get note;
  @override
  String get collectorName;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentActivityImplCopyWith<_$PaymentActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PartialPaymentActivityImplCopyWith<$Res>
    implements $ActivityCopyWith<$Res> {
  factory _$$PartialPaymentActivityImplCopyWith(
          _$PartialPaymentActivityImpl value,
          $Res Function(_$PartialPaymentActivityImpl) then) =
      __$$PartialPaymentActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, DateTime at, int amount, String note, String collectorName});
}

/// @nodoc
class __$$PartialPaymentActivityImplCopyWithImpl<$Res>
    extends _$ActivityCopyWithImpl<$Res, _$PartialPaymentActivityImpl>
    implements _$$PartialPaymentActivityImplCopyWith<$Res> {
  __$$PartialPaymentActivityImplCopyWithImpl(
      _$PartialPaymentActivityImpl _value,
      $Res Function(_$PartialPaymentActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? at = null,
    Object? amount = null,
    Object? note = null,
    Object? collectorName = null,
  }) {
    return _then(_$PartialPaymentActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      at: null == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      collectorName: null == collectorName
          ? _value.collectorName
          : collectorName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PartialPaymentActivityImpl implements PartialPaymentActivity {
  const _$PartialPaymentActivityImpl(
      {required this.id,
      required this.at,
      required this.amount,
      required this.note,
      required this.collectorName,
      final String? $type})
      : $type = $type ?? 'partialPayment';

  factory _$PartialPaymentActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$PartialPaymentActivityImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime at;
  @override
  final int amount;
  @override
  final String note;
  @override
  final String collectorName;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'Activity.partialPayment(id: $id, at: $at, amount: $amount, note: $note, collectorName: $collectorName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartialPaymentActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.at, at) || other.at == at) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.collectorName, collectorName) ||
                other.collectorName == collectorName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, at, amount, note, collectorName);

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartialPaymentActivityImplCopyWith<_$PartialPaymentActivityImpl>
      get copyWith => __$$PartialPaymentActivityImplCopyWithImpl<
          _$PartialPaymentActivityImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime at, int amount, String? note,
            String collectorName)
        payment,
    required TResult Function(String id, DateTime at, int amount, String note,
            String collectorName)
        partialPayment,
    required TResult Function(
            String id, DateTime at, String note, String collectorName)
        carryForward,
    required TResult Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)
        sale,
  }) {
    return partialPayment(id, at, amount, note, collectorName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime at, int amount, String? note,
            String collectorName)?
        payment,
    TResult? Function(String id, DateTime at, int amount, String note,
            String collectorName)?
        partialPayment,
    TResult? Function(
            String id, DateTime at, String note, String collectorName)?
        carryForward,
    TResult? Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)?
        sale,
  }) {
    return partialPayment?.call(id, at, amount, note, collectorName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime at, int amount, String? note,
            String collectorName)?
        payment,
    TResult Function(String id, DateTime at, int amount, String note,
            String collectorName)?
        partialPayment,
    TResult Function(String id, DateTime at, String note, String collectorName)?
        carryForward,
    TResult Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)?
        sale,
    required TResult orElse(),
  }) {
    if (partialPayment != null) {
      return partialPayment(id, at, amount, note, collectorName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentActivity value) payment,
    required TResult Function(PartialPaymentActivity value) partialPayment,
    required TResult Function(CarryForwardActivity value) carryForward,
    required TResult Function(SaleActivity value) sale,
  }) {
    return partialPayment(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentActivity value)? payment,
    TResult? Function(PartialPaymentActivity value)? partialPayment,
    TResult? Function(CarryForwardActivity value)? carryForward,
    TResult? Function(SaleActivity value)? sale,
  }) {
    return partialPayment?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentActivity value)? payment,
    TResult Function(PartialPaymentActivity value)? partialPayment,
    TResult Function(CarryForwardActivity value)? carryForward,
    TResult Function(SaleActivity value)? sale,
    required TResult orElse(),
  }) {
    if (partialPayment != null) {
      return partialPayment(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PartialPaymentActivityImplToJson(
      this,
    );
  }
}

abstract class PartialPaymentActivity implements Activity {
  const factory PartialPaymentActivity(
      {required final String id,
      required final DateTime at,
      required final int amount,
      required final String note,
      required final String collectorName}) = _$PartialPaymentActivityImpl;

  factory PartialPaymentActivity.fromJson(Map<String, dynamic> json) =
      _$PartialPaymentActivityImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get at;
  int get amount;
  @override
  String get note;
  @override
  String get collectorName;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartialPaymentActivityImplCopyWith<_$PartialPaymentActivityImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CarryForwardActivityImplCopyWith<$Res>
    implements $ActivityCopyWith<$Res> {
  factory _$$CarryForwardActivityImplCopyWith(_$CarryForwardActivityImpl value,
          $Res Function(_$CarryForwardActivityImpl) then) =
      __$$CarryForwardActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, DateTime at, String note, String collectorName});
}

/// @nodoc
class __$$CarryForwardActivityImplCopyWithImpl<$Res>
    extends _$ActivityCopyWithImpl<$Res, _$CarryForwardActivityImpl>
    implements _$$CarryForwardActivityImplCopyWith<$Res> {
  __$$CarryForwardActivityImplCopyWithImpl(_$CarryForwardActivityImpl _value,
      $Res Function(_$CarryForwardActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? at = null,
    Object? note = null,
    Object? collectorName = null,
  }) {
    return _then(_$CarryForwardActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      at: null == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      collectorName: null == collectorName
          ? _value.collectorName
          : collectorName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarryForwardActivityImpl implements CarryForwardActivity {
  const _$CarryForwardActivityImpl(
      {required this.id,
      required this.at,
      required this.note,
      required this.collectorName,
      final String? $type})
      : $type = $type ?? 'carryForward';

  factory _$CarryForwardActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarryForwardActivityImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime at;
  @override
  final String note;
  @override
  final String collectorName;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'Activity.carryForward(id: $id, at: $at, note: $note, collectorName: $collectorName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarryForwardActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.at, at) || other.at == at) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.collectorName, collectorName) ||
                other.collectorName == collectorName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, at, note, collectorName);

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarryForwardActivityImplCopyWith<_$CarryForwardActivityImpl>
      get copyWith =>
          __$$CarryForwardActivityImplCopyWithImpl<_$CarryForwardActivityImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime at, int amount, String? note,
            String collectorName)
        payment,
    required TResult Function(String id, DateTime at, int amount, String note,
            String collectorName)
        partialPayment,
    required TResult Function(
            String id, DateTime at, String note, String collectorName)
        carryForward,
    required TResult Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)
        sale,
  }) {
    return carryForward(id, at, note, collectorName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime at, int amount, String? note,
            String collectorName)?
        payment,
    TResult? Function(String id, DateTime at, int amount, String note,
            String collectorName)?
        partialPayment,
    TResult? Function(
            String id, DateTime at, String note, String collectorName)?
        carryForward,
    TResult? Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)?
        sale,
  }) {
    return carryForward?.call(id, at, note, collectorName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime at, int amount, String? note,
            String collectorName)?
        payment,
    TResult Function(String id, DateTime at, int amount, String note,
            String collectorName)?
        partialPayment,
    TResult Function(String id, DateTime at, String note, String collectorName)?
        carryForward,
    TResult Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)?
        sale,
    required TResult orElse(),
  }) {
    if (carryForward != null) {
      return carryForward(id, at, note, collectorName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentActivity value) payment,
    required TResult Function(PartialPaymentActivity value) partialPayment,
    required TResult Function(CarryForwardActivity value) carryForward,
    required TResult Function(SaleActivity value) sale,
  }) {
    return carryForward(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentActivity value)? payment,
    TResult? Function(PartialPaymentActivity value)? partialPayment,
    TResult? Function(CarryForwardActivity value)? carryForward,
    TResult? Function(SaleActivity value)? sale,
  }) {
    return carryForward?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentActivity value)? payment,
    TResult Function(PartialPaymentActivity value)? partialPayment,
    TResult Function(CarryForwardActivity value)? carryForward,
    TResult Function(SaleActivity value)? sale,
    required TResult orElse(),
  }) {
    if (carryForward != null) {
      return carryForward(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CarryForwardActivityImplToJson(
      this,
    );
  }
}

abstract class CarryForwardActivity implements Activity {
  const factory CarryForwardActivity(
      {required final String id,
      required final DateTime at,
      required final String note,
      required final String collectorName}) = _$CarryForwardActivityImpl;

  factory CarryForwardActivity.fromJson(Map<String, dynamic> json) =
      _$CarryForwardActivityImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get at;
  @override
  String get note;
  @override
  String get collectorName;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarryForwardActivityImplCopyWith<_$CarryForwardActivityImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SaleActivityImplCopyWith<$Res>
    implements $ActivityCopyWith<$Res> {
  factory _$$SaleActivityImplCopyWith(
          _$SaleActivityImpl value, $Res Function(_$SaleActivityImpl) then) =
      __$$SaleActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime at,
      List<SaleItemDetail> items,
      int total,
      int advance,
      int creditAdded,
      String saleType,
      String collectorName,
      String? note});
}

/// @nodoc
class __$$SaleActivityImplCopyWithImpl<$Res>
    extends _$ActivityCopyWithImpl<$Res, _$SaleActivityImpl>
    implements _$$SaleActivityImplCopyWith<$Res> {
  __$$SaleActivityImplCopyWithImpl(
      _$SaleActivityImpl _value, $Res Function(_$SaleActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? at = null,
    Object? items = null,
    Object? total = null,
    Object? advance = null,
    Object? creditAdded = null,
    Object? saleType = null,
    Object? collectorName = null,
    Object? note = freezed,
  }) {
    return _then(_$SaleActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      at: null == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SaleItemDetail>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      advance: null == advance
          ? _value.advance
          : advance // ignore: cast_nullable_to_non_nullable
              as int,
      creditAdded: null == creditAdded
          ? _value.creditAdded
          : creditAdded // ignore: cast_nullable_to_non_nullable
              as int,
      saleType: null == saleType
          ? _value.saleType
          : saleType // ignore: cast_nullable_to_non_nullable
              as String,
      collectorName: null == collectorName
          ? _value.collectorName
          : collectorName // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SaleActivityImpl implements SaleActivity {
  const _$SaleActivityImpl(
      {required this.id,
      required this.at,
      required final List<SaleItemDetail> items,
      required this.total,
      required this.advance,
      required this.creditAdded,
      required this.saleType,
      required this.collectorName,
      this.note,
      final String? $type})
      : _items = items,
        $type = $type ?? 'sale';

  factory _$SaleActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaleActivityImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime at;
  final List<SaleItemDetail> _items;
  @override
  List<SaleItemDetail> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int total;
  @override
  final int advance;
  @override
  final int creditAdded;
  @override
  final String saleType;
// READY or CREDIT
  @override
  final String collectorName;
  @override
  final String? note;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'Activity.sale(id: $id, at: $at, items: $items, total: $total, advance: $advance, creditAdded: $creditAdded, saleType: $saleType, collectorName: $collectorName, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaleActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.at, at) || other.at == at) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.advance, advance) || other.advance == advance) &&
            (identical(other.creditAdded, creditAdded) ||
                other.creditAdded == creditAdded) &&
            (identical(other.saleType, saleType) ||
                other.saleType == saleType) &&
            (identical(other.collectorName, collectorName) ||
                other.collectorName == collectorName) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      at,
      const DeepCollectionEquality().hash(_items),
      total,
      advance,
      creditAdded,
      saleType,
      collectorName,
      note);

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SaleActivityImplCopyWith<_$SaleActivityImpl> get copyWith =>
      __$$SaleActivityImplCopyWithImpl<_$SaleActivityImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, DateTime at, int amount, String? note,
            String collectorName)
        payment,
    required TResult Function(String id, DateTime at, int amount, String note,
            String collectorName)
        partialPayment,
    required TResult Function(
            String id, DateTime at, String note, String collectorName)
        carryForward,
    required TResult Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)
        sale,
  }) {
    return sale(id, at, items, total, advance, creditAdded, saleType,
        collectorName, note);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, DateTime at, int amount, String? note,
            String collectorName)?
        payment,
    TResult? Function(String id, DateTime at, int amount, String note,
            String collectorName)?
        partialPayment,
    TResult? Function(
            String id, DateTime at, String note, String collectorName)?
        carryForward,
    TResult? Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)?
        sale,
  }) {
    return sale?.call(id, at, items, total, advance, creditAdded, saleType,
        collectorName, note);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, DateTime at, int amount, String? note,
            String collectorName)?
        payment,
    TResult Function(String id, DateTime at, int amount, String note,
            String collectorName)?
        partialPayment,
    TResult Function(String id, DateTime at, String note, String collectorName)?
        carryForward,
    TResult Function(
            String id,
            DateTime at,
            List<SaleItemDetail> items,
            int total,
            int advance,
            int creditAdded,
            String saleType,
            String collectorName,
            String? note)?
        sale,
    required TResult orElse(),
  }) {
    if (sale != null) {
      return sale(id, at, items, total, advance, creditAdded, saleType,
          collectorName, note);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PaymentActivity value) payment,
    required TResult Function(PartialPaymentActivity value) partialPayment,
    required TResult Function(CarryForwardActivity value) carryForward,
    required TResult Function(SaleActivity value) sale,
  }) {
    return sale(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PaymentActivity value)? payment,
    TResult? Function(PartialPaymentActivity value)? partialPayment,
    TResult? Function(CarryForwardActivity value)? carryForward,
    TResult? Function(SaleActivity value)? sale,
  }) {
    return sale?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PaymentActivity value)? payment,
    TResult Function(PartialPaymentActivity value)? partialPayment,
    TResult Function(CarryForwardActivity value)? carryForward,
    TResult Function(SaleActivity value)? sale,
    required TResult orElse(),
  }) {
    if (sale != null) {
      return sale(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SaleActivityImplToJson(
      this,
    );
  }
}

abstract class SaleActivity implements Activity {
  const factory SaleActivity(
      {required final String id,
      required final DateTime at,
      required final List<SaleItemDetail> items,
      required final int total,
      required final int advance,
      required final int creditAdded,
      required final String saleType,
      required final String collectorName,
      final String? note}) = _$SaleActivityImpl;

  factory SaleActivity.fromJson(Map<String, dynamic> json) =
      _$SaleActivityImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get at;
  List<SaleItemDetail> get items;
  int get total;
  int get advance;
  int get creditAdded;
  String get saleType; // READY or CREDIT
  @override
  String get collectorName;
  @override
  String? get note;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SaleActivityImplCopyWith<_$SaleActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SaleItemDetail _$SaleItemDetailFromJson(Map<String, dynamic> json) {
  return _SaleItemDetail.fromJson(json);
}

/// @nodoc
mixin _$SaleItemDetail {
  String get productName => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  int get unitPrice => throw _privateConstructorUsedError;

  /// Serializes this SaleItemDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SaleItemDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SaleItemDetailCopyWith<SaleItemDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaleItemDetailCopyWith<$Res> {
  factory $SaleItemDetailCopyWith(
          SaleItemDetail value, $Res Function(SaleItemDetail) then) =
      _$SaleItemDetailCopyWithImpl<$Res, SaleItemDetail>;
  @useResult
  $Res call({String productName, int quantity, int unitPrice});
}

/// @nodoc
class _$SaleItemDetailCopyWithImpl<$Res, $Val extends SaleItemDetail>
    implements $SaleItemDetailCopyWith<$Res> {
  _$SaleItemDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SaleItemDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productName = null,
    Object? quantity = null,
    Object? unitPrice = null,
  }) {
    return _then(_value.copyWith(
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SaleItemDetailImplCopyWith<$Res>
    implements $SaleItemDetailCopyWith<$Res> {
  factory _$$SaleItemDetailImplCopyWith(_$SaleItemDetailImpl value,
          $Res Function(_$SaleItemDetailImpl) then) =
      __$$SaleItemDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String productName, int quantity, int unitPrice});
}

/// @nodoc
class __$$SaleItemDetailImplCopyWithImpl<$Res>
    extends _$SaleItemDetailCopyWithImpl<$Res, _$SaleItemDetailImpl>
    implements _$$SaleItemDetailImplCopyWith<$Res> {
  __$$SaleItemDetailImplCopyWithImpl(
      _$SaleItemDetailImpl _value, $Res Function(_$SaleItemDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of SaleItemDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productName = null,
    Object? quantity = null,
    Object? unitPrice = null,
  }) {
    return _then(_$SaleItemDetailImpl(
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SaleItemDetailImpl implements _SaleItemDetail {
  const _$SaleItemDetailImpl(
      {required this.productName,
      required this.quantity,
      required this.unitPrice});

  factory _$SaleItemDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaleItemDetailImplFromJson(json);

  @override
  final String productName;
  @override
  final int quantity;
  @override
  final int unitPrice;

  @override
  String toString() {
    return 'SaleItemDetail(productName: $productName, quantity: $quantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaleItemDetailImpl &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, productName, quantity, unitPrice);

  /// Create a copy of SaleItemDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SaleItemDetailImplCopyWith<_$SaleItemDetailImpl> get copyWith =>
      __$$SaleItemDetailImplCopyWithImpl<_$SaleItemDetailImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaleItemDetailImplToJson(
      this,
    );
  }
}

abstract class _SaleItemDetail implements SaleItemDetail {
  const factory _SaleItemDetail(
      {required final String productName,
      required final int quantity,
      required final int unitPrice}) = _$SaleItemDetailImpl;

  factory _SaleItemDetail.fromJson(Map<String, dynamic> json) =
      _$SaleItemDetailImpl.fromJson;

  @override
  String get productName;
  @override
  int get quantity;
  @override
  int get unitPrice;

  /// Create a copy of SaleItemDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SaleItemDetailImplCopyWith<_$SaleItemDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
