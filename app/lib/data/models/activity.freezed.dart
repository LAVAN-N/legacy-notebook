// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
Activity _$ActivityFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'payment':
          return PaymentActivity.fromJson(
            json
          );
                case 'partialPayment':
          return PartialPaymentActivity.fromJson(
            json
          );
                case 'carryForward':
          return CarryForwardActivity.fromJson(
            json
          );
                case 'sale':
          return SaleActivity.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'Activity',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$Activity {

 String get id; DateTime get at; String? get note; String get collectorName;
/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityCopyWith<Activity> get copyWith => _$ActivityCopyWithImpl<Activity>(this as Activity, _$identity);

  /// Serializes this Activity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Activity&&(identical(other.id, id) || other.id == id)&&(identical(other.at, at) || other.at == at)&&(identical(other.note, note) || other.note == note)&&(identical(other.collectorName, collectorName) || other.collectorName == collectorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,at,note,collectorName);

@override
String toString() {
  return 'Activity(id: $id, at: $at, note: $note, collectorName: $collectorName)';
}


}

/// @nodoc
abstract mixin class $ActivityCopyWith<$Res>  {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) _then) = _$ActivityCopyWithImpl;
@useResult
$Res call({
 String id, DateTime at, String note, String collectorName
});




}
/// @nodoc
class _$ActivityCopyWithImpl<$Res>
    implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._self, this._then);

  final Activity _self;
  final $Res Function(Activity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? at = null,Object? note = null,Object? collectorName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note! : note // ignore: cast_nullable_to_non_nullable
as String,collectorName: null == collectorName ? _self.collectorName : collectorName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Activity].
extension ActivityPatterns on Activity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PaymentActivity value)?  payment,TResult Function( PartialPaymentActivity value)?  partialPayment,TResult Function( CarryForwardActivity value)?  carryForward,TResult Function( SaleActivity value)?  sale,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PaymentActivity() when payment != null:
return payment(_that);case PartialPaymentActivity() when partialPayment != null:
return partialPayment(_that);case CarryForwardActivity() when carryForward != null:
return carryForward(_that);case SaleActivity() when sale != null:
return sale(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PaymentActivity value)  payment,required TResult Function( PartialPaymentActivity value)  partialPayment,required TResult Function( CarryForwardActivity value)  carryForward,required TResult Function( SaleActivity value)  sale,}){
final _that = this;
switch (_that) {
case PaymentActivity():
return payment(_that);case PartialPaymentActivity():
return partialPayment(_that);case CarryForwardActivity():
return carryForward(_that);case SaleActivity():
return sale(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PaymentActivity value)?  payment,TResult? Function( PartialPaymentActivity value)?  partialPayment,TResult? Function( CarryForwardActivity value)?  carryForward,TResult? Function( SaleActivity value)?  sale,}){
final _that = this;
switch (_that) {
case PaymentActivity() when payment != null:
return payment(_that);case PartialPaymentActivity() when partialPayment != null:
return partialPayment(_that);case CarryForwardActivity() when carryForward != null:
return carryForward(_that);case SaleActivity() when sale != null:
return sale(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  DateTime at,  int amount,  String? note,  String collectorName)?  payment,TResult Function( String id,  DateTime at,  int amount,  String note,  String collectorName)?  partialPayment,TResult Function( String id,  DateTime at,  String note,  String collectorName)?  carryForward,TResult Function( String id,  DateTime at,  List<SaleItemDetail> items,  int total,  int advance,  int creditAdded,  String saleType,  String collectorName,  String? note)?  sale,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PaymentActivity() when payment != null:
return payment(_that.id,_that.at,_that.amount,_that.note,_that.collectorName);case PartialPaymentActivity() when partialPayment != null:
return partialPayment(_that.id,_that.at,_that.amount,_that.note,_that.collectorName);case CarryForwardActivity() when carryForward != null:
return carryForward(_that.id,_that.at,_that.note,_that.collectorName);case SaleActivity() when sale != null:
return sale(_that.id,_that.at,_that.items,_that.total,_that.advance,_that.creditAdded,_that.saleType,_that.collectorName,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  DateTime at,  int amount,  String? note,  String collectorName)  payment,required TResult Function( String id,  DateTime at,  int amount,  String note,  String collectorName)  partialPayment,required TResult Function( String id,  DateTime at,  String note,  String collectorName)  carryForward,required TResult Function( String id,  DateTime at,  List<SaleItemDetail> items,  int total,  int advance,  int creditAdded,  String saleType,  String collectorName,  String? note)  sale,}) {final _that = this;
switch (_that) {
case PaymentActivity():
return payment(_that.id,_that.at,_that.amount,_that.note,_that.collectorName);case PartialPaymentActivity():
return partialPayment(_that.id,_that.at,_that.amount,_that.note,_that.collectorName);case CarryForwardActivity():
return carryForward(_that.id,_that.at,_that.note,_that.collectorName);case SaleActivity():
return sale(_that.id,_that.at,_that.items,_that.total,_that.advance,_that.creditAdded,_that.saleType,_that.collectorName,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  DateTime at,  int amount,  String? note,  String collectorName)?  payment,TResult? Function( String id,  DateTime at,  int amount,  String note,  String collectorName)?  partialPayment,TResult? Function( String id,  DateTime at,  String note,  String collectorName)?  carryForward,TResult? Function( String id,  DateTime at,  List<SaleItemDetail> items,  int total,  int advance,  int creditAdded,  String saleType,  String collectorName,  String? note)?  sale,}) {final _that = this;
switch (_that) {
case PaymentActivity() when payment != null:
return payment(_that.id,_that.at,_that.amount,_that.note,_that.collectorName);case PartialPaymentActivity() when partialPayment != null:
return partialPayment(_that.id,_that.at,_that.amount,_that.note,_that.collectorName);case CarryForwardActivity() when carryForward != null:
return carryForward(_that.id,_that.at,_that.note,_that.collectorName);case SaleActivity() when sale != null:
return sale(_that.id,_that.at,_that.items,_that.total,_that.advance,_that.creditAdded,_that.saleType,_that.collectorName,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class PaymentActivity implements Activity {
  const PaymentActivity({required this.id, required this.at, required this.amount, this.note, required this.collectorName,  String? $type}): $type = $type ?? 'payment';
  factory PaymentActivity.fromJson(Map<String, dynamic> json) => _$PaymentActivityFromJson(json);

@override final  String id;
@override final  DateTime at;
 final  int amount;
@override final  String? note;
@override final  String collectorName;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentActivityCopyWith<PaymentActivity> get copyWith => _$PaymentActivityCopyWithImpl<PaymentActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.at, at) || other.at == at)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.note, note) || other.note == note)&&(identical(other.collectorName, collectorName) || other.collectorName == collectorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,at,amount,note,collectorName);

@override
String toString() {
  return 'Activity.payment(id: $id, at: $at, amount: $amount, note: $note, collectorName: $collectorName)';
}


}

/// @nodoc
abstract mixin class $PaymentActivityCopyWith<$Res> implements $ActivityCopyWith<$Res> {
  factory $PaymentActivityCopyWith(PaymentActivity value, $Res Function(PaymentActivity) _then) = _$PaymentActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime at, int amount, String? note, String collectorName
});




}
/// @nodoc
class _$PaymentActivityCopyWithImpl<$Res>
    implements $PaymentActivityCopyWith<$Res> {
  _$PaymentActivityCopyWithImpl(this._self, this._then);

  final PaymentActivity _self;
  final $Res Function(PaymentActivity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? at = null,Object? amount = null,Object? note = freezed,Object? collectorName = null,}) {
  return _then(PaymentActivity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,collectorName: null == collectorName ? _self.collectorName : collectorName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PartialPaymentActivity implements Activity {
  const PartialPaymentActivity({required this.id, required this.at, required this.amount, required this.note, required this.collectorName,  String? $type}): $type = $type ?? 'partialPayment';
  factory PartialPaymentActivity.fromJson(Map<String, dynamic> json) => _$PartialPaymentActivityFromJson(json);

@override final  String id;
@override final  DateTime at;
 final  int amount;
@override final  String note;
@override final  String collectorName;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartialPaymentActivityCopyWith<PartialPaymentActivity> get copyWith => _$PartialPaymentActivityCopyWithImpl<PartialPaymentActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartialPaymentActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartialPaymentActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.at, at) || other.at == at)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.note, note) || other.note == note)&&(identical(other.collectorName, collectorName) || other.collectorName == collectorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,at,amount,note,collectorName);

@override
String toString() {
  return 'Activity.partialPayment(id: $id, at: $at, amount: $amount, note: $note, collectorName: $collectorName)';
}


}

/// @nodoc
abstract mixin class $PartialPaymentActivityCopyWith<$Res> implements $ActivityCopyWith<$Res> {
  factory $PartialPaymentActivityCopyWith(PartialPaymentActivity value, $Res Function(PartialPaymentActivity) _then) = _$PartialPaymentActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime at, int amount, String note, String collectorName
});




}
/// @nodoc
class _$PartialPaymentActivityCopyWithImpl<$Res>
    implements $PartialPaymentActivityCopyWith<$Res> {
  _$PartialPaymentActivityCopyWithImpl(this._self, this._then);

  final PartialPaymentActivity _self;
  final $Res Function(PartialPaymentActivity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? at = null,Object? amount = null,Object? note = null,Object? collectorName = null,}) {
  return _then(PartialPaymentActivity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,collectorName: null == collectorName ? _self.collectorName : collectorName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CarryForwardActivity implements Activity {
  const CarryForwardActivity({required this.id, required this.at, required this.note, required this.collectorName,  String? $type}): $type = $type ?? 'carryForward';
  factory CarryForwardActivity.fromJson(Map<String, dynamic> json) => _$CarryForwardActivityFromJson(json);

@override final  String id;
@override final  DateTime at;
@override final  String note;
@override final  String collectorName;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarryForwardActivityCopyWith<CarryForwardActivity> get copyWith => _$CarryForwardActivityCopyWithImpl<CarryForwardActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CarryForwardActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarryForwardActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.at, at) || other.at == at)&&(identical(other.note, note) || other.note == note)&&(identical(other.collectorName, collectorName) || other.collectorName == collectorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,at,note,collectorName);

@override
String toString() {
  return 'Activity.carryForward(id: $id, at: $at, note: $note, collectorName: $collectorName)';
}


}

/// @nodoc
abstract mixin class $CarryForwardActivityCopyWith<$Res> implements $ActivityCopyWith<$Res> {
  factory $CarryForwardActivityCopyWith(CarryForwardActivity value, $Res Function(CarryForwardActivity) _then) = _$CarryForwardActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime at, String note, String collectorName
});




}
/// @nodoc
class _$CarryForwardActivityCopyWithImpl<$Res>
    implements $CarryForwardActivityCopyWith<$Res> {
  _$CarryForwardActivityCopyWithImpl(this._self, this._then);

  final CarryForwardActivity _self;
  final $Res Function(CarryForwardActivity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? at = null,Object? note = null,Object? collectorName = null,}) {
  return _then(CarryForwardActivity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,collectorName: null == collectorName ? _self.collectorName : collectorName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SaleActivity implements Activity {
  const SaleActivity({required this.id, required this.at, required  List<SaleItemDetail> items, required this.total, required this.advance, required this.creditAdded, required this.saleType, required this.collectorName, this.note,  String? $type}): _items = items,$type = $type ?? 'sale';
  factory SaleActivity.fromJson(Map<String, dynamic> json) => _$SaleActivityFromJson(json);

@override final  String id;
@override final  DateTime at;
 final  List<SaleItemDetail> _items;
 List<SaleItemDetail> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  int total;
 final  int advance;
 final  int creditAdded;
 final  String saleType;
@override final  String collectorName;
@override final  String? note;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleActivityCopyWith<SaleActivity> get copyWith => _$SaleActivityCopyWithImpl<SaleActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaleActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.at, at) || other.at == at)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.advance, advance) || other.advance == advance)&&(identical(other.creditAdded, creditAdded) || other.creditAdded == creditAdded)&&(identical(other.saleType, saleType) || other.saleType == saleType)&&(identical(other.collectorName, collectorName) || other.collectorName == collectorName)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,at,const DeepCollectionEquality().hash(_items),total,advance,creditAdded,saleType,collectorName,note);

@override
String toString() {
  return 'Activity.sale(id: $id, at: $at, items: $items, total: $total, advance: $advance, creditAdded: $creditAdded, saleType: $saleType, collectorName: $collectorName, note: $note)';
}


}

/// @nodoc
abstract mixin class $SaleActivityCopyWith<$Res> implements $ActivityCopyWith<$Res> {
  factory $SaleActivityCopyWith(SaleActivity value, $Res Function(SaleActivity) _then) = _$SaleActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime at, List<SaleItemDetail> items, int total, int advance, int creditAdded, String saleType, String collectorName, String? note
});




}
/// @nodoc
class _$SaleActivityCopyWithImpl<$Res>
    implements $SaleActivityCopyWith<$Res> {
  _$SaleActivityCopyWithImpl(this._self, this._then);

  final SaleActivity _self;
  final $Res Function(SaleActivity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? at = null,Object? items = null,Object? total = null,Object? advance = null,Object? creditAdded = null,Object? saleType = null,Object? collectorName = null,Object? note = freezed,}) {
  return _then(SaleActivity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SaleItemDetail>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,advance: null == advance ? _self.advance : advance // ignore: cast_nullable_to_non_nullable
as int,creditAdded: null == creditAdded ? _self.creditAdded : creditAdded // ignore: cast_nullable_to_non_nullable
as int,saleType: null == saleType ? _self.saleType : saleType // ignore: cast_nullable_to_non_nullable
as String,collectorName: null == collectorName ? _self.collectorName : collectorName // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SaleItemDetail {

 String get productName; int get quantity; int get unitPrice;
/// Create a copy of SaleItemDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleItemDetailCopyWith<SaleItemDetail> get copyWith => _$SaleItemDetailCopyWithImpl<SaleItemDetail>(this as SaleItemDetail, _$identity);

  /// Serializes this SaleItemDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleItemDetail&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productName,quantity,unitPrice);

@override
String toString() {
  return 'SaleItemDetail(productName: $productName, quantity: $quantity, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class $SaleItemDetailCopyWith<$Res>  {
  factory $SaleItemDetailCopyWith(SaleItemDetail value, $Res Function(SaleItemDetail) _then) = _$SaleItemDetailCopyWithImpl;
@useResult
$Res call({
 String productName, int quantity, int unitPrice
});




}
/// @nodoc
class _$SaleItemDetailCopyWithImpl<$Res>
    implements $SaleItemDetailCopyWith<$Res> {
  _$SaleItemDetailCopyWithImpl(this._self, this._then);

  final SaleItemDetail _self;
  final $Res Function(SaleItemDetail) _then;

/// Create a copy of SaleItemDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productName = null,Object? quantity = null,Object? unitPrice = null,}) {
  return _then(SaleItemDetail(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleItemDetail].
extension SaleItemDetailPatterns on SaleItemDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleItemDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleItemDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleItemDetail value)  $default,){
final _that = this;
switch (_that) {
case _SaleItemDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleItemDetail value)?  $default,){
final _that = this;
switch (_that) {
case _SaleItemDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productName,  int quantity,  int unitPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleItemDetail() when $default != null:
return $default(_that.productName,_that.quantity,_that.unitPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productName,  int quantity,  int unitPrice)  $default,) {final _that = this;
switch (_that) {
case _SaleItemDetail():
return $default(_that.productName,_that.quantity,_that.unitPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productName,  int quantity,  int unitPrice)?  $default,) {final _that = this;
switch (_that) {
case _SaleItemDetail() when $default != null:
return $default(_that.productName,_that.quantity,_that.unitPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SaleItemDetail implements SaleItemDetail {
  const _SaleItemDetail({required this.productName, required this.quantity, required this.unitPrice});
  factory _SaleItemDetail.fromJson(Map<String, dynamic> json) => _$SaleItemDetailFromJson(json);

@override final  String productName;
@override final  int quantity;
@override final  int unitPrice;

/// Create a copy of SaleItemDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleItemDetailCopyWith<_SaleItemDetail> get copyWith => __$SaleItemDetailCopyWithImpl<_SaleItemDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaleItemDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleItemDetail&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productName,quantity,unitPrice);

@override
String toString() {
  return 'SaleItemDetail(productName: $productName, quantity: $quantity, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class _$SaleItemDetailCopyWith<$Res> implements $SaleItemDetailCopyWith<$Res> {
  factory _$SaleItemDetailCopyWith(_SaleItemDetail value, $Res Function(_SaleItemDetail) _then) = __$SaleItemDetailCopyWithImpl;
@override @useResult
$Res call({
 String productName, int quantity, int unitPrice
});




}
/// @nodoc
class __$SaleItemDetailCopyWithImpl<$Res>
    implements _$SaleItemDetailCopyWith<$Res> {
  __$SaleItemDetailCopyWithImpl(this._self, this._then);

  final _SaleItemDetail _self;
  final $Res Function(_SaleItemDetail) _then;

/// Create a copy of SaleItemDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productName = null,Object? quantity = null,Object? unitPrice = null,}) {
  return _then(_SaleItemDetail(
productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
