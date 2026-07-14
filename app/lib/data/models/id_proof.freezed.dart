// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'id_proof.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IdProofDocument _$IdProofDocumentFromJson(Map<String, dynamic> json) {
  return _IdProofDocument.fromJson(json);
}

/// @nodoc
mixin _$IdProofDocument {
  String get filename => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;
  int get sizeBytes => throw _privateConstructorUsedError;
  String get localUri => throw _privateConstructorUsedError;

  /// Serializes this IdProofDocument to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IdProofDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IdProofDocumentCopyWith<IdProofDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdProofDocumentCopyWith<$Res> {
  factory $IdProofDocumentCopyWith(
          IdProofDocument value, $Res Function(IdProofDocument) then) =
      _$IdProofDocumentCopyWithImpl<$Res, IdProofDocument>;
  @useResult
  $Res call({String filename, String mimeType, int sizeBytes, String localUri});
}

/// @nodoc
class _$IdProofDocumentCopyWithImpl<$Res, $Val extends IdProofDocument>
    implements $IdProofDocumentCopyWith<$Res> {
  _$IdProofDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IdProofDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filename = null,
    Object? mimeType = null,
    Object? sizeBytes = null,
    Object? localUri = null,
  }) {
    return _then(_value.copyWith(
      filename: null == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      sizeBytes: null == sizeBytes
          ? _value.sizeBytes
          : sizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      localUri: null == localUri
          ? _value.localUri
          : localUri // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IdProofDocumentImplCopyWith<$Res>
    implements $IdProofDocumentCopyWith<$Res> {
  factory _$$IdProofDocumentImplCopyWith(_$IdProofDocumentImpl value,
          $Res Function(_$IdProofDocumentImpl) then) =
      __$$IdProofDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String filename, String mimeType, int sizeBytes, String localUri});
}

/// @nodoc
class __$$IdProofDocumentImplCopyWithImpl<$Res>
    extends _$IdProofDocumentCopyWithImpl<$Res, _$IdProofDocumentImpl>
    implements _$$IdProofDocumentImplCopyWith<$Res> {
  __$$IdProofDocumentImplCopyWithImpl(
      _$IdProofDocumentImpl _value, $Res Function(_$IdProofDocumentImpl) _then)
      : super(_value, _then);

  /// Create a copy of IdProofDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filename = null,
    Object? mimeType = null,
    Object? sizeBytes = null,
    Object? localUri = null,
  }) {
    return _then(_$IdProofDocumentImpl(
      filename: null == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      sizeBytes: null == sizeBytes
          ? _value.sizeBytes
          : sizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      localUri: null == localUri
          ? _value.localUri
          : localUri // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IdProofDocumentImpl implements _IdProofDocument {
  const _$IdProofDocumentImpl(
      {required this.filename,
      required this.mimeType,
      required this.sizeBytes,
      required this.localUri});

  factory _$IdProofDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdProofDocumentImplFromJson(json);

  @override
  final String filename;
  @override
  final String mimeType;
  @override
  final int sizeBytes;
  @override
  final String localUri;

  @override
  String toString() {
    return 'IdProofDocument(filename: $filename, mimeType: $mimeType, sizeBytes: $sizeBytes, localUri: $localUri)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdProofDocumentImpl &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.localUri, localUri) ||
                other.localUri == localUri));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, filename, mimeType, sizeBytes, localUri);

  /// Create a copy of IdProofDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IdProofDocumentImplCopyWith<_$IdProofDocumentImpl> get copyWith =>
      __$$IdProofDocumentImplCopyWithImpl<_$IdProofDocumentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdProofDocumentImplToJson(
      this,
    );
  }
}

abstract class _IdProofDocument implements IdProofDocument {
  const factory _IdProofDocument(
      {required final String filename,
      required final String mimeType,
      required final int sizeBytes,
      required final String localUri}) = _$IdProofDocumentImpl;

  factory _IdProofDocument.fromJson(Map<String, dynamic> json) =
      _$IdProofDocumentImpl.fromJson;

  @override
  String get filename;
  @override
  String get mimeType;
  @override
  int get sizeBytes;
  @override
  String get localUri;

  /// Create a copy of IdProofDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IdProofDocumentImplCopyWith<_$IdProofDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IdProof _$IdProofFromJson(Map<String, dynamic> json) {
  return _IdProof.fromJson(json);
}

/// @nodoc
mixin _$IdProof {
  String get id => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'Aadhaar' | 'Voter' | 'DL' | 'PAN' | 'Other'
  String get number => throw _privateConstructorUsedError;
  IdProofDocument? get document => throw _privateConstructorUsedError;

  /// Serializes this IdProof to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IdProof
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IdProofCopyWith<IdProof> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdProofCopyWith<$Res> {
  factory $IdProofCopyWith(IdProof value, $Res Function(IdProof) then) =
      _$IdProofCopyWithImpl<$Res, IdProof>;
  @useResult
  $Res call({String id, String type, String number, IdProofDocument? document});

  $IdProofDocumentCopyWith<$Res>? get document;
}

/// @nodoc
class _$IdProofCopyWithImpl<$Res, $Val extends IdProof>
    implements $IdProofCopyWith<$Res> {
  _$IdProofCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IdProof
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? number = null,
    Object? document = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      document: freezed == document
          ? _value.document
          : document // ignore: cast_nullable_to_non_nullable
              as IdProofDocument?,
    ) as $Val);
  }

  /// Create a copy of IdProof
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IdProofDocumentCopyWith<$Res>? get document {
    if (_value.document == null) {
      return null;
    }

    return $IdProofDocumentCopyWith<$Res>(_value.document!, (value) {
      return _then(_value.copyWith(document: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$IdProofImplCopyWith<$Res> implements $IdProofCopyWith<$Res> {
  factory _$$IdProofImplCopyWith(
          _$IdProofImpl value, $Res Function(_$IdProofImpl) then) =
      __$$IdProofImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String type, String number, IdProofDocument? document});

  @override
  $IdProofDocumentCopyWith<$Res>? get document;
}

/// @nodoc
class __$$IdProofImplCopyWithImpl<$Res>
    extends _$IdProofCopyWithImpl<$Res, _$IdProofImpl>
    implements _$$IdProofImplCopyWith<$Res> {
  __$$IdProofImplCopyWithImpl(
      _$IdProofImpl _value, $Res Function(_$IdProofImpl) _then)
      : super(_value, _then);

  /// Create a copy of IdProof
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? number = null,
    Object? document = freezed,
  }) {
    return _then(_$IdProofImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      document: freezed == document
          ? _value.document
          : document // ignore: cast_nullable_to_non_nullable
              as IdProofDocument?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IdProofImpl implements _IdProof {
  const _$IdProofImpl(
      {required this.id,
      required this.type,
      required this.number,
      this.document});

  factory _$IdProofImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdProofImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
// 'Aadhaar' | 'Voter' | 'DL' | 'PAN' | 'Other'
  @override
  final String number;
  @override
  final IdProofDocument? document;

  @override
  String toString() {
    return 'IdProof(id: $id, type: $type, number: $number, document: $document)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdProofImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.document, document) ||
                other.document == document));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, number, document);

  /// Create a copy of IdProof
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IdProofImplCopyWith<_$IdProofImpl> get copyWith =>
      __$$IdProofImplCopyWithImpl<_$IdProofImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdProofImplToJson(
      this,
    );
  }
}

abstract class _IdProof implements IdProof {
  const factory _IdProof(
      {required final String id,
      required final String type,
      required final String number,
      final IdProofDocument? document}) = _$IdProofImpl;

  factory _IdProof.fromJson(Map<String, dynamic> json) = _$IdProofImpl.fromJson;

  @override
  String get id;
  @override
  String get type; // 'Aadhaar' | 'Voter' | 'DL' | 'PAN' | 'Other'
  @override
  String get number;
  @override
  IdProofDocument? get document;

  /// Create a copy of IdProof
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IdProofImplCopyWith<_$IdProofImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
