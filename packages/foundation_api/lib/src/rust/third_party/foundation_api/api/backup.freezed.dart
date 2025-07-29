// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BackupShardResponse {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() success,
    required TResult Function(String field0) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? success,
    TResult? Function(String field0)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? success,
    TResult Function(String field0)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BackupShardResponse_Success value) success,
    required TResult Function(BackupShardResponse_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BackupShardResponse_Success value)? success,
    TResult? Function(BackupShardResponse_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BackupShardResponse_Success value)? success,
    TResult Function(BackupShardResponse_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupShardResponseCopyWith<$Res> {
  factory $BackupShardResponseCopyWith(
          BackupShardResponse value, $Res Function(BackupShardResponse) then) =
      _$BackupShardResponseCopyWithImpl<$Res, BackupShardResponse>;
}

/// @nodoc
class _$BackupShardResponseCopyWithImpl<$Res, $Val extends BackupShardResponse>
    implements $BackupShardResponseCopyWith<$Res> {
  _$BackupShardResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupShardResponse
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$BackupShardResponse_SuccessImplCopyWith<$Res> {
  factory _$$BackupShardResponse_SuccessImplCopyWith(
          _$BackupShardResponse_SuccessImpl value,
          $Res Function(_$BackupShardResponse_SuccessImpl) then) =
      __$$BackupShardResponse_SuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BackupShardResponse_SuccessImplCopyWithImpl<$Res>
    extends _$BackupShardResponseCopyWithImpl<$Res,
        _$BackupShardResponse_SuccessImpl>
    implements _$$BackupShardResponse_SuccessImplCopyWith<$Res> {
  __$$BackupShardResponse_SuccessImplCopyWithImpl(
      _$BackupShardResponse_SuccessImpl _value,
      $Res Function(_$BackupShardResponse_SuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackupShardResponse
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$BackupShardResponse_SuccessImpl extends BackupShardResponse_Success {
  const _$BackupShardResponse_SuccessImpl() : super._();

  @override
  String toString() {
    return 'BackupShardResponse.success()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupShardResponse_SuccessImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() success,
    required TResult Function(String field0) error,
  }) {
    return success();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? success,
    TResult? Function(String field0)? error,
  }) {
    return success?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? success,
    TResult Function(String field0)? error,
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
    required TResult Function(BackupShardResponse_Success value) success,
    required TResult Function(BackupShardResponse_Error value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BackupShardResponse_Success value)? success,
    TResult? Function(BackupShardResponse_Error value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BackupShardResponse_Success value)? success,
    TResult Function(BackupShardResponse_Error value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class BackupShardResponse_Success extends BackupShardResponse {
  const factory BackupShardResponse_Success() =
      _$BackupShardResponse_SuccessImpl;
  const BackupShardResponse_Success._() : super._();
}

/// @nodoc
abstract class _$$BackupShardResponse_ErrorImplCopyWith<$Res> {
  factory _$$BackupShardResponse_ErrorImplCopyWith(
          _$BackupShardResponse_ErrorImpl value,
          $Res Function(_$BackupShardResponse_ErrorImpl) then) =
      __$$BackupShardResponse_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$BackupShardResponse_ErrorImplCopyWithImpl<$Res>
    extends _$BackupShardResponseCopyWithImpl<$Res,
        _$BackupShardResponse_ErrorImpl>
    implements _$$BackupShardResponse_ErrorImplCopyWith<$Res> {
  __$$BackupShardResponse_ErrorImplCopyWithImpl(
      _$BackupShardResponse_ErrorImpl _value,
      $Res Function(_$BackupShardResponse_ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackupShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$BackupShardResponse_ErrorImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$BackupShardResponse_ErrorImpl extends BackupShardResponse_Error {
  const _$BackupShardResponse_ErrorImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'BackupShardResponse.error(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupShardResponse_ErrorImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of BackupShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupShardResponse_ErrorImplCopyWith<_$BackupShardResponse_ErrorImpl>
      get copyWith => __$$BackupShardResponse_ErrorImplCopyWithImpl<
          _$BackupShardResponse_ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() success,
    required TResult Function(String field0) error,
  }) {
    return error(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? success,
    TResult? Function(String field0)? error,
  }) {
    return error?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? success,
    TResult Function(String field0)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BackupShardResponse_Success value) success,
    required TResult Function(BackupShardResponse_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BackupShardResponse_Success value)? success,
    TResult? Function(BackupShardResponse_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BackupShardResponse_Success value)? success,
    TResult Function(BackupShardResponse_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class BackupShardResponse_Error extends BackupShardResponse {
  const factory BackupShardResponse_Error(final String field0) =
      _$BackupShardResponse_ErrorImpl;
  const BackupShardResponse_Error._() : super._();

  String get field0;

  /// Create a copy of BackupShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupShardResponse_ErrorImplCopyWith<_$BackupShardResponse_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RestoreShardResponse {
  Object get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Shard field0) success,
    required TResult Function(String field0) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Shard field0)? success,
    TResult? Function(String field0)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Shard field0)? success,
    TResult Function(String field0)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreShardResponse_Success value) success,
    required TResult Function(RestoreShardResponse_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreShardResponse_Success value)? success,
    TResult? Function(RestoreShardResponse_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreShardResponse_Success value)? success,
    TResult Function(RestoreShardResponse_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestoreShardResponseCopyWith<$Res> {
  factory $RestoreShardResponseCopyWith(RestoreShardResponse value,
          $Res Function(RestoreShardResponse) then) =
      _$RestoreShardResponseCopyWithImpl<$Res, RestoreShardResponse>;
}

/// @nodoc
class _$RestoreShardResponseCopyWithImpl<$Res,
        $Val extends RestoreShardResponse>
    implements $RestoreShardResponseCopyWith<$Res> {
  _$RestoreShardResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RestoreShardResponse_SuccessImplCopyWith<$Res> {
  factory _$$RestoreShardResponse_SuccessImplCopyWith(
          _$RestoreShardResponse_SuccessImpl value,
          $Res Function(_$RestoreShardResponse_SuccessImpl) then) =
      __$$RestoreShardResponse_SuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Shard field0});
}

/// @nodoc
class __$$RestoreShardResponse_SuccessImplCopyWithImpl<$Res>
    extends _$RestoreShardResponseCopyWithImpl<$Res,
        _$RestoreShardResponse_SuccessImpl>
    implements _$$RestoreShardResponse_SuccessImplCopyWith<$Res> {
  __$$RestoreShardResponse_SuccessImplCopyWithImpl(
      _$RestoreShardResponse_SuccessImpl _value,
      $Res Function(_$RestoreShardResponse_SuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$RestoreShardResponse_SuccessImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as Shard,
    ));
  }
}

/// @nodoc

class _$RestoreShardResponse_SuccessImpl extends RestoreShardResponse_Success {
  const _$RestoreShardResponse_SuccessImpl(this.field0) : super._();

  @override
  final Shard field0;

  @override
  String toString() {
    return 'RestoreShardResponse.success(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreShardResponse_SuccessImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestoreShardResponse_SuccessImplCopyWith<
          _$RestoreShardResponse_SuccessImpl>
      get copyWith => __$$RestoreShardResponse_SuccessImplCopyWithImpl<
          _$RestoreShardResponse_SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Shard field0) success,
    required TResult Function(String field0) error,
  }) {
    return success(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Shard field0)? success,
    TResult? Function(String field0)? error,
  }) {
    return success?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Shard field0)? success,
    TResult Function(String field0)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreShardResponse_Success value) success,
    required TResult Function(RestoreShardResponse_Error value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreShardResponse_Success value)? success,
    TResult? Function(RestoreShardResponse_Error value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreShardResponse_Success value)? success,
    TResult Function(RestoreShardResponse_Error value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class RestoreShardResponse_Success extends RestoreShardResponse {
  const factory RestoreShardResponse_Success(final Shard field0) =
      _$RestoreShardResponse_SuccessImpl;
  const RestoreShardResponse_Success._() : super._();

  @override
  Shard get field0;

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestoreShardResponse_SuccessImplCopyWith<
          _$RestoreShardResponse_SuccessImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RestoreShardResponse_ErrorImplCopyWith<$Res> {
  factory _$$RestoreShardResponse_ErrorImplCopyWith(
          _$RestoreShardResponse_ErrorImpl value,
          $Res Function(_$RestoreShardResponse_ErrorImpl) then) =
      __$$RestoreShardResponse_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$RestoreShardResponse_ErrorImplCopyWithImpl<$Res>
    extends _$RestoreShardResponseCopyWithImpl<$Res,
        _$RestoreShardResponse_ErrorImpl>
    implements _$$RestoreShardResponse_ErrorImplCopyWith<$Res> {
  __$$RestoreShardResponse_ErrorImplCopyWithImpl(
      _$RestoreShardResponse_ErrorImpl _value,
      $Res Function(_$RestoreShardResponse_ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$RestoreShardResponse_ErrorImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RestoreShardResponse_ErrorImpl extends RestoreShardResponse_Error {
  const _$RestoreShardResponse_ErrorImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'RestoreShardResponse.error(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreShardResponse_ErrorImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestoreShardResponse_ErrorImplCopyWith<_$RestoreShardResponse_ErrorImpl>
      get copyWith => __$$RestoreShardResponse_ErrorImplCopyWithImpl<
          _$RestoreShardResponse_ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Shard field0) success,
    required TResult Function(String field0) error,
  }) {
    return error(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Shard field0)? success,
    TResult? Function(String field0)? error,
  }) {
    return error?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Shard field0)? success,
    TResult Function(String field0)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreShardResponse_Success value) success,
    required TResult Function(RestoreShardResponse_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreShardResponse_Success value)? success,
    TResult? Function(RestoreShardResponse_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreShardResponse_Success value)? success,
    TResult Function(RestoreShardResponse_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class RestoreShardResponse_Error extends RestoreShardResponse {
  const factory RestoreShardResponse_Error(final String field0) =
      _$RestoreShardResponse_ErrorImpl;
  const RestoreShardResponse_Error._() : super._();

  @override
  String get field0;

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestoreShardResponse_ErrorImplCopyWith<_$RestoreShardResponse_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}
