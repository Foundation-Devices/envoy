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
  $Res call({String error});
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
    Object? error = null,
  }) {
    return _then(_$BackupShardResponse_ErrorImpl(
      error: null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$BackupShardResponse_ErrorImpl extends BackupShardResponse_Error {
  const _$BackupShardResponse_ErrorImpl({required this.error}) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'BackupShardResponse.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupShardResponse_ErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

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
  const factory BackupShardResponse_Error({required final String error}) =
      _$BackupShardResponse_ErrorImpl;
  const BackupShardResponse_Error._() : super._();

  String get error;

  /// Create a copy of BackupShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupShardResponse_ErrorImplCopyWith<_$BackupShardResponse_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CreateMagicBackupEvent {
  Object get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(StartMagicBackup field0) start,
    required TResult Function(BackupChunk field0) chunk,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(StartMagicBackup field0)? start,
    TResult? Function(BackupChunk field0)? chunk,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(StartMagicBackup field0)? start,
    TResult Function(BackupChunk field0)? chunk,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CreateMagicBackupEvent_Start value) start,
    required TResult Function(CreateMagicBackupEvent_Chunk value) chunk,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupEvent_Start value)? start,
    TResult? Function(CreateMagicBackupEvent_Chunk value)? chunk,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateMagicBackupEvent_Start value)? start,
    TResult Function(CreateMagicBackupEvent_Chunk value)? chunk,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateMagicBackupEventCopyWith<$Res> {
  factory $CreateMagicBackupEventCopyWith(CreateMagicBackupEvent value,
          $Res Function(CreateMagicBackupEvent) then) =
      _$CreateMagicBackupEventCopyWithImpl<$Res, CreateMagicBackupEvent>;
}

/// @nodoc
class _$CreateMagicBackupEventCopyWithImpl<$Res,
        $Val extends CreateMagicBackupEvent>
    implements $CreateMagicBackupEventCopyWith<$Res> {
  _$CreateMagicBackupEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$CreateMagicBackupEvent_StartImplCopyWith<$Res> {
  factory _$$CreateMagicBackupEvent_StartImplCopyWith(
          _$CreateMagicBackupEvent_StartImpl value,
          $Res Function(_$CreateMagicBackupEvent_StartImpl) then) =
      __$$CreateMagicBackupEvent_StartImplCopyWithImpl<$Res>;
  @useResult
  $Res call({StartMagicBackup field0});
}

/// @nodoc
class __$$CreateMagicBackupEvent_StartImplCopyWithImpl<$Res>
    extends _$CreateMagicBackupEventCopyWithImpl<$Res,
        _$CreateMagicBackupEvent_StartImpl>
    implements _$$CreateMagicBackupEvent_StartImplCopyWith<$Res> {
  __$$CreateMagicBackupEvent_StartImplCopyWithImpl(
      _$CreateMagicBackupEvent_StartImpl _value,
      $Res Function(_$CreateMagicBackupEvent_StartImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$CreateMagicBackupEvent_StartImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as StartMagicBackup,
    ));
  }
}

/// @nodoc

class _$CreateMagicBackupEvent_StartImpl extends CreateMagicBackupEvent_Start {
  const _$CreateMagicBackupEvent_StartImpl(this.field0) : super._();

  @override
  final StartMagicBackup field0;

  @override
  String toString() {
    return 'CreateMagicBackupEvent.start(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateMagicBackupEvent_StartImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of CreateMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateMagicBackupEvent_StartImplCopyWith<
          _$CreateMagicBackupEvent_StartImpl>
      get copyWith => __$$CreateMagicBackupEvent_StartImplCopyWithImpl<
          _$CreateMagicBackupEvent_StartImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(StartMagicBackup field0) start,
    required TResult Function(BackupChunk field0) chunk,
  }) {
    return start(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(StartMagicBackup field0)? start,
    TResult? Function(BackupChunk field0)? chunk,
  }) {
    return start?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(StartMagicBackup field0)? start,
    TResult Function(BackupChunk field0)? chunk,
    required TResult orElse(),
  }) {
    if (start != null) {
      return start(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CreateMagicBackupEvent_Start value) start,
    required TResult Function(CreateMagicBackupEvent_Chunk value) chunk,
  }) {
    return start(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupEvent_Start value)? start,
    TResult? Function(CreateMagicBackupEvent_Chunk value)? chunk,
  }) {
    return start?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateMagicBackupEvent_Start value)? start,
    TResult Function(CreateMagicBackupEvent_Chunk value)? chunk,
    required TResult orElse(),
  }) {
    if (start != null) {
      return start(this);
    }
    return orElse();
  }
}

abstract class CreateMagicBackupEvent_Start extends CreateMagicBackupEvent {
  const factory CreateMagicBackupEvent_Start(final StartMagicBackup field0) =
      _$CreateMagicBackupEvent_StartImpl;
  const CreateMagicBackupEvent_Start._() : super._();

  @override
  StartMagicBackup get field0;

  /// Create a copy of CreateMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateMagicBackupEvent_StartImplCopyWith<
          _$CreateMagicBackupEvent_StartImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CreateMagicBackupEvent_ChunkImplCopyWith<$Res> {
  factory _$$CreateMagicBackupEvent_ChunkImplCopyWith(
          _$CreateMagicBackupEvent_ChunkImpl value,
          $Res Function(_$CreateMagicBackupEvent_ChunkImpl) then) =
      __$$CreateMagicBackupEvent_ChunkImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BackupChunk field0});
}

/// @nodoc
class __$$CreateMagicBackupEvent_ChunkImplCopyWithImpl<$Res>
    extends _$CreateMagicBackupEventCopyWithImpl<$Res,
        _$CreateMagicBackupEvent_ChunkImpl>
    implements _$$CreateMagicBackupEvent_ChunkImplCopyWith<$Res> {
  __$$CreateMagicBackupEvent_ChunkImplCopyWithImpl(
      _$CreateMagicBackupEvent_ChunkImpl _value,
      $Res Function(_$CreateMagicBackupEvent_ChunkImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$CreateMagicBackupEvent_ChunkImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BackupChunk,
    ));
  }
}

/// @nodoc

class _$CreateMagicBackupEvent_ChunkImpl extends CreateMagicBackupEvent_Chunk {
  const _$CreateMagicBackupEvent_ChunkImpl(this.field0) : super._();

  @override
  final BackupChunk field0;

  @override
  String toString() {
    return 'CreateMagicBackupEvent.chunk(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateMagicBackupEvent_ChunkImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of CreateMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateMagicBackupEvent_ChunkImplCopyWith<
          _$CreateMagicBackupEvent_ChunkImpl>
      get copyWith => __$$CreateMagicBackupEvent_ChunkImplCopyWithImpl<
          _$CreateMagicBackupEvent_ChunkImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(StartMagicBackup field0) start,
    required TResult Function(BackupChunk field0) chunk,
  }) {
    return chunk(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(StartMagicBackup field0)? start,
    TResult? Function(BackupChunk field0)? chunk,
  }) {
    return chunk?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(StartMagicBackup field0)? start,
    TResult Function(BackupChunk field0)? chunk,
    required TResult orElse(),
  }) {
    if (chunk != null) {
      return chunk(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CreateMagicBackupEvent_Start value) start,
    required TResult Function(CreateMagicBackupEvent_Chunk value) chunk,
  }) {
    return chunk(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupEvent_Start value)? start,
    TResult? Function(CreateMagicBackupEvent_Chunk value)? chunk,
  }) {
    return chunk?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateMagicBackupEvent_Start value)? start,
    TResult Function(CreateMagicBackupEvent_Chunk value)? chunk,
    required TResult orElse(),
  }) {
    if (chunk != null) {
      return chunk(this);
    }
    return orElse();
  }
}

abstract class CreateMagicBackupEvent_Chunk extends CreateMagicBackupEvent {
  const factory CreateMagicBackupEvent_Chunk(final BackupChunk field0) =
      _$CreateMagicBackupEvent_ChunkImpl;
  const CreateMagicBackupEvent_Chunk._() : super._();

  @override
  BackupChunk get field0;

  /// Create a copy of CreateMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateMagicBackupEvent_ChunkImplCopyWith<
          _$CreateMagicBackupEvent_ChunkImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CreateMagicBackupResult {
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
    required TResult Function(CreateMagicBackupResult_Success value) success,
    required TResult Function(CreateMagicBackupResult_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupResult_Success value)? success,
    TResult? Function(CreateMagicBackupResult_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateMagicBackupResult_Success value)? success,
    TResult Function(CreateMagicBackupResult_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateMagicBackupResultCopyWith<$Res> {
  factory $CreateMagicBackupResultCopyWith(CreateMagicBackupResult value,
          $Res Function(CreateMagicBackupResult) then) =
      _$CreateMagicBackupResultCopyWithImpl<$Res, CreateMagicBackupResult>;
}

/// @nodoc
class _$CreateMagicBackupResultCopyWithImpl<$Res,
        $Val extends CreateMagicBackupResult>
    implements $CreateMagicBackupResultCopyWith<$Res> {
  _$CreateMagicBackupResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$CreateMagicBackupResult_SuccessImplCopyWith<$Res> {
  factory _$$CreateMagicBackupResult_SuccessImplCopyWith(
          _$CreateMagicBackupResult_SuccessImpl value,
          $Res Function(_$CreateMagicBackupResult_SuccessImpl) then) =
      __$$CreateMagicBackupResult_SuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CreateMagicBackupResult_SuccessImplCopyWithImpl<$Res>
    extends _$CreateMagicBackupResultCopyWithImpl<$Res,
        _$CreateMagicBackupResult_SuccessImpl>
    implements _$$CreateMagicBackupResult_SuccessImplCopyWith<$Res> {
  __$$CreateMagicBackupResult_SuccessImplCopyWithImpl(
      _$CreateMagicBackupResult_SuccessImpl _value,
      $Res Function(_$CreateMagicBackupResult_SuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CreateMagicBackupResult_SuccessImpl
    extends CreateMagicBackupResult_Success {
  const _$CreateMagicBackupResult_SuccessImpl() : super._();

  @override
  String toString() {
    return 'CreateMagicBackupResult.success()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateMagicBackupResult_SuccessImpl);
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
    required TResult Function(CreateMagicBackupResult_Success value) success,
    required TResult Function(CreateMagicBackupResult_Error value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupResult_Success value)? success,
    TResult? Function(CreateMagicBackupResult_Error value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateMagicBackupResult_Success value)? success,
    TResult Function(CreateMagicBackupResult_Error value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class CreateMagicBackupResult_Success extends CreateMagicBackupResult {
  const factory CreateMagicBackupResult_Success() =
      _$CreateMagicBackupResult_SuccessImpl;
  const CreateMagicBackupResult_Success._() : super._();
}

/// @nodoc
abstract class _$$CreateMagicBackupResult_ErrorImplCopyWith<$Res> {
  factory _$$CreateMagicBackupResult_ErrorImplCopyWith(
          _$CreateMagicBackupResult_ErrorImpl value,
          $Res Function(_$CreateMagicBackupResult_ErrorImpl) then) =
      __$$CreateMagicBackupResult_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$CreateMagicBackupResult_ErrorImplCopyWithImpl<$Res>
    extends _$CreateMagicBackupResultCopyWithImpl<$Res,
        _$CreateMagicBackupResult_ErrorImpl>
    implements _$$CreateMagicBackupResult_ErrorImplCopyWith<$Res> {
  __$$CreateMagicBackupResult_ErrorImplCopyWithImpl(
      _$CreateMagicBackupResult_ErrorImpl _value,
      $Res Function(_$CreateMagicBackupResult_ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$CreateMagicBackupResult_ErrorImpl(
      error: null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CreateMagicBackupResult_ErrorImpl
    extends CreateMagicBackupResult_Error {
  const _$CreateMagicBackupResult_ErrorImpl({required this.error}) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'CreateMagicBackupResult.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateMagicBackupResult_ErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of CreateMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateMagicBackupResult_ErrorImplCopyWith<
          _$CreateMagicBackupResult_ErrorImpl>
      get copyWith => __$$CreateMagicBackupResult_ErrorImplCopyWithImpl<
          _$CreateMagicBackupResult_ErrorImpl>(this, _$identity);

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
    required TResult Function(CreateMagicBackupResult_Success value) success,
    required TResult Function(CreateMagicBackupResult_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupResult_Success value)? success,
    TResult? Function(CreateMagicBackupResult_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateMagicBackupResult_Success value)? success,
    TResult Function(CreateMagicBackupResult_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class CreateMagicBackupResult_Error extends CreateMagicBackupResult {
  const factory CreateMagicBackupResult_Error({required final String error}) =
      _$CreateMagicBackupResult_ErrorImpl;
  const CreateMagicBackupResult_Error._() : super._();

  String get error;

  /// Create a copy of CreateMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateMagicBackupResult_ErrorImplCopyWith<
          _$CreateMagicBackupResult_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MagicBackupRequestV2 {
  Object get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CreateMagicBackupV2 field0) create,
    required TResult Function(GetMagicBackupV2 field0) get_,
    required TResult Function(DeleteMagicBackupV2 field0) delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupV2 field0)? create,
    TResult? Function(GetMagicBackupV2 field0)? get_,
    TResult? Function(DeleteMagicBackupV2 field0)? delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CreateMagicBackupV2 field0)? create,
    TResult Function(GetMagicBackupV2 field0)? get_,
    TResult Function(DeleteMagicBackupV2 field0)? delete,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MagicBackupRequestV2_Create value) create,
    required TResult Function(MagicBackupRequestV2_Get value) get_,
    required TResult Function(MagicBackupRequestV2_Delete value) delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MagicBackupRequestV2_Create value)? create,
    TResult? Function(MagicBackupRequestV2_Get value)? get_,
    TResult? Function(MagicBackupRequestV2_Delete value)? delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MagicBackupRequestV2_Create value)? create,
    TResult Function(MagicBackupRequestV2_Get value)? get_,
    TResult Function(MagicBackupRequestV2_Delete value)? delete,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MagicBackupRequestV2CopyWith<$Res> {
  factory $MagicBackupRequestV2CopyWith(MagicBackupRequestV2 value,
          $Res Function(MagicBackupRequestV2) then) =
      _$MagicBackupRequestV2CopyWithImpl<$Res, MagicBackupRequestV2>;
}

/// @nodoc
class _$MagicBackupRequestV2CopyWithImpl<$Res,
        $Val extends MagicBackupRequestV2>
    implements $MagicBackupRequestV2CopyWith<$Res> {
  _$MagicBackupRequestV2CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$MagicBackupRequestV2_CreateImplCopyWith<$Res> {
  factory _$$MagicBackupRequestV2_CreateImplCopyWith(
          _$MagicBackupRequestV2_CreateImpl value,
          $Res Function(_$MagicBackupRequestV2_CreateImpl) then) =
      __$$MagicBackupRequestV2_CreateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CreateMagicBackupV2 field0});
}

/// @nodoc
class __$$MagicBackupRequestV2_CreateImplCopyWithImpl<$Res>
    extends _$MagicBackupRequestV2CopyWithImpl<$Res,
        _$MagicBackupRequestV2_CreateImpl>
    implements _$$MagicBackupRequestV2_CreateImplCopyWith<$Res> {
  __$$MagicBackupRequestV2_CreateImplCopyWithImpl(
      _$MagicBackupRequestV2_CreateImpl _value,
      $Res Function(_$MagicBackupRequestV2_CreateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$MagicBackupRequestV2_CreateImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as CreateMagicBackupV2,
    ));
  }
}

/// @nodoc

class _$MagicBackupRequestV2_CreateImpl extends MagicBackupRequestV2_Create {
  const _$MagicBackupRequestV2_CreateImpl(this.field0) : super._();

  @override
  final CreateMagicBackupV2 field0;

  @override
  String toString() {
    return 'MagicBackupRequestV2.create(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MagicBackupRequestV2_CreateImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MagicBackupRequestV2_CreateImplCopyWith<_$MagicBackupRequestV2_CreateImpl>
      get copyWith => __$$MagicBackupRequestV2_CreateImplCopyWithImpl<
          _$MagicBackupRequestV2_CreateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CreateMagicBackupV2 field0) create,
    required TResult Function(GetMagicBackupV2 field0) get_,
    required TResult Function(DeleteMagicBackupV2 field0) delete,
  }) {
    return create(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupV2 field0)? create,
    TResult? Function(GetMagicBackupV2 field0)? get_,
    TResult? Function(DeleteMagicBackupV2 field0)? delete,
  }) {
    return create?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CreateMagicBackupV2 field0)? create,
    TResult Function(GetMagicBackupV2 field0)? get_,
    TResult Function(DeleteMagicBackupV2 field0)? delete,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MagicBackupRequestV2_Create value) create,
    required TResult Function(MagicBackupRequestV2_Get value) get_,
    required TResult Function(MagicBackupRequestV2_Delete value) delete,
  }) {
    return create(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MagicBackupRequestV2_Create value)? create,
    TResult? Function(MagicBackupRequestV2_Get value)? get_,
    TResult? Function(MagicBackupRequestV2_Delete value)? delete,
  }) {
    return create?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MagicBackupRequestV2_Create value)? create,
    TResult Function(MagicBackupRequestV2_Get value)? get_,
    TResult Function(MagicBackupRequestV2_Delete value)? delete,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(this);
    }
    return orElse();
  }
}

abstract class MagicBackupRequestV2_Create extends MagicBackupRequestV2 {
  const factory MagicBackupRequestV2_Create(final CreateMagicBackupV2 field0) =
      _$MagicBackupRequestV2_CreateImpl;
  const MagicBackupRequestV2_Create._() : super._();

  @override
  CreateMagicBackupV2 get field0;

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MagicBackupRequestV2_CreateImplCopyWith<_$MagicBackupRequestV2_CreateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MagicBackupRequestV2_GetImplCopyWith<$Res> {
  factory _$$MagicBackupRequestV2_GetImplCopyWith(
          _$MagicBackupRequestV2_GetImpl value,
          $Res Function(_$MagicBackupRequestV2_GetImpl) then) =
      __$$MagicBackupRequestV2_GetImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GetMagicBackupV2 field0});
}

/// @nodoc
class __$$MagicBackupRequestV2_GetImplCopyWithImpl<$Res>
    extends _$MagicBackupRequestV2CopyWithImpl<$Res,
        _$MagicBackupRequestV2_GetImpl>
    implements _$$MagicBackupRequestV2_GetImplCopyWith<$Res> {
  __$$MagicBackupRequestV2_GetImplCopyWithImpl(
      _$MagicBackupRequestV2_GetImpl _value,
      $Res Function(_$MagicBackupRequestV2_GetImpl) _then)
      : super(_value, _then);

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$MagicBackupRequestV2_GetImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as GetMagicBackupV2,
    ));
  }
}

/// @nodoc

class _$MagicBackupRequestV2_GetImpl extends MagicBackupRequestV2_Get {
  const _$MagicBackupRequestV2_GetImpl(this.field0) : super._();

  @override
  final GetMagicBackupV2 field0;

  @override
  String toString() {
    return 'MagicBackupRequestV2.get_(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MagicBackupRequestV2_GetImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MagicBackupRequestV2_GetImplCopyWith<_$MagicBackupRequestV2_GetImpl>
      get copyWith => __$$MagicBackupRequestV2_GetImplCopyWithImpl<
          _$MagicBackupRequestV2_GetImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CreateMagicBackupV2 field0) create,
    required TResult Function(GetMagicBackupV2 field0) get_,
    required TResult Function(DeleteMagicBackupV2 field0) delete,
  }) {
    return get_(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupV2 field0)? create,
    TResult? Function(GetMagicBackupV2 field0)? get_,
    TResult? Function(DeleteMagicBackupV2 field0)? delete,
  }) {
    return get_?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CreateMagicBackupV2 field0)? create,
    TResult Function(GetMagicBackupV2 field0)? get_,
    TResult Function(DeleteMagicBackupV2 field0)? delete,
    required TResult orElse(),
  }) {
    if (get_ != null) {
      return get_(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MagicBackupRequestV2_Create value) create,
    required TResult Function(MagicBackupRequestV2_Get value) get_,
    required TResult Function(MagicBackupRequestV2_Delete value) delete,
  }) {
    return get_(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MagicBackupRequestV2_Create value)? create,
    TResult? Function(MagicBackupRequestV2_Get value)? get_,
    TResult? Function(MagicBackupRequestV2_Delete value)? delete,
  }) {
    return get_?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MagicBackupRequestV2_Create value)? create,
    TResult Function(MagicBackupRequestV2_Get value)? get_,
    TResult Function(MagicBackupRequestV2_Delete value)? delete,
    required TResult orElse(),
  }) {
    if (get_ != null) {
      return get_(this);
    }
    return orElse();
  }
}

abstract class MagicBackupRequestV2_Get extends MagicBackupRequestV2 {
  const factory MagicBackupRequestV2_Get(final GetMagicBackupV2 field0) =
      _$MagicBackupRequestV2_GetImpl;
  const MagicBackupRequestV2_Get._() : super._();

  @override
  GetMagicBackupV2 get field0;

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MagicBackupRequestV2_GetImplCopyWith<_$MagicBackupRequestV2_GetImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MagicBackupRequestV2_DeleteImplCopyWith<$Res> {
  factory _$$MagicBackupRequestV2_DeleteImplCopyWith(
          _$MagicBackupRequestV2_DeleteImpl value,
          $Res Function(_$MagicBackupRequestV2_DeleteImpl) then) =
      __$$MagicBackupRequestV2_DeleteImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DeleteMagicBackupV2 field0});
}

/// @nodoc
class __$$MagicBackupRequestV2_DeleteImplCopyWithImpl<$Res>
    extends _$MagicBackupRequestV2CopyWithImpl<$Res,
        _$MagicBackupRequestV2_DeleteImpl>
    implements _$$MagicBackupRequestV2_DeleteImplCopyWith<$Res> {
  __$$MagicBackupRequestV2_DeleteImplCopyWithImpl(
      _$MagicBackupRequestV2_DeleteImpl _value,
      $Res Function(_$MagicBackupRequestV2_DeleteImpl) _then)
      : super(_value, _then);

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$MagicBackupRequestV2_DeleteImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as DeleteMagicBackupV2,
    ));
  }
}

/// @nodoc

class _$MagicBackupRequestV2_DeleteImpl extends MagicBackupRequestV2_Delete {
  const _$MagicBackupRequestV2_DeleteImpl(this.field0) : super._();

  @override
  final DeleteMagicBackupV2 field0;

  @override
  String toString() {
    return 'MagicBackupRequestV2.delete(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MagicBackupRequestV2_DeleteImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MagicBackupRequestV2_DeleteImplCopyWith<_$MagicBackupRequestV2_DeleteImpl>
      get copyWith => __$$MagicBackupRequestV2_DeleteImplCopyWithImpl<
          _$MagicBackupRequestV2_DeleteImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CreateMagicBackupV2 field0) create,
    required TResult Function(GetMagicBackupV2 field0) get_,
    required TResult Function(DeleteMagicBackupV2 field0) delete,
  }) {
    return delete(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupV2 field0)? create,
    TResult? Function(GetMagicBackupV2 field0)? get_,
    TResult? Function(DeleteMagicBackupV2 field0)? delete,
  }) {
    return delete?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CreateMagicBackupV2 field0)? create,
    TResult Function(GetMagicBackupV2 field0)? get_,
    TResult Function(DeleteMagicBackupV2 field0)? delete,
    required TResult orElse(),
  }) {
    if (delete != null) {
      return delete(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MagicBackupRequestV2_Create value) create,
    required TResult Function(MagicBackupRequestV2_Get value) get_,
    required TResult Function(MagicBackupRequestV2_Delete value) delete,
  }) {
    return delete(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MagicBackupRequestV2_Create value)? create,
    TResult? Function(MagicBackupRequestV2_Get value)? get_,
    TResult? Function(MagicBackupRequestV2_Delete value)? delete,
  }) {
    return delete?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MagicBackupRequestV2_Create value)? create,
    TResult Function(MagicBackupRequestV2_Get value)? get_,
    TResult Function(MagicBackupRequestV2_Delete value)? delete,
    required TResult orElse(),
  }) {
    if (delete != null) {
      return delete(this);
    }
    return orElse();
  }
}

abstract class MagicBackupRequestV2_Delete extends MagicBackupRequestV2 {
  const factory MagicBackupRequestV2_Delete(final DeleteMagicBackupV2 field0) =
      _$MagicBackupRequestV2_DeleteImpl;
  const MagicBackupRequestV2_Delete._() : super._();

  @override
  DeleteMagicBackupV2 get field0;

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MagicBackupRequestV2_DeleteImplCopyWith<_$MagicBackupRequestV2_DeleteImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MagicBackupResponseV2 {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() created,
    required TResult Function(Uint8List data) backup,
    required TResult Function() deleted,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? created,
    TResult? Function(Uint8List data)? backup,
    TResult? Function()? deleted,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? created,
    TResult Function(Uint8List data)? backup,
    TResult Function()? deleted,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MagicBackupResponseV2_Created value) created,
    required TResult Function(MagicBackupResponseV2_Backup value) backup,
    required TResult Function(MagicBackupResponseV2_Deleted value) deleted,
    required TResult Function(MagicBackupResponseV2_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MagicBackupResponseV2_Created value)? created,
    TResult? Function(MagicBackupResponseV2_Backup value)? backup,
    TResult? Function(MagicBackupResponseV2_Deleted value)? deleted,
    TResult? Function(MagicBackupResponseV2_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MagicBackupResponseV2_Created value)? created,
    TResult Function(MagicBackupResponseV2_Backup value)? backup,
    TResult Function(MagicBackupResponseV2_Deleted value)? deleted,
    TResult Function(MagicBackupResponseV2_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MagicBackupResponseV2CopyWith<$Res> {
  factory $MagicBackupResponseV2CopyWith(MagicBackupResponseV2 value,
          $Res Function(MagicBackupResponseV2) then) =
      _$MagicBackupResponseV2CopyWithImpl<$Res, MagicBackupResponseV2>;
}

/// @nodoc
class _$MagicBackupResponseV2CopyWithImpl<$Res,
        $Val extends MagicBackupResponseV2>
    implements $MagicBackupResponseV2CopyWith<$Res> {
  _$MagicBackupResponseV2CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$MagicBackupResponseV2_CreatedImplCopyWith<$Res> {
  factory _$$MagicBackupResponseV2_CreatedImplCopyWith(
          _$MagicBackupResponseV2_CreatedImpl value,
          $Res Function(_$MagicBackupResponseV2_CreatedImpl) then) =
      __$$MagicBackupResponseV2_CreatedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MagicBackupResponseV2_CreatedImplCopyWithImpl<$Res>
    extends _$MagicBackupResponseV2CopyWithImpl<$Res,
        _$MagicBackupResponseV2_CreatedImpl>
    implements _$$MagicBackupResponseV2_CreatedImplCopyWith<$Res> {
  __$$MagicBackupResponseV2_CreatedImplCopyWithImpl(
      _$MagicBackupResponseV2_CreatedImpl _value,
      $Res Function(_$MagicBackupResponseV2_CreatedImpl) _then)
      : super(_value, _then);

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$MagicBackupResponseV2_CreatedImpl
    extends MagicBackupResponseV2_Created {
  const _$MagicBackupResponseV2_CreatedImpl() : super._();

  @override
  String toString() {
    return 'MagicBackupResponseV2.created()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MagicBackupResponseV2_CreatedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() created,
    required TResult Function(Uint8List data) backup,
    required TResult Function() deleted,
    required TResult Function(String error) error,
  }) {
    return created();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? created,
    TResult? Function(Uint8List data)? backup,
    TResult? Function()? deleted,
    TResult? Function(String error)? error,
  }) {
    return created?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? created,
    TResult Function(Uint8List data)? backup,
    TResult Function()? deleted,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (created != null) {
      return created();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MagicBackupResponseV2_Created value) created,
    required TResult Function(MagicBackupResponseV2_Backup value) backup,
    required TResult Function(MagicBackupResponseV2_Deleted value) deleted,
    required TResult Function(MagicBackupResponseV2_Error value) error,
  }) {
    return created(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MagicBackupResponseV2_Created value)? created,
    TResult? Function(MagicBackupResponseV2_Backup value)? backup,
    TResult? Function(MagicBackupResponseV2_Deleted value)? deleted,
    TResult? Function(MagicBackupResponseV2_Error value)? error,
  }) {
    return created?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MagicBackupResponseV2_Created value)? created,
    TResult Function(MagicBackupResponseV2_Backup value)? backup,
    TResult Function(MagicBackupResponseV2_Deleted value)? deleted,
    TResult Function(MagicBackupResponseV2_Error value)? error,
    required TResult orElse(),
  }) {
    if (created != null) {
      return created(this);
    }
    return orElse();
  }
}

abstract class MagicBackupResponseV2_Created extends MagicBackupResponseV2 {
  const factory MagicBackupResponseV2_Created() =
      _$MagicBackupResponseV2_CreatedImpl;
  const MagicBackupResponseV2_Created._() : super._();
}

/// @nodoc
abstract class _$$MagicBackupResponseV2_BackupImplCopyWith<$Res> {
  factory _$$MagicBackupResponseV2_BackupImplCopyWith(
          _$MagicBackupResponseV2_BackupImpl value,
          $Res Function(_$MagicBackupResponseV2_BackupImpl) then) =
      __$$MagicBackupResponseV2_BackupImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Uint8List data});
}

/// @nodoc
class __$$MagicBackupResponseV2_BackupImplCopyWithImpl<$Res>
    extends _$MagicBackupResponseV2CopyWithImpl<$Res,
        _$MagicBackupResponseV2_BackupImpl>
    implements _$$MagicBackupResponseV2_BackupImplCopyWith<$Res> {
  __$$MagicBackupResponseV2_BackupImplCopyWithImpl(
      _$MagicBackupResponseV2_BackupImpl _value,
      $Res Function(_$MagicBackupResponseV2_BackupImpl) _then)
      : super(_value, _then);

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$MagicBackupResponseV2_BackupImpl(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ));
  }
}

/// @nodoc

class _$MagicBackupResponseV2_BackupImpl extends MagicBackupResponseV2_Backup {
  const _$MagicBackupResponseV2_BackupImpl({required this.data}) : super._();

  @override
  final Uint8List data;

  @override
  String toString() {
    return 'MagicBackupResponseV2.backup(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MagicBackupResponseV2_BackupImpl &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MagicBackupResponseV2_BackupImplCopyWith<
          _$MagicBackupResponseV2_BackupImpl>
      get copyWith => __$$MagicBackupResponseV2_BackupImplCopyWithImpl<
          _$MagicBackupResponseV2_BackupImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() created,
    required TResult Function(Uint8List data) backup,
    required TResult Function() deleted,
    required TResult Function(String error) error,
  }) {
    return backup(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? created,
    TResult? Function(Uint8List data)? backup,
    TResult? Function()? deleted,
    TResult? Function(String error)? error,
  }) {
    return backup?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? created,
    TResult Function(Uint8List data)? backup,
    TResult Function()? deleted,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (backup != null) {
      return backup(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MagicBackupResponseV2_Created value) created,
    required TResult Function(MagicBackupResponseV2_Backup value) backup,
    required TResult Function(MagicBackupResponseV2_Deleted value) deleted,
    required TResult Function(MagicBackupResponseV2_Error value) error,
  }) {
    return backup(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MagicBackupResponseV2_Created value)? created,
    TResult? Function(MagicBackupResponseV2_Backup value)? backup,
    TResult? Function(MagicBackupResponseV2_Deleted value)? deleted,
    TResult? Function(MagicBackupResponseV2_Error value)? error,
  }) {
    return backup?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MagicBackupResponseV2_Created value)? created,
    TResult Function(MagicBackupResponseV2_Backup value)? backup,
    TResult Function(MagicBackupResponseV2_Deleted value)? deleted,
    TResult Function(MagicBackupResponseV2_Error value)? error,
    required TResult orElse(),
  }) {
    if (backup != null) {
      return backup(this);
    }
    return orElse();
  }
}

abstract class MagicBackupResponseV2_Backup extends MagicBackupResponseV2 {
  const factory MagicBackupResponseV2_Backup({required final Uint8List data}) =
      _$MagicBackupResponseV2_BackupImpl;
  const MagicBackupResponseV2_Backup._() : super._();

  Uint8List get data;

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MagicBackupResponseV2_BackupImplCopyWith<
          _$MagicBackupResponseV2_BackupImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MagicBackupResponseV2_DeletedImplCopyWith<$Res> {
  factory _$$MagicBackupResponseV2_DeletedImplCopyWith(
          _$MagicBackupResponseV2_DeletedImpl value,
          $Res Function(_$MagicBackupResponseV2_DeletedImpl) then) =
      __$$MagicBackupResponseV2_DeletedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MagicBackupResponseV2_DeletedImplCopyWithImpl<$Res>
    extends _$MagicBackupResponseV2CopyWithImpl<$Res,
        _$MagicBackupResponseV2_DeletedImpl>
    implements _$$MagicBackupResponseV2_DeletedImplCopyWith<$Res> {
  __$$MagicBackupResponseV2_DeletedImplCopyWithImpl(
      _$MagicBackupResponseV2_DeletedImpl _value,
      $Res Function(_$MagicBackupResponseV2_DeletedImpl) _then)
      : super(_value, _then);

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$MagicBackupResponseV2_DeletedImpl
    extends MagicBackupResponseV2_Deleted {
  const _$MagicBackupResponseV2_DeletedImpl() : super._();

  @override
  String toString() {
    return 'MagicBackupResponseV2.deleted()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MagicBackupResponseV2_DeletedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() created,
    required TResult Function(Uint8List data) backup,
    required TResult Function() deleted,
    required TResult Function(String error) error,
  }) {
    return deleted();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? created,
    TResult? Function(Uint8List data)? backup,
    TResult? Function()? deleted,
    TResult? Function(String error)? error,
  }) {
    return deleted?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? created,
    TResult Function(Uint8List data)? backup,
    TResult Function()? deleted,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (deleted != null) {
      return deleted();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MagicBackupResponseV2_Created value) created,
    required TResult Function(MagicBackupResponseV2_Backup value) backup,
    required TResult Function(MagicBackupResponseV2_Deleted value) deleted,
    required TResult Function(MagicBackupResponseV2_Error value) error,
  }) {
    return deleted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MagicBackupResponseV2_Created value)? created,
    TResult? Function(MagicBackupResponseV2_Backup value)? backup,
    TResult? Function(MagicBackupResponseV2_Deleted value)? deleted,
    TResult? Function(MagicBackupResponseV2_Error value)? error,
  }) {
    return deleted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MagicBackupResponseV2_Created value)? created,
    TResult Function(MagicBackupResponseV2_Backup value)? backup,
    TResult Function(MagicBackupResponseV2_Deleted value)? deleted,
    TResult Function(MagicBackupResponseV2_Error value)? error,
    required TResult orElse(),
  }) {
    if (deleted != null) {
      return deleted(this);
    }
    return orElse();
  }
}

abstract class MagicBackupResponseV2_Deleted extends MagicBackupResponseV2 {
  const factory MagicBackupResponseV2_Deleted() =
      _$MagicBackupResponseV2_DeletedImpl;
  const MagicBackupResponseV2_Deleted._() : super._();
}

/// @nodoc
abstract class _$$MagicBackupResponseV2_ErrorImplCopyWith<$Res> {
  factory _$$MagicBackupResponseV2_ErrorImplCopyWith(
          _$MagicBackupResponseV2_ErrorImpl value,
          $Res Function(_$MagicBackupResponseV2_ErrorImpl) then) =
      __$$MagicBackupResponseV2_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$MagicBackupResponseV2_ErrorImplCopyWithImpl<$Res>
    extends _$MagicBackupResponseV2CopyWithImpl<$Res,
        _$MagicBackupResponseV2_ErrorImpl>
    implements _$$MagicBackupResponseV2_ErrorImplCopyWith<$Res> {
  __$$MagicBackupResponseV2_ErrorImplCopyWithImpl(
      _$MagicBackupResponseV2_ErrorImpl _value,
      $Res Function(_$MagicBackupResponseV2_ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$MagicBackupResponseV2_ErrorImpl(
      error: null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MagicBackupResponseV2_ErrorImpl extends MagicBackupResponseV2_Error {
  const _$MagicBackupResponseV2_ErrorImpl({required this.error}) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'MagicBackupResponseV2.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MagicBackupResponseV2_ErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MagicBackupResponseV2_ErrorImplCopyWith<_$MagicBackupResponseV2_ErrorImpl>
      get copyWith => __$$MagicBackupResponseV2_ErrorImplCopyWithImpl<
          _$MagicBackupResponseV2_ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() created,
    required TResult Function(Uint8List data) backup,
    required TResult Function() deleted,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? created,
    TResult? Function(Uint8List data)? backup,
    TResult? Function()? deleted,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? created,
    TResult Function(Uint8List data)? backup,
    TResult Function()? deleted,
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
    required TResult Function(MagicBackupResponseV2_Created value) created,
    required TResult Function(MagicBackupResponseV2_Backup value) backup,
    required TResult Function(MagicBackupResponseV2_Deleted value) deleted,
    required TResult Function(MagicBackupResponseV2_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MagicBackupResponseV2_Created value)? created,
    TResult? Function(MagicBackupResponseV2_Backup value)? backup,
    TResult? Function(MagicBackupResponseV2_Deleted value)? deleted,
    TResult? Function(MagicBackupResponseV2_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MagicBackupResponseV2_Created value)? created,
    TResult Function(MagicBackupResponseV2_Backup value)? backup,
    TResult Function(MagicBackupResponseV2_Deleted value)? deleted,
    TResult Function(MagicBackupResponseV2_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class MagicBackupResponseV2_Error extends MagicBackupResponseV2 {
  const factory MagicBackupResponseV2_Error({required final String error}) =
      _$MagicBackupResponseV2_ErrorImpl;
  const MagicBackupResponseV2_Error._() : super._();

  String get error;

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MagicBackupResponseV2_ErrorImplCopyWith<_$MagicBackupResponseV2_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RestoreMagicBackupEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notFound,
    required TResult Function(BackupMetadata field0) starting,
    required TResult Function(BackupChunk field0) chunk,
    required TResult Function(String error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notFound,
    TResult? Function(BackupMetadata field0)? starting,
    TResult? Function(BackupChunk field0)? chunk,
    TResult? Function(String error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notFound,
    TResult Function(BackupMetadata field0)? starting,
    TResult Function(BackupChunk field0)? chunk,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreMagicBackupEvent_NotFound value) notFound,
    required TResult Function(RestoreMagicBackupEvent_Starting value) starting,
    required TResult Function(RestoreMagicBackupEvent_Chunk value) chunk,
    required TResult Function(RestoreMagicBackupEvent_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreMagicBackupEvent_NotFound value)? notFound,
    TResult? Function(RestoreMagicBackupEvent_Starting value)? starting,
    TResult? Function(RestoreMagicBackupEvent_Chunk value)? chunk,
    TResult? Function(RestoreMagicBackupEvent_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreMagicBackupEvent_NotFound value)? notFound,
    TResult Function(RestoreMagicBackupEvent_Starting value)? starting,
    TResult Function(RestoreMagicBackupEvent_Chunk value)? chunk,
    TResult Function(RestoreMagicBackupEvent_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestoreMagicBackupEventCopyWith<$Res> {
  factory $RestoreMagicBackupEventCopyWith(RestoreMagicBackupEvent value,
          $Res Function(RestoreMagicBackupEvent) then) =
      _$RestoreMagicBackupEventCopyWithImpl<$Res, RestoreMagicBackupEvent>;
}

/// @nodoc
class _$RestoreMagicBackupEventCopyWithImpl<$Res,
        $Val extends RestoreMagicBackupEvent>
    implements $RestoreMagicBackupEventCopyWith<$Res> {
  _$RestoreMagicBackupEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RestoreMagicBackupEvent_NotFoundImplCopyWith<$Res> {
  factory _$$RestoreMagicBackupEvent_NotFoundImplCopyWith(
          _$RestoreMagicBackupEvent_NotFoundImpl value,
          $Res Function(_$RestoreMagicBackupEvent_NotFoundImpl) then) =
      __$$RestoreMagicBackupEvent_NotFoundImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RestoreMagicBackupEvent_NotFoundImplCopyWithImpl<$Res>
    extends _$RestoreMagicBackupEventCopyWithImpl<$Res,
        _$RestoreMagicBackupEvent_NotFoundImpl>
    implements _$$RestoreMagicBackupEvent_NotFoundImplCopyWith<$Res> {
  __$$RestoreMagicBackupEvent_NotFoundImplCopyWithImpl(
      _$RestoreMagicBackupEvent_NotFoundImpl _value,
      $Res Function(_$RestoreMagicBackupEvent_NotFoundImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RestoreMagicBackupEvent_NotFoundImpl
    extends RestoreMagicBackupEvent_NotFound {
  const _$RestoreMagicBackupEvent_NotFoundImpl() : super._();

  @override
  String toString() {
    return 'RestoreMagicBackupEvent.notFound()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreMagicBackupEvent_NotFoundImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notFound,
    required TResult Function(BackupMetadata field0) starting,
    required TResult Function(BackupChunk field0) chunk,
    required TResult Function(String error) error,
  }) {
    return notFound();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notFound,
    TResult? Function(BackupMetadata field0)? starting,
    TResult? Function(BackupChunk field0)? chunk,
    TResult? Function(String error)? error,
  }) {
    return notFound?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notFound,
    TResult Function(BackupMetadata field0)? starting,
    TResult Function(BackupChunk field0)? chunk,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreMagicBackupEvent_NotFound value) notFound,
    required TResult Function(RestoreMagicBackupEvent_Starting value) starting,
    required TResult Function(RestoreMagicBackupEvent_Chunk value) chunk,
    required TResult Function(RestoreMagicBackupEvent_Error value) error,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreMagicBackupEvent_NotFound value)? notFound,
    TResult? Function(RestoreMagicBackupEvent_Starting value)? starting,
    TResult? Function(RestoreMagicBackupEvent_Chunk value)? chunk,
    TResult? Function(RestoreMagicBackupEvent_Error value)? error,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreMagicBackupEvent_NotFound value)? notFound,
    TResult Function(RestoreMagicBackupEvent_Starting value)? starting,
    TResult Function(RestoreMagicBackupEvent_Chunk value)? chunk,
    TResult Function(RestoreMagicBackupEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class RestoreMagicBackupEvent_NotFound
    extends RestoreMagicBackupEvent {
  const factory RestoreMagicBackupEvent_NotFound() =
      _$RestoreMagicBackupEvent_NotFoundImpl;
  const RestoreMagicBackupEvent_NotFound._() : super._();
}

/// @nodoc
abstract class _$$RestoreMagicBackupEvent_StartingImplCopyWith<$Res> {
  factory _$$RestoreMagicBackupEvent_StartingImplCopyWith(
          _$RestoreMagicBackupEvent_StartingImpl value,
          $Res Function(_$RestoreMagicBackupEvent_StartingImpl) then) =
      __$$RestoreMagicBackupEvent_StartingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BackupMetadata field0});
}

/// @nodoc
class __$$RestoreMagicBackupEvent_StartingImplCopyWithImpl<$Res>
    extends _$RestoreMagicBackupEventCopyWithImpl<$Res,
        _$RestoreMagicBackupEvent_StartingImpl>
    implements _$$RestoreMagicBackupEvent_StartingImplCopyWith<$Res> {
  __$$RestoreMagicBackupEvent_StartingImplCopyWithImpl(
      _$RestoreMagicBackupEvent_StartingImpl _value,
      $Res Function(_$RestoreMagicBackupEvent_StartingImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$RestoreMagicBackupEvent_StartingImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BackupMetadata,
    ));
  }
}

/// @nodoc

class _$RestoreMagicBackupEvent_StartingImpl
    extends RestoreMagicBackupEvent_Starting {
  const _$RestoreMagicBackupEvent_StartingImpl(this.field0) : super._();

  @override
  final BackupMetadata field0;

  @override
  String toString() {
    return 'RestoreMagicBackupEvent.starting(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreMagicBackupEvent_StartingImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestoreMagicBackupEvent_StartingImplCopyWith<
          _$RestoreMagicBackupEvent_StartingImpl>
      get copyWith => __$$RestoreMagicBackupEvent_StartingImplCopyWithImpl<
          _$RestoreMagicBackupEvent_StartingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notFound,
    required TResult Function(BackupMetadata field0) starting,
    required TResult Function(BackupChunk field0) chunk,
    required TResult Function(String error) error,
  }) {
    return starting(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notFound,
    TResult? Function(BackupMetadata field0)? starting,
    TResult? Function(BackupChunk field0)? chunk,
    TResult? Function(String error)? error,
  }) {
    return starting?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notFound,
    TResult Function(BackupMetadata field0)? starting,
    TResult Function(BackupChunk field0)? chunk,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (starting != null) {
      return starting(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreMagicBackupEvent_NotFound value) notFound,
    required TResult Function(RestoreMagicBackupEvent_Starting value) starting,
    required TResult Function(RestoreMagicBackupEvent_Chunk value) chunk,
    required TResult Function(RestoreMagicBackupEvent_Error value) error,
  }) {
    return starting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreMagicBackupEvent_NotFound value)? notFound,
    TResult? Function(RestoreMagicBackupEvent_Starting value)? starting,
    TResult? Function(RestoreMagicBackupEvent_Chunk value)? chunk,
    TResult? Function(RestoreMagicBackupEvent_Error value)? error,
  }) {
    return starting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreMagicBackupEvent_NotFound value)? notFound,
    TResult Function(RestoreMagicBackupEvent_Starting value)? starting,
    TResult Function(RestoreMagicBackupEvent_Chunk value)? chunk,
    TResult Function(RestoreMagicBackupEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (starting != null) {
      return starting(this);
    }
    return orElse();
  }
}

abstract class RestoreMagicBackupEvent_Starting
    extends RestoreMagicBackupEvent {
  const factory RestoreMagicBackupEvent_Starting(final BackupMetadata field0) =
      _$RestoreMagicBackupEvent_StartingImpl;
  const RestoreMagicBackupEvent_Starting._() : super._();

  BackupMetadata get field0;

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestoreMagicBackupEvent_StartingImplCopyWith<
          _$RestoreMagicBackupEvent_StartingImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RestoreMagicBackupEvent_ChunkImplCopyWith<$Res> {
  factory _$$RestoreMagicBackupEvent_ChunkImplCopyWith(
          _$RestoreMagicBackupEvent_ChunkImpl value,
          $Res Function(_$RestoreMagicBackupEvent_ChunkImpl) then) =
      __$$RestoreMagicBackupEvent_ChunkImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BackupChunk field0});
}

/// @nodoc
class __$$RestoreMagicBackupEvent_ChunkImplCopyWithImpl<$Res>
    extends _$RestoreMagicBackupEventCopyWithImpl<$Res,
        _$RestoreMagicBackupEvent_ChunkImpl>
    implements _$$RestoreMagicBackupEvent_ChunkImplCopyWith<$Res> {
  __$$RestoreMagicBackupEvent_ChunkImplCopyWithImpl(
      _$RestoreMagicBackupEvent_ChunkImpl _value,
      $Res Function(_$RestoreMagicBackupEvent_ChunkImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$RestoreMagicBackupEvent_ChunkImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BackupChunk,
    ));
  }
}

/// @nodoc

class _$RestoreMagicBackupEvent_ChunkImpl
    extends RestoreMagicBackupEvent_Chunk {
  const _$RestoreMagicBackupEvent_ChunkImpl(this.field0) : super._();

  @override
  final BackupChunk field0;

  @override
  String toString() {
    return 'RestoreMagicBackupEvent.chunk(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreMagicBackupEvent_ChunkImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestoreMagicBackupEvent_ChunkImplCopyWith<
          _$RestoreMagicBackupEvent_ChunkImpl>
      get copyWith => __$$RestoreMagicBackupEvent_ChunkImplCopyWithImpl<
          _$RestoreMagicBackupEvent_ChunkImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notFound,
    required TResult Function(BackupMetadata field0) starting,
    required TResult Function(BackupChunk field0) chunk,
    required TResult Function(String error) error,
  }) {
    return chunk(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notFound,
    TResult? Function(BackupMetadata field0)? starting,
    TResult? Function(BackupChunk field0)? chunk,
    TResult? Function(String error)? error,
  }) {
    return chunk?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notFound,
    TResult Function(BackupMetadata field0)? starting,
    TResult Function(BackupChunk field0)? chunk,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    if (chunk != null) {
      return chunk(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreMagicBackupEvent_NotFound value) notFound,
    required TResult Function(RestoreMagicBackupEvent_Starting value) starting,
    required TResult Function(RestoreMagicBackupEvent_Chunk value) chunk,
    required TResult Function(RestoreMagicBackupEvent_Error value) error,
  }) {
    return chunk(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreMagicBackupEvent_NotFound value)? notFound,
    TResult? Function(RestoreMagicBackupEvent_Starting value)? starting,
    TResult? Function(RestoreMagicBackupEvent_Chunk value)? chunk,
    TResult? Function(RestoreMagicBackupEvent_Error value)? error,
  }) {
    return chunk?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreMagicBackupEvent_NotFound value)? notFound,
    TResult Function(RestoreMagicBackupEvent_Starting value)? starting,
    TResult Function(RestoreMagicBackupEvent_Chunk value)? chunk,
    TResult Function(RestoreMagicBackupEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (chunk != null) {
      return chunk(this);
    }
    return orElse();
  }
}

abstract class RestoreMagicBackupEvent_Chunk extends RestoreMagicBackupEvent {
  const factory RestoreMagicBackupEvent_Chunk(final BackupChunk field0) =
      _$RestoreMagicBackupEvent_ChunkImpl;
  const RestoreMagicBackupEvent_Chunk._() : super._();

  BackupChunk get field0;

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestoreMagicBackupEvent_ChunkImplCopyWith<
          _$RestoreMagicBackupEvent_ChunkImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RestoreMagicBackupEvent_ErrorImplCopyWith<$Res> {
  factory _$$RestoreMagicBackupEvent_ErrorImplCopyWith(
          _$RestoreMagicBackupEvent_ErrorImpl value,
          $Res Function(_$RestoreMagicBackupEvent_ErrorImpl) then) =
      __$$RestoreMagicBackupEvent_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$RestoreMagicBackupEvent_ErrorImplCopyWithImpl<$Res>
    extends _$RestoreMagicBackupEventCopyWithImpl<$Res,
        _$RestoreMagicBackupEvent_ErrorImpl>
    implements _$$RestoreMagicBackupEvent_ErrorImplCopyWith<$Res> {
  __$$RestoreMagicBackupEvent_ErrorImplCopyWithImpl(
      _$RestoreMagicBackupEvent_ErrorImpl _value,
      $Res Function(_$RestoreMagicBackupEvent_ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$RestoreMagicBackupEvent_ErrorImpl(
      error: null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RestoreMagicBackupEvent_ErrorImpl
    extends RestoreMagicBackupEvent_Error {
  const _$RestoreMagicBackupEvent_ErrorImpl({required this.error}) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'RestoreMagicBackupEvent.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreMagicBackupEvent_ErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestoreMagicBackupEvent_ErrorImplCopyWith<
          _$RestoreMagicBackupEvent_ErrorImpl>
      get copyWith => __$$RestoreMagicBackupEvent_ErrorImplCopyWithImpl<
          _$RestoreMagicBackupEvent_ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notFound,
    required TResult Function(BackupMetadata field0) starting,
    required TResult Function(BackupChunk field0) chunk,
    required TResult Function(String error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notFound,
    TResult? Function(BackupMetadata field0)? starting,
    TResult? Function(BackupChunk field0)? chunk,
    TResult? Function(String error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notFound,
    TResult Function(BackupMetadata field0)? starting,
    TResult Function(BackupChunk field0)? chunk,
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
    required TResult Function(RestoreMagicBackupEvent_NotFound value) notFound,
    required TResult Function(RestoreMagicBackupEvent_Starting value) starting,
    required TResult Function(RestoreMagicBackupEvent_Chunk value) chunk,
    required TResult Function(RestoreMagicBackupEvent_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreMagicBackupEvent_NotFound value)? notFound,
    TResult? Function(RestoreMagicBackupEvent_Starting value)? starting,
    TResult? Function(RestoreMagicBackupEvent_Chunk value)? chunk,
    TResult? Function(RestoreMagicBackupEvent_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreMagicBackupEvent_NotFound value)? notFound,
    TResult Function(RestoreMagicBackupEvent_Starting value)? starting,
    TResult Function(RestoreMagicBackupEvent_Chunk value)? chunk,
    TResult Function(RestoreMagicBackupEvent_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class RestoreMagicBackupEvent_Error extends RestoreMagicBackupEvent {
  const factory RestoreMagicBackupEvent_Error({required final String error}) =
      _$RestoreMagicBackupEvent_ErrorImpl;
  const RestoreMagicBackupEvent_Error._() : super._();

  String get error;

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestoreMagicBackupEvent_ErrorImplCopyWith<
          _$RestoreMagicBackupEvent_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RestoreMagicBackupResult {
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
    required TResult Function(RestoreMagicBackupResult_Success value) success,
    required TResult Function(RestoreMagicBackupResult_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreMagicBackupResult_Success value)? success,
    TResult? Function(RestoreMagicBackupResult_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreMagicBackupResult_Success value)? success,
    TResult Function(RestoreMagicBackupResult_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestoreMagicBackupResultCopyWith<$Res> {
  factory $RestoreMagicBackupResultCopyWith(RestoreMagicBackupResult value,
          $Res Function(RestoreMagicBackupResult) then) =
      _$RestoreMagicBackupResultCopyWithImpl<$Res, RestoreMagicBackupResult>;
}

/// @nodoc
class _$RestoreMagicBackupResultCopyWithImpl<$Res,
        $Val extends RestoreMagicBackupResult>
    implements $RestoreMagicBackupResultCopyWith<$Res> {
  _$RestoreMagicBackupResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RestoreMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RestoreMagicBackupResult_SuccessImplCopyWith<$Res> {
  factory _$$RestoreMagicBackupResult_SuccessImplCopyWith(
          _$RestoreMagicBackupResult_SuccessImpl value,
          $Res Function(_$RestoreMagicBackupResult_SuccessImpl) then) =
      __$$RestoreMagicBackupResult_SuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RestoreMagicBackupResult_SuccessImplCopyWithImpl<$Res>
    extends _$RestoreMagicBackupResultCopyWithImpl<$Res,
        _$RestoreMagicBackupResult_SuccessImpl>
    implements _$$RestoreMagicBackupResult_SuccessImplCopyWith<$Res> {
  __$$RestoreMagicBackupResult_SuccessImplCopyWithImpl(
      _$RestoreMagicBackupResult_SuccessImpl _value,
      $Res Function(_$RestoreMagicBackupResult_SuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestoreMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RestoreMagicBackupResult_SuccessImpl
    extends RestoreMagicBackupResult_Success {
  const _$RestoreMagicBackupResult_SuccessImpl() : super._();

  @override
  String toString() {
    return 'RestoreMagicBackupResult.success()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreMagicBackupResult_SuccessImpl);
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
    required TResult Function(RestoreMagicBackupResult_Success value) success,
    required TResult Function(RestoreMagicBackupResult_Error value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreMagicBackupResult_Success value)? success,
    TResult? Function(RestoreMagicBackupResult_Error value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreMagicBackupResult_Success value)? success,
    TResult Function(RestoreMagicBackupResult_Error value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class RestoreMagicBackupResult_Success
    extends RestoreMagicBackupResult {
  const factory RestoreMagicBackupResult_Success() =
      _$RestoreMagicBackupResult_SuccessImpl;
  const RestoreMagicBackupResult_Success._() : super._();
}

/// @nodoc
abstract class _$$RestoreMagicBackupResult_ErrorImplCopyWith<$Res> {
  factory _$$RestoreMagicBackupResult_ErrorImplCopyWith(
          _$RestoreMagicBackupResult_ErrorImpl value,
          $Res Function(_$RestoreMagicBackupResult_ErrorImpl) then) =
      __$$RestoreMagicBackupResult_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$RestoreMagicBackupResult_ErrorImplCopyWithImpl<$Res>
    extends _$RestoreMagicBackupResultCopyWithImpl<$Res,
        _$RestoreMagicBackupResult_ErrorImpl>
    implements _$$RestoreMagicBackupResult_ErrorImplCopyWith<$Res> {
  __$$RestoreMagicBackupResult_ErrorImplCopyWithImpl(
      _$RestoreMagicBackupResult_ErrorImpl _value,
      $Res Function(_$RestoreMagicBackupResult_ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestoreMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$RestoreMagicBackupResult_ErrorImpl(
      error: null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RestoreMagicBackupResult_ErrorImpl
    extends RestoreMagicBackupResult_Error {
  const _$RestoreMagicBackupResult_ErrorImpl({required this.error}) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'RestoreMagicBackupResult.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreMagicBackupResult_ErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of RestoreMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestoreMagicBackupResult_ErrorImplCopyWith<
          _$RestoreMagicBackupResult_ErrorImpl>
      get copyWith => __$$RestoreMagicBackupResult_ErrorImplCopyWithImpl<
          _$RestoreMagicBackupResult_ErrorImpl>(this, _$identity);

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
    required TResult Function(RestoreMagicBackupResult_Success value) success,
    required TResult Function(RestoreMagicBackupResult_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreMagicBackupResult_Success value)? success,
    TResult? Function(RestoreMagicBackupResult_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreMagicBackupResult_Success value)? success,
    TResult Function(RestoreMagicBackupResult_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class RestoreMagicBackupResult_Error extends RestoreMagicBackupResult {
  const factory RestoreMagicBackupResult_Error({required final String error}) =
      _$RestoreMagicBackupResult_ErrorImpl;
  const RestoreMagicBackupResult_Error._() : super._();

  String get error;

  /// Create a copy of RestoreMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestoreMagicBackupResult_ErrorImplCopyWith<
          _$RestoreMagicBackupResult_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RestoreShardResponse {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Shard shard) success,
    required TResult Function(String error) error,
    required TResult Function() notFound,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Shard shard)? success,
    TResult? Function(String error)? error,
    TResult? Function()? notFound,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Shard shard)? success,
    TResult Function(String error)? error,
    TResult Function()? notFound,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreShardResponse_Success value) success,
    required TResult Function(RestoreShardResponse_Error value) error,
    required TResult Function(RestoreShardResponse_NotFound value) notFound,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreShardResponse_Success value)? success,
    TResult? Function(RestoreShardResponse_Error value)? error,
    TResult? Function(RestoreShardResponse_NotFound value)? notFound,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreShardResponse_Success value)? success,
    TResult Function(RestoreShardResponse_Error value)? error,
    TResult Function(RestoreShardResponse_NotFound value)? notFound,
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
  $Res call({Shard shard});
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
    Object? shard = null,
  }) {
    return _then(_$RestoreShardResponse_SuccessImpl(
      shard: null == shard
          ? _value.shard
          : shard // ignore: cast_nullable_to_non_nullable
              as Shard,
    ));
  }
}

/// @nodoc

class _$RestoreShardResponse_SuccessImpl extends RestoreShardResponse_Success {
  const _$RestoreShardResponse_SuccessImpl({required this.shard}) : super._();

  @override
  final Shard shard;

  @override
  String toString() {
    return 'RestoreShardResponse.success(shard: $shard)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreShardResponse_SuccessImpl &&
            (identical(other.shard, shard) || other.shard == shard));
  }

  @override
  int get hashCode => Object.hash(runtimeType, shard);

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
    required TResult Function(Shard shard) success,
    required TResult Function(String error) error,
    required TResult Function() notFound,
  }) {
    return success(shard);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Shard shard)? success,
    TResult? Function(String error)? error,
    TResult? Function()? notFound,
  }) {
    return success?.call(shard);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Shard shard)? success,
    TResult Function(String error)? error,
    TResult Function()? notFound,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(shard);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreShardResponse_Success value) success,
    required TResult Function(RestoreShardResponse_Error value) error,
    required TResult Function(RestoreShardResponse_NotFound value) notFound,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreShardResponse_Success value)? success,
    TResult? Function(RestoreShardResponse_Error value)? error,
    TResult? Function(RestoreShardResponse_NotFound value)? notFound,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreShardResponse_Success value)? success,
    TResult Function(RestoreShardResponse_Error value)? error,
    TResult Function(RestoreShardResponse_NotFound value)? notFound,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class RestoreShardResponse_Success extends RestoreShardResponse {
  const factory RestoreShardResponse_Success({required final Shard shard}) =
      _$RestoreShardResponse_SuccessImpl;
  const RestoreShardResponse_Success._() : super._();

  Shard get shard;

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
  $Res call({String error});
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
    Object? error = null,
  }) {
    return _then(_$RestoreShardResponse_ErrorImpl(
      error: null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RestoreShardResponse_ErrorImpl extends RestoreShardResponse_Error {
  const _$RestoreShardResponse_ErrorImpl({required this.error}) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'RestoreShardResponse.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreShardResponse_ErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

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
    required TResult Function(Shard shard) success,
    required TResult Function(String error) error,
    required TResult Function() notFound,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Shard shard)? success,
    TResult? Function(String error)? error,
    TResult? Function()? notFound,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Shard shard)? success,
    TResult Function(String error)? error,
    TResult Function()? notFound,
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
    required TResult Function(RestoreShardResponse_Success value) success,
    required TResult Function(RestoreShardResponse_Error value) error,
    required TResult Function(RestoreShardResponse_NotFound value) notFound,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreShardResponse_Success value)? success,
    TResult? Function(RestoreShardResponse_Error value)? error,
    TResult? Function(RestoreShardResponse_NotFound value)? notFound,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreShardResponse_Success value)? success,
    TResult Function(RestoreShardResponse_Error value)? error,
    TResult Function(RestoreShardResponse_NotFound value)? notFound,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class RestoreShardResponse_Error extends RestoreShardResponse {
  const factory RestoreShardResponse_Error({required final String error}) =
      _$RestoreShardResponse_ErrorImpl;
  const RestoreShardResponse_Error._() : super._();

  String get error;

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestoreShardResponse_ErrorImplCopyWith<_$RestoreShardResponse_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RestoreShardResponse_NotFoundImplCopyWith<$Res> {
  factory _$$RestoreShardResponse_NotFoundImplCopyWith(
          _$RestoreShardResponse_NotFoundImpl value,
          $Res Function(_$RestoreShardResponse_NotFoundImpl) then) =
      __$$RestoreShardResponse_NotFoundImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RestoreShardResponse_NotFoundImplCopyWithImpl<$Res>
    extends _$RestoreShardResponseCopyWithImpl<$Res,
        _$RestoreShardResponse_NotFoundImpl>
    implements _$$RestoreShardResponse_NotFoundImplCopyWith<$Res> {
  __$$RestoreShardResponse_NotFoundImplCopyWithImpl(
      _$RestoreShardResponse_NotFoundImpl _value,
      $Res Function(_$RestoreShardResponse_NotFoundImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RestoreShardResponse_NotFoundImpl
    extends RestoreShardResponse_NotFound {
  const _$RestoreShardResponse_NotFoundImpl() : super._();

  @override
  String toString() {
    return 'RestoreShardResponse.notFound()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestoreShardResponse_NotFoundImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Shard shard) success,
    required TResult Function(String error) error,
    required TResult Function() notFound,
  }) {
    return notFound();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Shard shard)? success,
    TResult? Function(String error)? error,
    TResult? Function()? notFound,
  }) {
    return notFound?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Shard shard)? success,
    TResult Function(String error)? error,
    TResult Function()? notFound,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreShardResponse_Success value) success,
    required TResult Function(RestoreShardResponse_Error value) error,
    required TResult Function(RestoreShardResponse_NotFound value) notFound,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreShardResponse_Success value)? success,
    TResult? Function(RestoreShardResponse_Error value)? error,
    TResult? Function(RestoreShardResponse_NotFound value)? notFound,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreShardResponse_Success value)? success,
    TResult Function(RestoreShardResponse_Error value)? error,
    TResult Function(RestoreShardResponse_NotFound value)? notFound,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class RestoreShardResponse_NotFound extends RestoreShardResponse {
  const factory RestoreShardResponse_NotFound() =
      _$RestoreShardResponse_NotFoundImpl;
  const RestoreShardResponse_NotFound._() : super._();
}
