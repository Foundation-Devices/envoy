// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'firmware.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FirmwareDownloadResponse {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double progress) envoyDownloadProgress,
    required TResult Function(int diffIndex, int totalChunks) start,
    required TResult Function(FirmwareChunk field0) chunk,
    required TResult Function(String field0) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double progress)? envoyDownloadProgress,
    TResult? Function(int diffIndex, int totalChunks)? start,
    TResult? Function(FirmwareChunk field0)? chunk,
    TResult? Function(String field0)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double progress)? envoyDownloadProgress,
    TResult Function(int diffIndex, int totalChunks)? start,
    TResult Function(FirmwareChunk field0)? chunk,
    TResult Function(String field0)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(
            FirmwareDownloadResponse_EnvoyDownloadProgress value)
        envoyDownloadProgress,
    required TResult Function(FirmwareDownloadResponse_Start value) start,
    required TResult Function(FirmwareDownloadResponse_Chunk value) chunk,
    required TResult Function(FirmwareDownloadResponse_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FirmwareDownloadResponse_EnvoyDownloadProgress value)?
        envoyDownloadProgress,
    TResult? Function(FirmwareDownloadResponse_Start value)? start,
    TResult? Function(FirmwareDownloadResponse_Chunk value)? chunk,
    TResult? Function(FirmwareDownloadResponse_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FirmwareDownloadResponse_EnvoyDownloadProgress value)?
        envoyDownloadProgress,
    TResult Function(FirmwareDownloadResponse_Start value)? start,
    TResult Function(FirmwareDownloadResponse_Chunk value)? chunk,
    TResult Function(FirmwareDownloadResponse_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirmwareDownloadResponseCopyWith<$Res> {
  factory $FirmwareDownloadResponseCopyWith(FirmwareDownloadResponse value,
          $Res Function(FirmwareDownloadResponse) then) =
      _$FirmwareDownloadResponseCopyWithImpl<$Res, FirmwareDownloadResponse>;
}

/// @nodoc
class _$FirmwareDownloadResponseCopyWithImpl<$Res,
        $Val extends FirmwareDownloadResponse>
    implements $FirmwareDownloadResponseCopyWith<$Res> {
  _$FirmwareDownloadResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FirmwareDownloadResponse_EnvoyDownloadProgressImplCopyWith<
    $Res> {
  factory _$$FirmwareDownloadResponse_EnvoyDownloadProgressImplCopyWith(
          _$FirmwareDownloadResponse_EnvoyDownloadProgressImpl value,
          $Res Function(_$FirmwareDownloadResponse_EnvoyDownloadProgressImpl)
              then) =
      __$$FirmwareDownloadResponse_EnvoyDownloadProgressImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double progress});
}

/// @nodoc
class __$$FirmwareDownloadResponse_EnvoyDownloadProgressImplCopyWithImpl<$Res>
    extends _$FirmwareDownloadResponseCopyWithImpl<$Res,
        _$FirmwareDownloadResponse_EnvoyDownloadProgressImpl>
    implements
        _$$FirmwareDownloadResponse_EnvoyDownloadProgressImplCopyWith<$Res> {
  __$$FirmwareDownloadResponse_EnvoyDownloadProgressImplCopyWithImpl(
      _$FirmwareDownloadResponse_EnvoyDownloadProgressImpl _value,
      $Res Function(_$FirmwareDownloadResponse_EnvoyDownloadProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? progress = null,
  }) {
    return _then(_$FirmwareDownloadResponse_EnvoyDownloadProgressImpl(
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$FirmwareDownloadResponse_EnvoyDownloadProgressImpl
    extends FirmwareDownloadResponse_EnvoyDownloadProgress {
  const _$FirmwareDownloadResponse_EnvoyDownloadProgressImpl(
      {required this.progress})
      : super._();

  @override
  final double progress;

  @override
  String toString() {
    return 'FirmwareDownloadResponse.envoyDownloadProgress(progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirmwareDownloadResponse_EnvoyDownloadProgressImpl &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode => Object.hash(runtimeType, progress);

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirmwareDownloadResponse_EnvoyDownloadProgressImplCopyWith<
          _$FirmwareDownloadResponse_EnvoyDownloadProgressImpl>
      get copyWith =>
          __$$FirmwareDownloadResponse_EnvoyDownloadProgressImplCopyWithImpl<
                  _$FirmwareDownloadResponse_EnvoyDownloadProgressImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double progress) envoyDownloadProgress,
    required TResult Function(int diffIndex, int totalChunks) start,
    required TResult Function(FirmwareChunk field0) chunk,
    required TResult Function(String field0) error,
  }) {
    return envoyDownloadProgress(progress);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double progress)? envoyDownloadProgress,
    TResult? Function(int diffIndex, int totalChunks)? start,
    TResult? Function(FirmwareChunk field0)? chunk,
    TResult? Function(String field0)? error,
  }) {
    return envoyDownloadProgress?.call(progress);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double progress)? envoyDownloadProgress,
    TResult Function(int diffIndex, int totalChunks)? start,
    TResult Function(FirmwareChunk field0)? chunk,
    TResult Function(String field0)? error,
    required TResult orElse(),
  }) {
    if (envoyDownloadProgress != null) {
      return envoyDownloadProgress(progress);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(
            FirmwareDownloadResponse_EnvoyDownloadProgress value)
        envoyDownloadProgress,
    required TResult Function(FirmwareDownloadResponse_Start value) start,
    required TResult Function(FirmwareDownloadResponse_Chunk value) chunk,
    required TResult Function(FirmwareDownloadResponse_Error value) error,
  }) {
    return envoyDownloadProgress(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FirmwareDownloadResponse_EnvoyDownloadProgress value)?
        envoyDownloadProgress,
    TResult? Function(FirmwareDownloadResponse_Start value)? start,
    TResult? Function(FirmwareDownloadResponse_Chunk value)? chunk,
    TResult? Function(FirmwareDownloadResponse_Error value)? error,
  }) {
    return envoyDownloadProgress?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FirmwareDownloadResponse_EnvoyDownloadProgress value)?
        envoyDownloadProgress,
    TResult Function(FirmwareDownloadResponse_Start value)? start,
    TResult Function(FirmwareDownloadResponse_Chunk value)? chunk,
    TResult Function(FirmwareDownloadResponse_Error value)? error,
    required TResult orElse(),
  }) {
    if (envoyDownloadProgress != null) {
      return envoyDownloadProgress(this);
    }
    return orElse();
  }
}

abstract class FirmwareDownloadResponse_EnvoyDownloadProgress
    extends FirmwareDownloadResponse {
  const factory FirmwareDownloadResponse_EnvoyDownloadProgress(
          {required final double progress}) =
      _$FirmwareDownloadResponse_EnvoyDownloadProgressImpl;
  const FirmwareDownloadResponse_EnvoyDownloadProgress._() : super._();

  double get progress;

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirmwareDownloadResponse_EnvoyDownloadProgressImplCopyWith<
          _$FirmwareDownloadResponse_EnvoyDownloadProgressImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FirmwareDownloadResponse_StartImplCopyWith<$Res> {
  factory _$$FirmwareDownloadResponse_StartImplCopyWith(
          _$FirmwareDownloadResponse_StartImpl value,
          $Res Function(_$FirmwareDownloadResponse_StartImpl) then) =
      __$$FirmwareDownloadResponse_StartImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int diffIndex, int totalChunks});
}

/// @nodoc
class __$$FirmwareDownloadResponse_StartImplCopyWithImpl<$Res>
    extends _$FirmwareDownloadResponseCopyWithImpl<$Res,
        _$FirmwareDownloadResponse_StartImpl>
    implements _$$FirmwareDownloadResponse_StartImplCopyWith<$Res> {
  __$$FirmwareDownloadResponse_StartImplCopyWithImpl(
      _$FirmwareDownloadResponse_StartImpl _value,
      $Res Function(_$FirmwareDownloadResponse_StartImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? diffIndex = null,
    Object? totalChunks = null,
  }) {
    return _then(_$FirmwareDownloadResponse_StartImpl(
      diffIndex: null == diffIndex
          ? _value.diffIndex
          : diffIndex // ignore: cast_nullable_to_non_nullable
              as int,
      totalChunks: null == totalChunks
          ? _value.totalChunks
          : totalChunks // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$FirmwareDownloadResponse_StartImpl
    extends FirmwareDownloadResponse_Start {
  const _$FirmwareDownloadResponse_StartImpl(
      {required this.diffIndex, required this.totalChunks})
      : super._();

  @override
  final int diffIndex;
  @override
  final int totalChunks;

  @override
  String toString() {
    return 'FirmwareDownloadResponse.start(diffIndex: $diffIndex, totalChunks: $totalChunks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirmwareDownloadResponse_StartImpl &&
            (identical(other.diffIndex, diffIndex) ||
                other.diffIndex == diffIndex) &&
            (identical(other.totalChunks, totalChunks) ||
                other.totalChunks == totalChunks));
  }

  @override
  int get hashCode => Object.hash(runtimeType, diffIndex, totalChunks);

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirmwareDownloadResponse_StartImplCopyWith<
          _$FirmwareDownloadResponse_StartImpl>
      get copyWith => __$$FirmwareDownloadResponse_StartImplCopyWithImpl<
          _$FirmwareDownloadResponse_StartImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double progress) envoyDownloadProgress,
    required TResult Function(int diffIndex, int totalChunks) start,
    required TResult Function(FirmwareChunk field0) chunk,
    required TResult Function(String field0) error,
  }) {
    return start(diffIndex, totalChunks);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double progress)? envoyDownloadProgress,
    TResult? Function(int diffIndex, int totalChunks)? start,
    TResult? Function(FirmwareChunk field0)? chunk,
    TResult? Function(String field0)? error,
  }) {
    return start?.call(diffIndex, totalChunks);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double progress)? envoyDownloadProgress,
    TResult Function(int diffIndex, int totalChunks)? start,
    TResult Function(FirmwareChunk field0)? chunk,
    TResult Function(String field0)? error,
    required TResult orElse(),
  }) {
    if (start != null) {
      return start(diffIndex, totalChunks);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(
            FirmwareDownloadResponse_EnvoyDownloadProgress value)
        envoyDownloadProgress,
    required TResult Function(FirmwareDownloadResponse_Start value) start,
    required TResult Function(FirmwareDownloadResponse_Chunk value) chunk,
    required TResult Function(FirmwareDownloadResponse_Error value) error,
  }) {
    return start(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FirmwareDownloadResponse_EnvoyDownloadProgress value)?
        envoyDownloadProgress,
    TResult? Function(FirmwareDownloadResponse_Start value)? start,
    TResult? Function(FirmwareDownloadResponse_Chunk value)? chunk,
    TResult? Function(FirmwareDownloadResponse_Error value)? error,
  }) {
    return start?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FirmwareDownloadResponse_EnvoyDownloadProgress value)?
        envoyDownloadProgress,
    TResult Function(FirmwareDownloadResponse_Start value)? start,
    TResult Function(FirmwareDownloadResponse_Chunk value)? chunk,
    TResult Function(FirmwareDownloadResponse_Error value)? error,
    required TResult orElse(),
  }) {
    if (start != null) {
      return start(this);
    }
    return orElse();
  }
}

abstract class FirmwareDownloadResponse_Start extends FirmwareDownloadResponse {
  const factory FirmwareDownloadResponse_Start(
      {required final int diffIndex,
      required final int totalChunks}) = _$FirmwareDownloadResponse_StartImpl;
  const FirmwareDownloadResponse_Start._() : super._();

  int get diffIndex;
  int get totalChunks;

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirmwareDownloadResponse_StartImplCopyWith<
          _$FirmwareDownloadResponse_StartImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FirmwareDownloadResponse_ChunkImplCopyWith<$Res> {
  factory _$$FirmwareDownloadResponse_ChunkImplCopyWith(
          _$FirmwareDownloadResponse_ChunkImpl value,
          $Res Function(_$FirmwareDownloadResponse_ChunkImpl) then) =
      __$$FirmwareDownloadResponse_ChunkImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FirmwareChunk field0});
}

/// @nodoc
class __$$FirmwareDownloadResponse_ChunkImplCopyWithImpl<$Res>
    extends _$FirmwareDownloadResponseCopyWithImpl<$Res,
        _$FirmwareDownloadResponse_ChunkImpl>
    implements _$$FirmwareDownloadResponse_ChunkImplCopyWith<$Res> {
  __$$FirmwareDownloadResponse_ChunkImplCopyWithImpl(
      _$FirmwareDownloadResponse_ChunkImpl _value,
      $Res Function(_$FirmwareDownloadResponse_ChunkImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$FirmwareDownloadResponse_ChunkImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as FirmwareChunk,
    ));
  }
}

/// @nodoc

class _$FirmwareDownloadResponse_ChunkImpl
    extends FirmwareDownloadResponse_Chunk {
  const _$FirmwareDownloadResponse_ChunkImpl(this.field0) : super._();

  @override
  final FirmwareChunk field0;

  @override
  String toString() {
    return 'FirmwareDownloadResponse.chunk(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirmwareDownloadResponse_ChunkImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirmwareDownloadResponse_ChunkImplCopyWith<
          _$FirmwareDownloadResponse_ChunkImpl>
      get copyWith => __$$FirmwareDownloadResponse_ChunkImplCopyWithImpl<
          _$FirmwareDownloadResponse_ChunkImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double progress) envoyDownloadProgress,
    required TResult Function(int diffIndex, int totalChunks) start,
    required TResult Function(FirmwareChunk field0) chunk,
    required TResult Function(String field0) error,
  }) {
    return chunk(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double progress)? envoyDownloadProgress,
    TResult? Function(int diffIndex, int totalChunks)? start,
    TResult? Function(FirmwareChunk field0)? chunk,
    TResult? Function(String field0)? error,
  }) {
    return chunk?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double progress)? envoyDownloadProgress,
    TResult Function(int diffIndex, int totalChunks)? start,
    TResult Function(FirmwareChunk field0)? chunk,
    TResult Function(String field0)? error,
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
    required TResult Function(
            FirmwareDownloadResponse_EnvoyDownloadProgress value)
        envoyDownloadProgress,
    required TResult Function(FirmwareDownloadResponse_Start value) start,
    required TResult Function(FirmwareDownloadResponse_Chunk value) chunk,
    required TResult Function(FirmwareDownloadResponse_Error value) error,
  }) {
    return chunk(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FirmwareDownloadResponse_EnvoyDownloadProgress value)?
        envoyDownloadProgress,
    TResult? Function(FirmwareDownloadResponse_Start value)? start,
    TResult? Function(FirmwareDownloadResponse_Chunk value)? chunk,
    TResult? Function(FirmwareDownloadResponse_Error value)? error,
  }) {
    return chunk?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FirmwareDownloadResponse_EnvoyDownloadProgress value)?
        envoyDownloadProgress,
    TResult Function(FirmwareDownloadResponse_Start value)? start,
    TResult Function(FirmwareDownloadResponse_Chunk value)? chunk,
    TResult Function(FirmwareDownloadResponse_Error value)? error,
    required TResult orElse(),
  }) {
    if (chunk != null) {
      return chunk(this);
    }
    return orElse();
  }
}

abstract class FirmwareDownloadResponse_Chunk extends FirmwareDownloadResponse {
  const factory FirmwareDownloadResponse_Chunk(final FirmwareChunk field0) =
      _$FirmwareDownloadResponse_ChunkImpl;
  const FirmwareDownloadResponse_Chunk._() : super._();

  FirmwareChunk get field0;

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirmwareDownloadResponse_ChunkImplCopyWith<
          _$FirmwareDownloadResponse_ChunkImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FirmwareDownloadResponse_ErrorImplCopyWith<$Res> {
  factory _$$FirmwareDownloadResponse_ErrorImplCopyWith(
          _$FirmwareDownloadResponse_ErrorImpl value,
          $Res Function(_$FirmwareDownloadResponse_ErrorImpl) then) =
      __$$FirmwareDownloadResponse_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$FirmwareDownloadResponse_ErrorImplCopyWithImpl<$Res>
    extends _$FirmwareDownloadResponseCopyWithImpl<$Res,
        _$FirmwareDownloadResponse_ErrorImpl>
    implements _$$FirmwareDownloadResponse_ErrorImplCopyWith<$Res> {
  __$$FirmwareDownloadResponse_ErrorImplCopyWithImpl(
      _$FirmwareDownloadResponse_ErrorImpl _value,
      $Res Function(_$FirmwareDownloadResponse_ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$FirmwareDownloadResponse_ErrorImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FirmwareDownloadResponse_ErrorImpl
    extends FirmwareDownloadResponse_Error {
  const _$FirmwareDownloadResponse_ErrorImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'FirmwareDownloadResponse.error(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirmwareDownloadResponse_ErrorImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirmwareDownloadResponse_ErrorImplCopyWith<
          _$FirmwareDownloadResponse_ErrorImpl>
      get copyWith => __$$FirmwareDownloadResponse_ErrorImplCopyWithImpl<
          _$FirmwareDownloadResponse_ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(double progress) envoyDownloadProgress,
    required TResult Function(int diffIndex, int totalChunks) start,
    required TResult Function(FirmwareChunk field0) chunk,
    required TResult Function(String field0) error,
  }) {
    return error(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(double progress)? envoyDownloadProgress,
    TResult? Function(int diffIndex, int totalChunks)? start,
    TResult? Function(FirmwareChunk field0)? chunk,
    TResult? Function(String field0)? error,
  }) {
    return error?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(double progress)? envoyDownloadProgress,
    TResult Function(int diffIndex, int totalChunks)? start,
    TResult Function(FirmwareChunk field0)? chunk,
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
    required TResult Function(
            FirmwareDownloadResponse_EnvoyDownloadProgress value)
        envoyDownloadProgress,
    required TResult Function(FirmwareDownloadResponse_Start value) start,
    required TResult Function(FirmwareDownloadResponse_Chunk value) chunk,
    required TResult Function(FirmwareDownloadResponse_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FirmwareDownloadResponse_EnvoyDownloadProgress value)?
        envoyDownloadProgress,
    TResult? Function(FirmwareDownloadResponse_Start value)? start,
    TResult? Function(FirmwareDownloadResponse_Chunk value)? chunk,
    TResult? Function(FirmwareDownloadResponse_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FirmwareDownloadResponse_EnvoyDownloadProgress value)?
        envoyDownloadProgress,
    TResult Function(FirmwareDownloadResponse_Start value)? start,
    TResult Function(FirmwareDownloadResponse_Chunk value)? chunk,
    TResult Function(FirmwareDownloadResponse_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class FirmwareDownloadResponse_Error extends FirmwareDownloadResponse {
  const factory FirmwareDownloadResponse_Error(final String field0) =
      _$FirmwareDownloadResponse_ErrorImpl;
  const FirmwareDownloadResponse_Error._() : super._();

  String get field0;

  /// Create a copy of FirmwareDownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirmwareDownloadResponse_ErrorImplCopyWith<
          _$FirmwareDownloadResponse_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FirmwareUpdateCheckResponse {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FirmwareUpdateAvailable field0) available,
    required TResult Function() notAvailable,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FirmwareUpdateAvailable field0)? available,
    TResult? Function()? notAvailable,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FirmwareUpdateAvailable field0)? available,
    TResult Function()? notAvailable,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FirmwareUpdateCheckResponse_Available value)
        available,
    required TResult Function(FirmwareUpdateCheckResponse_NotAvailable value)
        notAvailable,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FirmwareUpdateCheckResponse_Available value)? available,
    TResult? Function(FirmwareUpdateCheckResponse_NotAvailable value)?
        notAvailable,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FirmwareUpdateCheckResponse_Available value)? available,
    TResult Function(FirmwareUpdateCheckResponse_NotAvailable value)?
        notAvailable,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirmwareUpdateCheckResponseCopyWith<$Res> {
  factory $FirmwareUpdateCheckResponseCopyWith(
          FirmwareUpdateCheckResponse value,
          $Res Function(FirmwareUpdateCheckResponse) then) =
      _$FirmwareUpdateCheckResponseCopyWithImpl<$Res,
          FirmwareUpdateCheckResponse>;
}

/// @nodoc
class _$FirmwareUpdateCheckResponseCopyWithImpl<$Res,
        $Val extends FirmwareUpdateCheckResponse>
    implements $FirmwareUpdateCheckResponseCopyWith<$Res> {
  _$FirmwareUpdateCheckResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirmwareUpdateCheckResponse
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FirmwareUpdateCheckResponse_AvailableImplCopyWith<$Res> {
  factory _$$FirmwareUpdateCheckResponse_AvailableImplCopyWith(
          _$FirmwareUpdateCheckResponse_AvailableImpl value,
          $Res Function(_$FirmwareUpdateCheckResponse_AvailableImpl) then) =
      __$$FirmwareUpdateCheckResponse_AvailableImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FirmwareUpdateAvailable field0});
}

/// @nodoc
class __$$FirmwareUpdateCheckResponse_AvailableImplCopyWithImpl<$Res>
    extends _$FirmwareUpdateCheckResponseCopyWithImpl<$Res,
        _$FirmwareUpdateCheckResponse_AvailableImpl>
    implements _$$FirmwareUpdateCheckResponse_AvailableImplCopyWith<$Res> {
  __$$FirmwareUpdateCheckResponse_AvailableImplCopyWithImpl(
      _$FirmwareUpdateCheckResponse_AvailableImpl _value,
      $Res Function(_$FirmwareUpdateCheckResponse_AvailableImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirmwareUpdateCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$FirmwareUpdateCheckResponse_AvailableImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as FirmwareUpdateAvailable,
    ));
  }
}

/// @nodoc

class _$FirmwareUpdateCheckResponse_AvailableImpl
    extends FirmwareUpdateCheckResponse_Available {
  const _$FirmwareUpdateCheckResponse_AvailableImpl(this.field0) : super._();

  @override
  final FirmwareUpdateAvailable field0;

  @override
  String toString() {
    return 'FirmwareUpdateCheckResponse.available(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirmwareUpdateCheckResponse_AvailableImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of FirmwareUpdateCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirmwareUpdateCheckResponse_AvailableImplCopyWith<
          _$FirmwareUpdateCheckResponse_AvailableImpl>
      get copyWith => __$$FirmwareUpdateCheckResponse_AvailableImplCopyWithImpl<
          _$FirmwareUpdateCheckResponse_AvailableImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FirmwareUpdateAvailable field0) available,
    required TResult Function() notAvailable,
  }) {
    return available(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FirmwareUpdateAvailable field0)? available,
    TResult? Function()? notAvailable,
  }) {
    return available?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FirmwareUpdateAvailable field0)? available,
    TResult Function()? notAvailable,
    required TResult orElse(),
  }) {
    if (available != null) {
      return available(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FirmwareUpdateCheckResponse_Available value)
        available,
    required TResult Function(FirmwareUpdateCheckResponse_NotAvailable value)
        notAvailable,
  }) {
    return available(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FirmwareUpdateCheckResponse_Available value)? available,
    TResult? Function(FirmwareUpdateCheckResponse_NotAvailable value)?
        notAvailable,
  }) {
    return available?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FirmwareUpdateCheckResponse_Available value)? available,
    TResult Function(FirmwareUpdateCheckResponse_NotAvailable value)?
        notAvailable,
    required TResult orElse(),
  }) {
    if (available != null) {
      return available(this);
    }
    return orElse();
  }
}

abstract class FirmwareUpdateCheckResponse_Available
    extends FirmwareUpdateCheckResponse {
  const factory FirmwareUpdateCheckResponse_Available(
          final FirmwareUpdateAvailable field0) =
      _$FirmwareUpdateCheckResponse_AvailableImpl;
  const FirmwareUpdateCheckResponse_Available._() : super._();

  FirmwareUpdateAvailable get field0;

  /// Create a copy of FirmwareUpdateCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirmwareUpdateCheckResponse_AvailableImplCopyWith<
          _$FirmwareUpdateCheckResponse_AvailableImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FirmwareUpdateCheckResponse_NotAvailableImplCopyWith<$Res> {
  factory _$$FirmwareUpdateCheckResponse_NotAvailableImplCopyWith(
          _$FirmwareUpdateCheckResponse_NotAvailableImpl value,
          $Res Function(_$FirmwareUpdateCheckResponse_NotAvailableImpl) then) =
      __$$FirmwareUpdateCheckResponse_NotAvailableImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FirmwareUpdateCheckResponse_NotAvailableImplCopyWithImpl<$Res>
    extends _$FirmwareUpdateCheckResponseCopyWithImpl<$Res,
        _$FirmwareUpdateCheckResponse_NotAvailableImpl>
    implements _$$FirmwareUpdateCheckResponse_NotAvailableImplCopyWith<$Res> {
  __$$FirmwareUpdateCheckResponse_NotAvailableImplCopyWithImpl(
      _$FirmwareUpdateCheckResponse_NotAvailableImpl _value,
      $Res Function(_$FirmwareUpdateCheckResponse_NotAvailableImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirmwareUpdateCheckResponse
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FirmwareUpdateCheckResponse_NotAvailableImpl
    extends FirmwareUpdateCheckResponse_NotAvailable {
  const _$FirmwareUpdateCheckResponse_NotAvailableImpl() : super._();

  @override
  String toString() {
    return 'FirmwareUpdateCheckResponse.notAvailable()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirmwareUpdateCheckResponse_NotAvailableImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FirmwareUpdateAvailable field0) available,
    required TResult Function() notAvailable,
  }) {
    return notAvailable();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FirmwareUpdateAvailable field0)? available,
    TResult? Function()? notAvailable,
  }) {
    return notAvailable?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FirmwareUpdateAvailable field0)? available,
    TResult Function()? notAvailable,
    required TResult orElse(),
  }) {
    if (notAvailable != null) {
      return notAvailable();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FirmwareUpdateCheckResponse_Available value)
        available,
    required TResult Function(FirmwareUpdateCheckResponse_NotAvailable value)
        notAvailable,
  }) {
    return notAvailable(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FirmwareUpdateCheckResponse_Available value)? available,
    TResult? Function(FirmwareUpdateCheckResponse_NotAvailable value)?
        notAvailable,
  }) {
    return notAvailable?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FirmwareUpdateCheckResponse_Available value)? available,
    TResult Function(FirmwareUpdateCheckResponse_NotAvailable value)?
        notAvailable,
    required TResult orElse(),
  }) {
    if (notAvailable != null) {
      return notAvailable(this);
    }
    return orElse();
  }
}

abstract class FirmwareUpdateCheckResponse_NotAvailable
    extends FirmwareUpdateCheckResponse {
  const factory FirmwareUpdateCheckResponse_NotAvailable() =
      _$FirmwareUpdateCheckResponse_NotAvailableImpl;
  const FirmwareUpdateCheckResponse_NotAvailable._() : super._();
}

/// @nodoc
mixin _$FirmwareUpdateResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String installedVersion) success,
    required TResult Function(String field0) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String installedVersion)? success,
    TResult? Function(String field0)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String installedVersion)? success,
    TResult Function(String field0)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FirmwareUpdateResult_Success value) success,
    required TResult Function(FirmwareUpdateResult_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FirmwareUpdateResult_Success value)? success,
    TResult? Function(FirmwareUpdateResult_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FirmwareUpdateResult_Success value)? success,
    TResult Function(FirmwareUpdateResult_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirmwareUpdateResultCopyWith<$Res> {
  factory $FirmwareUpdateResultCopyWith(FirmwareUpdateResult value,
          $Res Function(FirmwareUpdateResult) then) =
      _$FirmwareUpdateResultCopyWithImpl<$Res, FirmwareUpdateResult>;
}

/// @nodoc
class _$FirmwareUpdateResultCopyWithImpl<$Res,
        $Val extends FirmwareUpdateResult>
    implements $FirmwareUpdateResultCopyWith<$Res> {
  _$FirmwareUpdateResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirmwareUpdateResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FirmwareUpdateResult_SuccessImplCopyWith<$Res> {
  factory _$$FirmwareUpdateResult_SuccessImplCopyWith(
          _$FirmwareUpdateResult_SuccessImpl value,
          $Res Function(_$FirmwareUpdateResult_SuccessImpl) then) =
      __$$FirmwareUpdateResult_SuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String installedVersion});
}

/// @nodoc
class __$$FirmwareUpdateResult_SuccessImplCopyWithImpl<$Res>
    extends _$FirmwareUpdateResultCopyWithImpl<$Res,
        _$FirmwareUpdateResult_SuccessImpl>
    implements _$$FirmwareUpdateResult_SuccessImplCopyWith<$Res> {
  __$$FirmwareUpdateResult_SuccessImplCopyWithImpl(
      _$FirmwareUpdateResult_SuccessImpl _value,
      $Res Function(_$FirmwareUpdateResult_SuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirmwareUpdateResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? installedVersion = null,
  }) {
    return _then(_$FirmwareUpdateResult_SuccessImpl(
      installedVersion: null == installedVersion
          ? _value.installedVersion
          : installedVersion // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FirmwareUpdateResult_SuccessImpl extends FirmwareUpdateResult_Success {
  const _$FirmwareUpdateResult_SuccessImpl({required this.installedVersion})
      : super._();

  @override
  final String installedVersion;

  @override
  String toString() {
    return 'FirmwareUpdateResult.success(installedVersion: $installedVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirmwareUpdateResult_SuccessImpl &&
            (identical(other.installedVersion, installedVersion) ||
                other.installedVersion == installedVersion));
  }

  @override
  int get hashCode => Object.hash(runtimeType, installedVersion);

  /// Create a copy of FirmwareUpdateResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirmwareUpdateResult_SuccessImplCopyWith<
          _$FirmwareUpdateResult_SuccessImpl>
      get copyWith => __$$FirmwareUpdateResult_SuccessImplCopyWithImpl<
          _$FirmwareUpdateResult_SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String installedVersion) success,
    required TResult Function(String field0) error,
  }) {
    return success(installedVersion);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String installedVersion)? success,
    TResult? Function(String field0)? error,
  }) {
    return success?.call(installedVersion);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String installedVersion)? success,
    TResult Function(String field0)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(installedVersion);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FirmwareUpdateResult_Success value) success,
    required TResult Function(FirmwareUpdateResult_Error value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FirmwareUpdateResult_Success value)? success,
    TResult? Function(FirmwareUpdateResult_Error value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FirmwareUpdateResult_Success value)? success,
    TResult Function(FirmwareUpdateResult_Error value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class FirmwareUpdateResult_Success extends FirmwareUpdateResult {
  const factory FirmwareUpdateResult_Success(
          {required final String installedVersion}) =
      _$FirmwareUpdateResult_SuccessImpl;
  const FirmwareUpdateResult_Success._() : super._();

  String get installedVersion;

  /// Create a copy of FirmwareUpdateResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirmwareUpdateResult_SuccessImplCopyWith<
          _$FirmwareUpdateResult_SuccessImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FirmwareUpdateResult_ErrorImplCopyWith<$Res> {
  factory _$$FirmwareUpdateResult_ErrorImplCopyWith(
          _$FirmwareUpdateResult_ErrorImpl value,
          $Res Function(_$FirmwareUpdateResult_ErrorImpl) then) =
      __$$FirmwareUpdateResult_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$FirmwareUpdateResult_ErrorImplCopyWithImpl<$Res>
    extends _$FirmwareUpdateResultCopyWithImpl<$Res,
        _$FirmwareUpdateResult_ErrorImpl>
    implements _$$FirmwareUpdateResult_ErrorImplCopyWith<$Res> {
  __$$FirmwareUpdateResult_ErrorImplCopyWithImpl(
      _$FirmwareUpdateResult_ErrorImpl _value,
      $Res Function(_$FirmwareUpdateResult_ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirmwareUpdateResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$FirmwareUpdateResult_ErrorImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FirmwareUpdateResult_ErrorImpl extends FirmwareUpdateResult_Error {
  const _$FirmwareUpdateResult_ErrorImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'FirmwareUpdateResult.error(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirmwareUpdateResult_ErrorImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of FirmwareUpdateResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirmwareUpdateResult_ErrorImplCopyWith<_$FirmwareUpdateResult_ErrorImpl>
      get copyWith => __$$FirmwareUpdateResult_ErrorImplCopyWithImpl<
          _$FirmwareUpdateResult_ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String installedVersion) success,
    required TResult Function(String field0) error,
  }) {
    return error(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String installedVersion)? success,
    TResult? Function(String field0)? error,
  }) {
    return error?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String installedVersion)? success,
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
    required TResult Function(FirmwareUpdateResult_Success value) success,
    required TResult Function(FirmwareUpdateResult_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FirmwareUpdateResult_Success value)? success,
    TResult? Function(FirmwareUpdateResult_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FirmwareUpdateResult_Success value)? success,
    TResult Function(FirmwareUpdateResult_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class FirmwareUpdateResult_Error extends FirmwareUpdateResult {
  const factory FirmwareUpdateResult_Error(final String field0) =
      _$FirmwareUpdateResult_ErrorImpl;
  const FirmwareUpdateResult_Error._() : super._();

  String get field0;

  /// Create a copy of FirmwareUpdateResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirmwareUpdateResult_ErrorImplCopyWith<_$FirmwareUpdateResult_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}
