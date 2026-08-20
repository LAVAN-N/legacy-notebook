// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'id_proof.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IdProofDocument {

 String get filename; String get mimeType; int get sizeBytes; String get localUri;
/// Create a copy of IdProofDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdProofDocumentCopyWith<IdProofDocument> get copyWith => _$IdProofDocumentCopyWithImpl<IdProofDocument>(this as IdProofDocument, _$identity);

  /// Serializes this IdProofDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdProofDocument&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.localUri, localUri) || other.localUri == localUri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,filename,mimeType,sizeBytes,localUri);

@override
String toString() {
  return 'IdProofDocument(filename: $filename, mimeType: $mimeType, sizeBytes: $sizeBytes, localUri: $localUri)';
}


}

/// @nodoc
abstract mixin class $IdProofDocumentCopyWith<$Res>  {
  factory $IdProofDocumentCopyWith(IdProofDocument value, $Res Function(IdProofDocument) _then) = _$IdProofDocumentCopyWithImpl;
@useResult
$Res call({
 String filename, String mimeType, int sizeBytes, String localUri
});




}
/// @nodoc
class _$IdProofDocumentCopyWithImpl<$Res>
    implements $IdProofDocumentCopyWith<$Res> {
  _$IdProofDocumentCopyWithImpl(this._self, this._then);

  final IdProofDocument _self;
  final $Res Function(IdProofDocument) _then;

/// Create a copy of IdProofDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filename = null,Object? mimeType = null,Object? sizeBytes = null,Object? localUri = null,}) {
  return _then(IdProofDocument(
filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,localUri: null == localUri ? _self.localUri : localUri // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IdProofDocument].
extension IdProofDocumentPatterns on IdProofDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdProofDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdProofDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdProofDocument value)  $default,){
final _that = this;
switch (_that) {
case _IdProofDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdProofDocument value)?  $default,){
final _that = this;
switch (_that) {
case _IdProofDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String filename,  String mimeType,  int sizeBytes,  String localUri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdProofDocument() when $default != null:
return $default(_that.filename,_that.mimeType,_that.sizeBytes,_that.localUri);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String filename,  String mimeType,  int sizeBytes,  String localUri)  $default,) {final _that = this;
switch (_that) {
case _IdProofDocument():
return $default(_that.filename,_that.mimeType,_that.sizeBytes,_that.localUri);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String filename,  String mimeType,  int sizeBytes,  String localUri)?  $default,) {final _that = this;
switch (_that) {
case _IdProofDocument() when $default != null:
return $default(_that.filename,_that.mimeType,_that.sizeBytes,_that.localUri);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IdProofDocument implements IdProofDocument {
  const _IdProofDocument({required this.filename, required this.mimeType, required this.sizeBytes, required this.localUri});
  factory _IdProofDocument.fromJson(Map<String, dynamic> json) => _$IdProofDocumentFromJson(json);

@override final  String filename;
@override final  String mimeType;
@override final  int sizeBytes;
@override final  String localUri;

/// Create a copy of IdProofDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdProofDocumentCopyWith<_IdProofDocument> get copyWith => __$IdProofDocumentCopyWithImpl<_IdProofDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdProofDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdProofDocument&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.localUri, localUri) || other.localUri == localUri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,filename,mimeType,sizeBytes,localUri);

@override
String toString() {
  return 'IdProofDocument(filename: $filename, mimeType: $mimeType, sizeBytes: $sizeBytes, localUri: $localUri)';
}


}

/// @nodoc
abstract mixin class _$IdProofDocumentCopyWith<$Res> implements $IdProofDocumentCopyWith<$Res> {
  factory _$IdProofDocumentCopyWith(_IdProofDocument value, $Res Function(_IdProofDocument) _then) = __$IdProofDocumentCopyWithImpl;
@override @useResult
$Res call({
 String filename, String mimeType, int sizeBytes, String localUri
});




}
/// @nodoc
class __$IdProofDocumentCopyWithImpl<$Res>
    implements _$IdProofDocumentCopyWith<$Res> {
  __$IdProofDocumentCopyWithImpl(this._self, this._then);

  final _IdProofDocument _self;
  final $Res Function(_IdProofDocument) _then;

/// Create a copy of IdProofDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filename = null,Object? mimeType = null,Object? sizeBytes = null,Object? localUri = null,}) {
  return _then(_IdProofDocument(
filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,localUri: null == localUri ? _self.localUri : localUri // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$IdProof {

 String get id; String get type;@JsonKey(name: 'proof_url') String get proofUrl; IdProofDocument? get document;
/// Create a copy of IdProof
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdProofCopyWith<IdProof> get copyWith => _$IdProofCopyWithImpl<IdProof>(this as IdProof, _$identity);

  /// Serializes this IdProof to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdProof&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.proofUrl, proofUrl) || other.proofUrl == proofUrl)&&(identical(other.document, document) || other.document == document));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,proofUrl,document);

@override
String toString() {
  return 'IdProof(id: $id, type: $type, proofUrl: $proofUrl, document: $document)';
}


}

/// @nodoc
abstract mixin class $IdProofCopyWith<$Res>  {
  factory $IdProofCopyWith(IdProof value, $Res Function(IdProof) _then) = _$IdProofCopyWithImpl;
@useResult
$Res call({
 String id, String type,@JsonKey(name: 'proof_url') String proofUrl, IdProofDocument? document
});


$IdProofDocumentCopyWith<$Res>? get document;

}
/// @nodoc
class _$IdProofCopyWithImpl<$Res>
    implements $IdProofCopyWith<$Res> {
  _$IdProofCopyWithImpl(this._self, this._then);

  final IdProof _self;
  final $Res Function(IdProof) _then;

/// Create a copy of IdProof
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? proofUrl = null,Object? document = freezed,}) {
  return _then(IdProof(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,proofUrl: null == proofUrl ? _self.proofUrl : proofUrl // ignore: cast_nullable_to_non_nullable
as String,document: freezed == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as IdProofDocument?,
  ));
}
/// Create a copy of IdProof
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdProofDocumentCopyWith<$Res>? get document {
    if (_self.document == null) {
    return null;
  }

  return $IdProofDocumentCopyWith<$Res>(_self.document!, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}


/// Adds pattern-matching-related methods to [IdProof].
extension IdProofPatterns on IdProof {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdProof value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdProof() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdProof value)  $default,){
final _that = this;
switch (_that) {
case _IdProof():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdProof value)?  $default,){
final _that = this;
switch (_that) {
case _IdProof() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type, @JsonKey(name: 'proof_url')  String proofUrl,  IdProofDocument? document)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdProof() when $default != null:
return $default(_that.id,_that.type,_that.proofUrl,_that.document);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type, @JsonKey(name: 'proof_url')  String proofUrl,  IdProofDocument? document)  $default,) {final _that = this;
switch (_that) {
case _IdProof():
return $default(_that.id,_that.type,_that.proofUrl,_that.document);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type, @JsonKey(name: 'proof_url')  String proofUrl,  IdProofDocument? document)?  $default,) {final _that = this;
switch (_that) {
case _IdProof() when $default != null:
return $default(_that.id,_that.type,_that.proofUrl,_that.document);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IdProof implements IdProof {
  const _IdProof({required this.id, required this.type, @JsonKey(name: 'proof_url') required this.proofUrl, this.document});
  factory _IdProof.fromJson(Map<String, dynamic> json) => _$IdProofFromJson(json);

@override final  String id;
@override final  String type;
@override@JsonKey(name: 'proof_url') final  String proofUrl;
@override final  IdProofDocument? document;

/// Create a copy of IdProof
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdProofCopyWith<_IdProof> get copyWith => __$IdProofCopyWithImpl<_IdProof>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdProofToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdProof&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.proofUrl, proofUrl) || other.proofUrl == proofUrl)&&(identical(other.document, document) || other.document == document));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,proofUrl,document);

@override
String toString() {
  return 'IdProof(id: $id, type: $type, proofUrl: $proofUrl, document: $document)';
}


}

/// @nodoc
abstract mixin class _$IdProofCopyWith<$Res> implements $IdProofCopyWith<$Res> {
  factory _$IdProofCopyWith(_IdProof value, $Res Function(_IdProof) _then) = __$IdProofCopyWithImpl;
@override @useResult
$Res call({
 String id, String type,@JsonKey(name: 'proof_url') String proofUrl, IdProofDocument? document
});


@override $IdProofDocumentCopyWith<$Res>? get document;

}
/// @nodoc
class __$IdProofCopyWithImpl<$Res>
    implements _$IdProofCopyWith<$Res> {
  __$IdProofCopyWithImpl(this._self, this._then);

  final _IdProof _self;
  final $Res Function(_IdProof) _then;

/// Create a copy of IdProof
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? proofUrl = null,Object? document = freezed,}) {
  return _then(_IdProof(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,proofUrl: null == proofUrl ? _self.proofUrl : proofUrl // ignore: cast_nullable_to_non_nullable
as String,document: freezed == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as IdProofDocument?,
  ));
}

/// Create a copy of IdProof
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdProofDocumentCopyWith<$Res>? get document {
    if (_self.document == null) {
    return null;
  }

  return $IdProofDocumentCopyWith<$Res>(_self.document!, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}

// dart format on
