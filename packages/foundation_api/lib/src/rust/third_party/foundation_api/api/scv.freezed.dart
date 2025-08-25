// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scv.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChallengeResponseResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Uint8List data) success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Uint8List data)? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Uint8List data)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChallengeResponseResult_Success value) success,
    required TResult Function(ChallengeResponseResult_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChallengeResponseResult_Success value)? success,
    TResult? Function(ChallengeResponseResult_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChallengeResponseResult_Success value)? success,
    TResult Function(ChallengeResponseResult_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeResponseResultCopyWith<$Res> {
  factory $ChallengeResponseResultCopyWith(ChallengeResponseResult value,
          $Res Function(ChallengeResponseResult) then) =
      _$ChallengeResponseResultCopyWithImpl<$Res, ChallengeResponseResult>;
}

/// @nodoc
class _$ChallengeResponseResultCopyWithImpl<$Res,
        $Val extends ChallengeResponseResult>
    implements $ChallengeResponseResultCopyWith<$Res> {
  _$ChallengeResponseResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeResponseResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ChallengeResponseResult_SuccessImplCopyWith<$Res> {
  factory _$$ChallengeResponseResult_SuccessImplCopyWith(
          _$ChallengeResponseResult_SuccessImpl value,
          $Res Function(_$ChallengeResponseResult_SuccessImpl) then) =
      __$$ChallengeResponseResult_SuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Uint8List data});
}

/// @nodoc
class __$$ChallengeResponseResult_SuccessImplCopyWithImpl<$Res>
    extends _$ChallengeResponseResultCopyWithImpl<$Res,
        _$ChallengeResponseResult_SuccessImpl>
    implements _$$ChallengeResponseResult_SuccessImplCopyWith<$Res> {
  __$$ChallengeResponseResult_SuccessImplCopyWithImpl(
      _$ChallengeResponseResult_SuccessImpl _value,
      $Res Function(_$ChallengeResponseResult_SuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeResponseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$ChallengeResponseResult_SuccessImpl(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ));
  }
}

/// @nodoc

class _$ChallengeResponseResult_SuccessImpl
    extends ChallengeResponseResult_Success {
  const _$ChallengeResponseResult_SuccessImpl({required this.data}) : super._();

  @override
  final Uint8List data;

  @override
  String toString() {
    return 'ChallengeResponseResult.success(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeResponseResult_SuccessImpl &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  /// Create a copy of ChallengeResponseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeResponseResult_SuccessImplCopyWith<
          _$ChallengeResponseResult_SuccessImpl>
      get copyWith => __$$ChallengeResponseResult_SuccessImplCopyWithImpl<
          _$ChallengeResponseResult_SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Uint8List data) success,
    required TResult Function(String error) error,
  }) {
    return success(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Uint8List data)? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Uint8List data)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChallengeResponseResult_Success value) success,
    required TResult Function(ChallengeResponseResult_Error value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChallengeResponseResult_Success value)? success,
    TResult? Function(ChallengeResponseResult_Error value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChallengeResponseResult_Success value)? success,
    TResult Function(ChallengeResponseResult_Error value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class ChallengeResponseResult_Success extends ChallengeResponseResult {
  const factory ChallengeResponseResult_Success(
      {required final Uint8List data}) = _$ChallengeResponseResult_SuccessImpl;
  const ChallengeResponseResult_Success._() : super._();

  Uint8List get data;

  /// Create a copy of ChallengeResponseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeResponseResult_SuccessImplCopyWith<
          _$ChallengeResponseResult_SuccessImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChallengeResponseResult_ErrorImplCopyWith<$Res> {
  factory _$$ChallengeResponseResult_ErrorImplCopyWith(
          _$ChallengeResponseResult_ErrorImpl value,
          $Res Function(_$ChallengeResponseResult_ErrorImpl) then) =
      __$$ChallengeResponseResult_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$ChallengeResponseResult_ErrorImplCopyWithImpl<$Res>
    extends _$ChallengeResponseResultCopyWithImpl<$Res,
        _$ChallengeResponseResult_ErrorImpl>
    implements _$$ChallengeResponseResult_ErrorImplCopyWith<$Res> {
  __$$ChallengeResponseResult_ErrorImplCopyWithImpl(
      _$ChallengeResponseResult_ErrorImpl _value,
      $Res Function(_$ChallengeResponseResult_ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeResponseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$ChallengeResponseResult_ErrorImpl(
      error: null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ChallengeResponseResult_ErrorImpl
    extends ChallengeResponseResult_Error {
  const _$ChallengeResponseResult_ErrorImpl({required this.error}) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'ChallengeResponseResult.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeResponseResult_ErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of ChallengeResponseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeResponseResult_ErrorImplCopyWith<
          _$ChallengeResponseResult_ErrorImpl>
      get copyWith => __$$ChallengeResponseResult_ErrorImplCopyWithImpl<
          _$ChallengeResponseResult_ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Uint8List data) success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Uint8List data)? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Uint8List data)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChallengeResponseResult_Success value) success,
    required TResult Function(ChallengeResponseResult_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChallengeResponseResult_Success value)? success,
    TResult? Function(ChallengeResponseResult_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChallengeResponseResult_Success value)? success,
    TResult Function(ChallengeResponseResult_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ChallengeResponseResult_Error extends ChallengeResponseResult {
  const factory ChallengeResponseResult_Error({required final String error}) =
      _$ChallengeResponseResult_ErrorImpl;
  const ChallengeResponseResult_Error._() : super._();

  String get error;

  /// Create a copy of ChallengeResponseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeResponseResult_ErrorImplCopyWith<
          _$ChallengeResponseResult_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SecurityCheck {
  Object get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ChallengeRequest field0) challengeRequest,
    required TResult Function(ChallengeResponseResult field0) challengeResponse,
    required TResult Function(VerificationResult field0) verificationResult,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ChallengeRequest field0)? challengeRequest,
    TResult? Function(ChallengeResponseResult field0)? challengeResponse,
    TResult? Function(VerificationResult field0)? verificationResult,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ChallengeRequest field0)? challengeRequest,
    TResult Function(ChallengeResponseResult field0)? challengeResponse,
    TResult Function(VerificationResult field0)? verificationResult,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SecurityCheck_ChallengeRequest value)
        challengeRequest,
    required TResult Function(SecurityCheck_ChallengeResponse value)
        challengeResponse,
    required TResult Function(SecurityCheck_VerificationResult value)
        verificationResult,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SecurityCheck_ChallengeRequest value)? challengeRequest,
    TResult? Function(SecurityCheck_ChallengeResponse value)? challengeResponse,
    TResult? Function(SecurityCheck_VerificationResult value)?
        verificationResult,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SecurityCheck_ChallengeRequest value)? challengeRequest,
    TResult Function(SecurityCheck_ChallengeResponse value)? challengeResponse,
    TResult Function(SecurityCheck_VerificationResult value)?
        verificationResult,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityCheckCopyWith<$Res> {
  factory $SecurityCheckCopyWith(
          SecurityCheck value, $Res Function(SecurityCheck) then) =
      _$SecurityCheckCopyWithImpl<$Res, SecurityCheck>;
}

/// @nodoc
class _$SecurityCheckCopyWithImpl<$Res, $Val extends SecurityCheck>
    implements $SecurityCheckCopyWith<$Res> {
  _$SecurityCheckCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityCheck
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SecurityCheck_ChallengeRequestImplCopyWith<$Res> {
  factory _$$SecurityCheck_ChallengeRequestImplCopyWith(
          _$SecurityCheck_ChallengeRequestImpl value,
          $Res Function(_$SecurityCheck_ChallengeRequestImpl) then) =
      __$$SecurityCheck_ChallengeRequestImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ChallengeRequest field0});
}

/// @nodoc
class __$$SecurityCheck_ChallengeRequestImplCopyWithImpl<$Res>
    extends _$SecurityCheckCopyWithImpl<$Res,
        _$SecurityCheck_ChallengeRequestImpl>
    implements _$$SecurityCheck_ChallengeRequestImplCopyWith<$Res> {
  __$$SecurityCheck_ChallengeRequestImplCopyWithImpl(
      _$SecurityCheck_ChallengeRequestImpl _value,
      $Res Function(_$SecurityCheck_ChallengeRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of SecurityCheck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$SecurityCheck_ChallengeRequestImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ChallengeRequest,
    ));
  }
}

/// @nodoc

class _$SecurityCheck_ChallengeRequestImpl
    extends SecurityCheck_ChallengeRequest {
  const _$SecurityCheck_ChallengeRequestImpl(this.field0) : super._();

  @override
  final ChallengeRequest field0;

  @override
  String toString() {
    return 'SecurityCheck.challengeRequest(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityCheck_ChallengeRequestImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of SecurityCheck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityCheck_ChallengeRequestImplCopyWith<
          _$SecurityCheck_ChallengeRequestImpl>
      get copyWith => __$$SecurityCheck_ChallengeRequestImplCopyWithImpl<
          _$SecurityCheck_ChallengeRequestImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ChallengeRequest field0) challengeRequest,
    required TResult Function(ChallengeResponseResult field0) challengeResponse,
    required TResult Function(VerificationResult field0) verificationResult,
  }) {
    return challengeRequest(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ChallengeRequest field0)? challengeRequest,
    TResult? Function(ChallengeResponseResult field0)? challengeResponse,
    TResult? Function(VerificationResult field0)? verificationResult,
  }) {
    return challengeRequest?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ChallengeRequest field0)? challengeRequest,
    TResult Function(ChallengeResponseResult field0)? challengeResponse,
    TResult Function(VerificationResult field0)? verificationResult,
    required TResult orElse(),
  }) {
    if (challengeRequest != null) {
      return challengeRequest(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SecurityCheck_ChallengeRequest value)
        challengeRequest,
    required TResult Function(SecurityCheck_ChallengeResponse value)
        challengeResponse,
    required TResult Function(SecurityCheck_VerificationResult value)
        verificationResult,
  }) {
    return challengeRequest(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SecurityCheck_ChallengeRequest value)? challengeRequest,
    TResult? Function(SecurityCheck_ChallengeResponse value)? challengeResponse,
    TResult? Function(SecurityCheck_VerificationResult value)?
        verificationResult,
  }) {
    return challengeRequest?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SecurityCheck_ChallengeRequest value)? challengeRequest,
    TResult Function(SecurityCheck_ChallengeResponse value)? challengeResponse,
    TResult Function(SecurityCheck_VerificationResult value)?
        verificationResult,
    required TResult orElse(),
  }) {
    if (challengeRequest != null) {
      return challengeRequest(this);
    }
    return orElse();
  }
}

abstract class SecurityCheck_ChallengeRequest extends SecurityCheck {
  const factory SecurityCheck_ChallengeRequest(final ChallengeRequest field0) =
      _$SecurityCheck_ChallengeRequestImpl;
  const SecurityCheck_ChallengeRequest._() : super._();

  @override
  ChallengeRequest get field0;

  /// Create a copy of SecurityCheck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityCheck_ChallengeRequestImplCopyWith<
          _$SecurityCheck_ChallengeRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SecurityCheck_ChallengeResponseImplCopyWith<$Res> {
  factory _$$SecurityCheck_ChallengeResponseImplCopyWith(
          _$SecurityCheck_ChallengeResponseImpl value,
          $Res Function(_$SecurityCheck_ChallengeResponseImpl) then) =
      __$$SecurityCheck_ChallengeResponseImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ChallengeResponseResult field0});

  $ChallengeResponseResultCopyWith<$Res> get field0;
}

/// @nodoc
class __$$SecurityCheck_ChallengeResponseImplCopyWithImpl<$Res>
    extends _$SecurityCheckCopyWithImpl<$Res,
        _$SecurityCheck_ChallengeResponseImpl>
    implements _$$SecurityCheck_ChallengeResponseImplCopyWith<$Res> {
  __$$SecurityCheck_ChallengeResponseImplCopyWithImpl(
      _$SecurityCheck_ChallengeResponseImpl _value,
      $Res Function(_$SecurityCheck_ChallengeResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of SecurityCheck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$SecurityCheck_ChallengeResponseImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ChallengeResponseResult,
    ));
  }

  /// Create a copy of SecurityCheck
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeResponseResultCopyWith<$Res> get field0 {
    return $ChallengeResponseResultCopyWith<$Res>(_value.field0, (value) {
      return _then(_value.copyWith(field0: value));
    });
  }
}

/// @nodoc

class _$SecurityCheck_ChallengeResponseImpl
    extends SecurityCheck_ChallengeResponse {
  const _$SecurityCheck_ChallengeResponseImpl(this.field0) : super._();

  @override
  final ChallengeResponseResult field0;

  @override
  String toString() {
    return 'SecurityCheck.challengeResponse(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityCheck_ChallengeResponseImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of SecurityCheck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityCheck_ChallengeResponseImplCopyWith<
          _$SecurityCheck_ChallengeResponseImpl>
      get copyWith => __$$SecurityCheck_ChallengeResponseImplCopyWithImpl<
          _$SecurityCheck_ChallengeResponseImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ChallengeRequest field0) challengeRequest,
    required TResult Function(ChallengeResponseResult field0) challengeResponse,
    required TResult Function(VerificationResult field0) verificationResult,
  }) {
    return challengeResponse(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ChallengeRequest field0)? challengeRequest,
    TResult? Function(ChallengeResponseResult field0)? challengeResponse,
    TResult? Function(VerificationResult field0)? verificationResult,
  }) {
    return challengeResponse?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ChallengeRequest field0)? challengeRequest,
    TResult Function(ChallengeResponseResult field0)? challengeResponse,
    TResult Function(VerificationResult field0)? verificationResult,
    required TResult orElse(),
  }) {
    if (challengeResponse != null) {
      return challengeResponse(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SecurityCheck_ChallengeRequest value)
        challengeRequest,
    required TResult Function(SecurityCheck_ChallengeResponse value)
        challengeResponse,
    required TResult Function(SecurityCheck_VerificationResult value)
        verificationResult,
  }) {
    return challengeResponse(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SecurityCheck_ChallengeRequest value)? challengeRequest,
    TResult? Function(SecurityCheck_ChallengeResponse value)? challengeResponse,
    TResult? Function(SecurityCheck_VerificationResult value)?
        verificationResult,
  }) {
    return challengeResponse?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SecurityCheck_ChallengeRequest value)? challengeRequest,
    TResult Function(SecurityCheck_ChallengeResponse value)? challengeResponse,
    TResult Function(SecurityCheck_VerificationResult value)?
        verificationResult,
    required TResult orElse(),
  }) {
    if (challengeResponse != null) {
      return challengeResponse(this);
    }
    return orElse();
  }
}

abstract class SecurityCheck_ChallengeResponse extends SecurityCheck {
  const factory SecurityCheck_ChallengeResponse(
          final ChallengeResponseResult field0) =
      _$SecurityCheck_ChallengeResponseImpl;
  const SecurityCheck_ChallengeResponse._() : super._();

  @override
  ChallengeResponseResult get field0;

  /// Create a copy of SecurityCheck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityCheck_ChallengeResponseImplCopyWith<
          _$SecurityCheck_ChallengeResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SecurityCheck_VerificationResultImplCopyWith<$Res> {
  factory _$$SecurityCheck_VerificationResultImplCopyWith(
          _$SecurityCheck_VerificationResultImpl value,
          $Res Function(_$SecurityCheck_VerificationResultImpl) then) =
      __$$SecurityCheck_VerificationResultImplCopyWithImpl<$Res>;
  @useResult
  $Res call({VerificationResult field0});

  $VerificationResultCopyWith<$Res> get field0;
}

/// @nodoc
class __$$SecurityCheck_VerificationResultImplCopyWithImpl<$Res>
    extends _$SecurityCheckCopyWithImpl<$Res,
        _$SecurityCheck_VerificationResultImpl>
    implements _$$SecurityCheck_VerificationResultImplCopyWith<$Res> {
  __$$SecurityCheck_VerificationResultImplCopyWithImpl(
      _$SecurityCheck_VerificationResultImpl _value,
      $Res Function(_$SecurityCheck_VerificationResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of SecurityCheck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$SecurityCheck_VerificationResultImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as VerificationResult,
    ));
  }

  /// Create a copy of SecurityCheck
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VerificationResultCopyWith<$Res> get field0 {
    return $VerificationResultCopyWith<$Res>(_value.field0, (value) {
      return _then(_value.copyWith(field0: value));
    });
  }
}

/// @nodoc

class _$SecurityCheck_VerificationResultImpl
    extends SecurityCheck_VerificationResult {
  const _$SecurityCheck_VerificationResultImpl(this.field0) : super._();

  @override
  final VerificationResult field0;

  @override
  String toString() {
    return 'SecurityCheck.verificationResult(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityCheck_VerificationResultImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of SecurityCheck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityCheck_VerificationResultImplCopyWith<
          _$SecurityCheck_VerificationResultImpl>
      get copyWith => __$$SecurityCheck_VerificationResultImplCopyWithImpl<
          _$SecurityCheck_VerificationResultImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ChallengeRequest field0) challengeRequest,
    required TResult Function(ChallengeResponseResult field0) challengeResponse,
    required TResult Function(VerificationResult field0) verificationResult,
  }) {
    return verificationResult(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ChallengeRequest field0)? challengeRequest,
    TResult? Function(ChallengeResponseResult field0)? challengeResponse,
    TResult? Function(VerificationResult field0)? verificationResult,
  }) {
    return verificationResult?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ChallengeRequest field0)? challengeRequest,
    TResult Function(ChallengeResponseResult field0)? challengeResponse,
    TResult Function(VerificationResult field0)? verificationResult,
    required TResult orElse(),
  }) {
    if (verificationResult != null) {
      return verificationResult(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SecurityCheck_ChallengeRequest value)
        challengeRequest,
    required TResult Function(SecurityCheck_ChallengeResponse value)
        challengeResponse,
    required TResult Function(SecurityCheck_VerificationResult value)
        verificationResult,
  }) {
    return verificationResult(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SecurityCheck_ChallengeRequest value)? challengeRequest,
    TResult? Function(SecurityCheck_ChallengeResponse value)? challengeResponse,
    TResult? Function(SecurityCheck_VerificationResult value)?
        verificationResult,
  }) {
    return verificationResult?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SecurityCheck_ChallengeRequest value)? challengeRequest,
    TResult Function(SecurityCheck_ChallengeResponse value)? challengeResponse,
    TResult Function(SecurityCheck_VerificationResult value)?
        verificationResult,
    required TResult orElse(),
  }) {
    if (verificationResult != null) {
      return verificationResult(this);
    }
    return orElse();
  }
}

abstract class SecurityCheck_VerificationResult extends SecurityCheck {
  const factory SecurityCheck_VerificationResult(
      final VerificationResult field0) = _$SecurityCheck_VerificationResultImpl;
  const SecurityCheck_VerificationResult._() : super._();

  @override
  VerificationResult get field0;

  /// Create a copy of SecurityCheck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityCheck_VerificationResultImplCopyWith<
          _$SecurityCheck_VerificationResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$VerificationResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() success,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? success,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VerificationResult_Success value) success,
    required TResult Function(VerificationResult_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VerificationResult_Success value)? success,
    TResult? Function(VerificationResult_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VerificationResult_Success value)? success,
    TResult Function(VerificationResult_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerificationResultCopyWith<$Res> {
  factory $VerificationResultCopyWith(
          VerificationResult value, $Res Function(VerificationResult) then) =
      _$VerificationResultCopyWithImpl<$Res, VerificationResult>;
}

/// @nodoc
class _$VerificationResultCopyWithImpl<$Res, $Val extends VerificationResult>
    implements $VerificationResultCopyWith<$Res> {
  _$VerificationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$VerificationResult_SuccessImplCopyWith<$Res> {
  factory _$$VerificationResult_SuccessImplCopyWith(
          _$VerificationResult_SuccessImpl value,
          $Res Function(_$VerificationResult_SuccessImpl) then) =
      __$$VerificationResult_SuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$VerificationResult_SuccessImplCopyWithImpl<$Res>
    extends _$VerificationResultCopyWithImpl<$Res,
        _$VerificationResult_SuccessImpl>
    implements _$$VerificationResult_SuccessImplCopyWith<$Res> {
  __$$VerificationResult_SuccessImplCopyWithImpl(
      _$VerificationResult_SuccessImpl _value,
      $Res Function(_$VerificationResult_SuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$VerificationResult_SuccessImpl extends VerificationResult_Success {
  const _$VerificationResult_SuccessImpl() : super._();

  @override
  String toString() {
    return 'VerificationResult.success()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerificationResult_SuccessImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() success,
    required TResult Function(String error) error,
  }) {
    return success();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? success,
    TResult? Function(String error)? error,
  }) {
    return success?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VerificationResult_Success value) success,
    required TResult Function(VerificationResult_Error value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VerificationResult_Success value)? success,
    TResult? Function(VerificationResult_Error value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VerificationResult_Success value)? success,
    TResult Function(VerificationResult_Error value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class VerificationResult_Success extends VerificationResult {
  const factory VerificationResult_Success() = _$VerificationResult_SuccessImpl;
  const VerificationResult_Success._() : super._();
}

/// @nodoc
abstract class _$$VerificationResult_ErrorImplCopyWith<$Res> {
  factory _$$VerificationResult_ErrorImplCopyWith(
          _$VerificationResult_ErrorImpl value,
          $Res Function(_$VerificationResult_ErrorImpl) then) =
      __$$VerificationResult_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$VerificationResult_ErrorImplCopyWithImpl<$Res>
    extends _$VerificationResultCopyWithImpl<$Res,
        _$VerificationResult_ErrorImpl>
    implements _$$VerificationResult_ErrorImplCopyWith<$Res> {
  __$$VerificationResult_ErrorImplCopyWithImpl(
      _$VerificationResult_ErrorImpl _value,
      $Res Function(_$VerificationResult_ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$VerificationResult_ErrorImpl(
      error: null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$VerificationResult_ErrorImpl extends VerificationResult_Error {
  const _$VerificationResult_ErrorImpl({required this.error}) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'VerificationResult.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerificationResult_ErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerificationResult_ErrorImplCopyWith<_$VerificationResult_ErrorImpl>
      get copyWith => __$$VerificationResult_ErrorImplCopyWithImpl<
          _$VerificationResult_ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() success,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? success,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VerificationResult_Success value) success,
    required TResult Function(VerificationResult_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VerificationResult_Success value)? success,
    TResult? Function(VerificationResult_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VerificationResult_Success value)? success,
    TResult Function(VerificationResult_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class VerificationResult_Error extends VerificationResult {
  const factory VerificationResult_Error({required final String error}) =
      _$VerificationResult_ErrorImpl;
  const VerificationResult_Error._() : super._();

  String get error;

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerificationResult_ErrorImplCopyWith<_$VerificationResult_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}
