// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BackupShardResponse {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is BackupShardResponse);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'BackupShardResponse()';
  }
}

/// @nodoc
class $BackupShardResponseCopyWith<$Res> {
  $BackupShardResponseCopyWith(
      BackupShardResponse _, $Res Function(BackupShardResponse) __);
}

/// Adds pattern-matching-related methods to [BackupShardResponse].
extension BackupShardResponsePatterns on BackupShardResponse {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BackupShardResponse_Success value)? success,
    TResult Function(BackupShardResponse_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case BackupShardResponse_Success() when success != null:
        return success(_that);
      case BackupShardResponse_Error() when error != null:
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BackupShardResponse_Success value) success,
    required TResult Function(BackupShardResponse_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case BackupShardResponse_Success():
        return success(_that);
      case BackupShardResponse_Error():
        return error(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BackupShardResponse_Success value)? success,
    TResult? Function(BackupShardResponse_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case BackupShardResponse_Success() when success != null:
        return success(_that);
      case BackupShardResponse_Error() when error != null:
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case BackupShardResponse_Success() when success != null:
        return success();
      case BackupShardResponse_Error() when error != null:
        return error(_that.error);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() success,
    required TResult Function(String error) error,
  }) {
    final _that = this;
    switch (_that) {
      case BackupShardResponse_Success():
        return success();
      case BackupShardResponse_Error():
        return error(_that.error);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? success,
    TResult? Function(String error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case BackupShardResponse_Success() when success != null:
        return success();
      case BackupShardResponse_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class BackupShardResponse_Success extends BackupShardResponse {
  const BackupShardResponse_Success() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BackupShardResponse_Success);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'BackupShardResponse.success()';
  }
}

/// @nodoc

class BackupShardResponse_Error extends BackupShardResponse {
  const BackupShardResponse_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of BackupShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BackupShardResponse_ErrorCopyWith<BackupShardResponse_Error> get copyWith =>
      _$BackupShardResponse_ErrorCopyWithImpl<BackupShardResponse_Error>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BackupShardResponse_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'BackupShardResponse.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $BackupShardResponse_ErrorCopyWith<$Res>
    implements $BackupShardResponseCopyWith<$Res> {
  factory $BackupShardResponse_ErrorCopyWith(BackupShardResponse_Error value,
          $Res Function(BackupShardResponse_Error) _then) =
      _$BackupShardResponse_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$BackupShardResponse_ErrorCopyWithImpl<$Res>
    implements $BackupShardResponse_ErrorCopyWith<$Res> {
  _$BackupShardResponse_ErrorCopyWithImpl(this._self, this._then);

  final BackupShardResponse_Error _self;
  final $Res Function(BackupShardResponse_Error) _then;

  /// Create a copy of BackupShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(BackupShardResponse_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$CreateMagicBackupEvent {
  Object get field0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CreateMagicBackupEvent &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @override
  String toString() {
    return 'CreateMagicBackupEvent(field0: $field0)';
  }
}

/// @nodoc
class $CreateMagicBackupEventCopyWith<$Res> {
  $CreateMagicBackupEventCopyWith(
      CreateMagicBackupEvent _, $Res Function(CreateMagicBackupEvent) __);
}

/// Adds pattern-matching-related methods to [CreateMagicBackupEvent].
extension CreateMagicBackupEventPatterns on CreateMagicBackupEvent {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateMagicBackupEvent_Start value)? start,
    TResult Function(CreateMagicBackupEvent_Chunk value)? chunk,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case CreateMagicBackupEvent_Start() when start != null:
        return start(_that);
      case CreateMagicBackupEvent_Chunk() when chunk != null:
        return chunk(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CreateMagicBackupEvent_Start value) start,
    required TResult Function(CreateMagicBackupEvent_Chunk value) chunk,
  }) {
    final _that = this;
    switch (_that) {
      case CreateMagicBackupEvent_Start():
        return start(_that);
      case CreateMagicBackupEvent_Chunk():
        return chunk(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupEvent_Start value)? start,
    TResult? Function(CreateMagicBackupEvent_Chunk value)? chunk,
  }) {
    final _that = this;
    switch (_that) {
      case CreateMagicBackupEvent_Start() when start != null:
        return start(_that);
      case CreateMagicBackupEvent_Chunk() when chunk != null:
        return chunk(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(StartMagicBackup field0)? start,
    TResult Function(BackupChunk field0)? chunk,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case CreateMagicBackupEvent_Start() when start != null:
        return start(_that.field0);
      case CreateMagicBackupEvent_Chunk() when chunk != null:
        return chunk(_that.field0);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(StartMagicBackup field0) start,
    required TResult Function(BackupChunk field0) chunk,
  }) {
    final _that = this;
    switch (_that) {
      case CreateMagicBackupEvent_Start():
        return start(_that.field0);
      case CreateMagicBackupEvent_Chunk():
        return chunk(_that.field0);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(StartMagicBackup field0)? start,
    TResult? Function(BackupChunk field0)? chunk,
  }) {
    final _that = this;
    switch (_that) {
      case CreateMagicBackupEvent_Start() when start != null:
        return start(_that.field0);
      case CreateMagicBackupEvent_Chunk() when chunk != null:
        return chunk(_that.field0);
      case _:
        return null;
    }
  }
}

/// @nodoc

class CreateMagicBackupEvent_Start extends CreateMagicBackupEvent {
  const CreateMagicBackupEvent_Start(this.field0) : super._();

  @override
  final StartMagicBackup field0;

  /// Create a copy of CreateMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CreateMagicBackupEvent_StartCopyWith<CreateMagicBackupEvent_Start>
      get copyWith => _$CreateMagicBackupEvent_StartCopyWithImpl<
          CreateMagicBackupEvent_Start>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CreateMagicBackupEvent_Start &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'CreateMagicBackupEvent.start(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $CreateMagicBackupEvent_StartCopyWith<$Res>
    implements $CreateMagicBackupEventCopyWith<$Res> {
  factory $CreateMagicBackupEvent_StartCopyWith(
          CreateMagicBackupEvent_Start value,
          $Res Function(CreateMagicBackupEvent_Start) _then) =
      _$CreateMagicBackupEvent_StartCopyWithImpl;
  @useResult
  $Res call({StartMagicBackup field0});
}

/// @nodoc
class _$CreateMagicBackupEvent_StartCopyWithImpl<$Res>
    implements $CreateMagicBackupEvent_StartCopyWith<$Res> {
  _$CreateMagicBackupEvent_StartCopyWithImpl(this._self, this._then);

  final CreateMagicBackupEvent_Start _self;
  final $Res Function(CreateMagicBackupEvent_Start) _then;

  /// Create a copy of CreateMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(CreateMagicBackupEvent_Start(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as StartMagicBackup,
    ));
  }
}

/// @nodoc

class CreateMagicBackupEvent_Chunk extends CreateMagicBackupEvent {
  const CreateMagicBackupEvent_Chunk(this.field0) : super._();

  @override
  final BackupChunk field0;

  /// Create a copy of CreateMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CreateMagicBackupEvent_ChunkCopyWith<CreateMagicBackupEvent_Chunk>
      get copyWith => _$CreateMagicBackupEvent_ChunkCopyWithImpl<
          CreateMagicBackupEvent_Chunk>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CreateMagicBackupEvent_Chunk &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'CreateMagicBackupEvent.chunk(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $CreateMagicBackupEvent_ChunkCopyWith<$Res>
    implements $CreateMagicBackupEventCopyWith<$Res> {
  factory $CreateMagicBackupEvent_ChunkCopyWith(
          CreateMagicBackupEvent_Chunk value,
          $Res Function(CreateMagicBackupEvent_Chunk) _then) =
      _$CreateMagicBackupEvent_ChunkCopyWithImpl;
  @useResult
  $Res call({BackupChunk field0});
}

/// @nodoc
class _$CreateMagicBackupEvent_ChunkCopyWithImpl<$Res>
    implements $CreateMagicBackupEvent_ChunkCopyWith<$Res> {
  _$CreateMagicBackupEvent_ChunkCopyWithImpl(this._self, this._then);

  final CreateMagicBackupEvent_Chunk _self;
  final $Res Function(CreateMagicBackupEvent_Chunk) _then;

  /// Create a copy of CreateMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(CreateMagicBackupEvent_Chunk(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BackupChunk,
    ));
  }
}

/// @nodoc
mixin _$CreateMagicBackupResult {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CreateMagicBackupResult);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CreateMagicBackupResult()';
  }
}

/// @nodoc
class $CreateMagicBackupResultCopyWith<$Res> {
  $CreateMagicBackupResultCopyWith(
      CreateMagicBackupResult _, $Res Function(CreateMagicBackupResult) __);
}

/// Adds pattern-matching-related methods to [CreateMagicBackupResult].
extension CreateMagicBackupResultPatterns on CreateMagicBackupResult {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CreateMagicBackupResult_Success value)? success,
    TResult Function(CreateMagicBackupResult_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case CreateMagicBackupResult_Success() when success != null:
        return success(_that);
      case CreateMagicBackupResult_Error() when error != null:
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CreateMagicBackupResult_Success value) success,
    required TResult Function(CreateMagicBackupResult_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case CreateMagicBackupResult_Success():
        return success(_that);
      case CreateMagicBackupResult_Error():
        return error(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupResult_Success value)? success,
    TResult? Function(CreateMagicBackupResult_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case CreateMagicBackupResult_Success() when success != null:
        return success(_that);
      case CreateMagicBackupResult_Error() when error != null:
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case CreateMagicBackupResult_Success() when success != null:
        return success();
      case CreateMagicBackupResult_Error() when error != null:
        return error(_that.error);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() success,
    required TResult Function(String error) error,
  }) {
    final _that = this;
    switch (_that) {
      case CreateMagicBackupResult_Success():
        return success();
      case CreateMagicBackupResult_Error():
        return error(_that.error);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? success,
    TResult? Function(String error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case CreateMagicBackupResult_Success() when success != null:
        return success();
      case CreateMagicBackupResult_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class CreateMagicBackupResult_Success extends CreateMagicBackupResult {
  const CreateMagicBackupResult_Success() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CreateMagicBackupResult_Success);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CreateMagicBackupResult.success()';
  }
}

/// @nodoc

class CreateMagicBackupResult_Error extends CreateMagicBackupResult {
  const CreateMagicBackupResult_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of CreateMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CreateMagicBackupResult_ErrorCopyWith<CreateMagicBackupResult_Error>
      get copyWith => _$CreateMagicBackupResult_ErrorCopyWithImpl<
          CreateMagicBackupResult_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CreateMagicBackupResult_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'CreateMagicBackupResult.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $CreateMagicBackupResult_ErrorCopyWith<$Res>
    implements $CreateMagicBackupResultCopyWith<$Res> {
  factory $CreateMagicBackupResult_ErrorCopyWith(
          CreateMagicBackupResult_Error value,
          $Res Function(CreateMagicBackupResult_Error) _then) =
      _$CreateMagicBackupResult_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$CreateMagicBackupResult_ErrorCopyWithImpl<$Res>
    implements $CreateMagicBackupResult_ErrorCopyWith<$Res> {
  _$CreateMagicBackupResult_ErrorCopyWithImpl(this._self, this._then);

  final CreateMagicBackupResult_Error _self;
  final $Res Function(CreateMagicBackupResult_Error) _then;

  /// Create a copy of CreateMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(CreateMagicBackupResult_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$MagicBackupRequestV2 {
  Object get field0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MagicBackupRequestV2 &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @override
  String toString() {
    return 'MagicBackupRequestV2(field0: $field0)';
  }
}

/// @nodoc
class $MagicBackupRequestV2CopyWith<$Res> {
  $MagicBackupRequestV2CopyWith(
      MagicBackupRequestV2 _, $Res Function(MagicBackupRequestV2) __);
}

/// Adds pattern-matching-related methods to [MagicBackupRequestV2].
extension MagicBackupRequestV2Patterns on MagicBackupRequestV2 {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MagicBackupRequestV2_Create value)? create,
    TResult Function(MagicBackupRequestV2_Get value)? get_,
    TResult Function(MagicBackupRequestV2_Delete value)? delete,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupRequestV2_Create() when create != null:
        return create(_that);
      case MagicBackupRequestV2_Get() when get_ != null:
        return get_(_that);
      case MagicBackupRequestV2_Delete() when delete != null:
        return delete(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MagicBackupRequestV2_Create value) create,
    required TResult Function(MagicBackupRequestV2_Get value) get_,
    required TResult Function(MagicBackupRequestV2_Delete value) delete,
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupRequestV2_Create():
        return create(_that);
      case MagicBackupRequestV2_Get():
        return get_(_that);
      case MagicBackupRequestV2_Delete():
        return delete(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MagicBackupRequestV2_Create value)? create,
    TResult? Function(MagicBackupRequestV2_Get value)? get_,
    TResult? Function(MagicBackupRequestV2_Delete value)? delete,
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupRequestV2_Create() when create != null:
        return create(_that);
      case MagicBackupRequestV2_Get() when get_ != null:
        return get_(_that);
      case MagicBackupRequestV2_Delete() when delete != null:
        return delete(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CreateMagicBackupV2 field0)? create,
    TResult Function(GetMagicBackupV2 field0)? get_,
    TResult Function(DeleteMagicBackupV2 field0)? delete,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupRequestV2_Create() when create != null:
        return create(_that.field0);
      case MagicBackupRequestV2_Get() when get_ != null:
        return get_(_that.field0);
      case MagicBackupRequestV2_Delete() when delete != null:
        return delete(_that.field0);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CreateMagicBackupV2 field0) create,
    required TResult Function(GetMagicBackupV2 field0) get_,
    required TResult Function(DeleteMagicBackupV2 field0) delete,
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupRequestV2_Create():
        return create(_that.field0);
      case MagicBackupRequestV2_Get():
        return get_(_that.field0);
      case MagicBackupRequestV2_Delete():
        return delete(_that.field0);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CreateMagicBackupV2 field0)? create,
    TResult? Function(GetMagicBackupV2 field0)? get_,
    TResult? Function(DeleteMagicBackupV2 field0)? delete,
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupRequestV2_Create() when create != null:
        return create(_that.field0);
      case MagicBackupRequestV2_Get() when get_ != null:
        return get_(_that.field0);
      case MagicBackupRequestV2_Delete() when delete != null:
        return delete(_that.field0);
      case _:
        return null;
    }
  }
}

/// @nodoc

class MagicBackupRequestV2_Create extends MagicBackupRequestV2 {
  const MagicBackupRequestV2_Create(this.field0) : super._();

  @override
  final CreateMagicBackupV2 field0;

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MagicBackupRequestV2_CreateCopyWith<MagicBackupRequestV2_Create>
      get copyWith => _$MagicBackupRequestV2_CreateCopyWithImpl<
          MagicBackupRequestV2_Create>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MagicBackupRequestV2_Create &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'MagicBackupRequestV2.create(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $MagicBackupRequestV2_CreateCopyWith<$Res>
    implements $MagicBackupRequestV2CopyWith<$Res> {
  factory $MagicBackupRequestV2_CreateCopyWith(
          MagicBackupRequestV2_Create value,
          $Res Function(MagicBackupRequestV2_Create) _then) =
      _$MagicBackupRequestV2_CreateCopyWithImpl;
  @useResult
  $Res call({CreateMagicBackupV2 field0});
}

/// @nodoc
class _$MagicBackupRequestV2_CreateCopyWithImpl<$Res>
    implements $MagicBackupRequestV2_CreateCopyWith<$Res> {
  _$MagicBackupRequestV2_CreateCopyWithImpl(this._self, this._then);

  final MagicBackupRequestV2_Create _self;
  final $Res Function(MagicBackupRequestV2_Create) _then;

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(MagicBackupRequestV2_Create(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as CreateMagicBackupV2,
    ));
  }
}

/// @nodoc

class MagicBackupRequestV2_Get extends MagicBackupRequestV2 {
  const MagicBackupRequestV2_Get(this.field0) : super._();

  @override
  final GetMagicBackupV2 field0;

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MagicBackupRequestV2_GetCopyWith<MagicBackupRequestV2_Get> get copyWith =>
      _$MagicBackupRequestV2_GetCopyWithImpl<MagicBackupRequestV2_Get>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MagicBackupRequestV2_Get &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'MagicBackupRequestV2.get_(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $MagicBackupRequestV2_GetCopyWith<$Res>
    implements $MagicBackupRequestV2CopyWith<$Res> {
  factory $MagicBackupRequestV2_GetCopyWith(MagicBackupRequestV2_Get value,
          $Res Function(MagicBackupRequestV2_Get) _then) =
      _$MagicBackupRequestV2_GetCopyWithImpl;
  @useResult
  $Res call({GetMagicBackupV2 field0});
}

/// @nodoc
class _$MagicBackupRequestV2_GetCopyWithImpl<$Res>
    implements $MagicBackupRequestV2_GetCopyWith<$Res> {
  _$MagicBackupRequestV2_GetCopyWithImpl(this._self, this._then);

  final MagicBackupRequestV2_Get _self;
  final $Res Function(MagicBackupRequestV2_Get) _then;

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(MagicBackupRequestV2_Get(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as GetMagicBackupV2,
    ));
  }
}

/// @nodoc

class MagicBackupRequestV2_Delete extends MagicBackupRequestV2 {
  const MagicBackupRequestV2_Delete(this.field0) : super._();

  @override
  final DeleteMagicBackupV2 field0;

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MagicBackupRequestV2_DeleteCopyWith<MagicBackupRequestV2_Delete>
      get copyWith => _$MagicBackupRequestV2_DeleteCopyWithImpl<
          MagicBackupRequestV2_Delete>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MagicBackupRequestV2_Delete &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'MagicBackupRequestV2.delete(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $MagicBackupRequestV2_DeleteCopyWith<$Res>
    implements $MagicBackupRequestV2CopyWith<$Res> {
  factory $MagicBackupRequestV2_DeleteCopyWith(
          MagicBackupRequestV2_Delete value,
          $Res Function(MagicBackupRequestV2_Delete) _then) =
      _$MagicBackupRequestV2_DeleteCopyWithImpl;
  @useResult
  $Res call({DeleteMagicBackupV2 field0});
}

/// @nodoc
class _$MagicBackupRequestV2_DeleteCopyWithImpl<$Res>
    implements $MagicBackupRequestV2_DeleteCopyWith<$Res> {
  _$MagicBackupRequestV2_DeleteCopyWithImpl(this._self, this._then);

  final MagicBackupRequestV2_Delete _self;
  final $Res Function(MagicBackupRequestV2_Delete) _then;

  /// Create a copy of MagicBackupRequestV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(MagicBackupRequestV2_Delete(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as DeleteMagicBackupV2,
    ));
  }
}

/// @nodoc
mixin _$MagicBackupResponseV2 {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is MagicBackupResponseV2);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MagicBackupResponseV2()';
  }
}

/// @nodoc
class $MagicBackupResponseV2CopyWith<$Res> {
  $MagicBackupResponseV2CopyWith(
      MagicBackupResponseV2 _, $Res Function(MagicBackupResponseV2) __);
}

/// Adds pattern-matching-related methods to [MagicBackupResponseV2].
extension MagicBackupResponseV2Patterns on MagicBackupResponseV2 {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MagicBackupResponseV2_Created value)? created,
    TResult Function(MagicBackupResponseV2_Backup value)? backup,
    TResult Function(MagicBackupResponseV2_Deleted value)? deleted,
    TResult Function(MagicBackupResponseV2_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupResponseV2_Created() when created != null:
        return created(_that);
      case MagicBackupResponseV2_Backup() when backup != null:
        return backup(_that);
      case MagicBackupResponseV2_Deleted() when deleted != null:
        return deleted(_that);
      case MagicBackupResponseV2_Error() when error != null:
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MagicBackupResponseV2_Created value) created,
    required TResult Function(MagicBackupResponseV2_Backup value) backup,
    required TResult Function(MagicBackupResponseV2_Deleted value) deleted,
    required TResult Function(MagicBackupResponseV2_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupResponseV2_Created():
        return created(_that);
      case MagicBackupResponseV2_Backup():
        return backup(_that);
      case MagicBackupResponseV2_Deleted():
        return deleted(_that);
      case MagicBackupResponseV2_Error():
        return error(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MagicBackupResponseV2_Created value)? created,
    TResult? Function(MagicBackupResponseV2_Backup value)? backup,
    TResult? Function(MagicBackupResponseV2_Deleted value)? deleted,
    TResult? Function(MagicBackupResponseV2_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupResponseV2_Created() when created != null:
        return created(_that);
      case MagicBackupResponseV2_Backup() when backup != null:
        return backup(_that);
      case MagicBackupResponseV2_Deleted() when deleted != null:
        return deleted(_that);
      case MagicBackupResponseV2_Error() when error != null:
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? created,
    TResult Function(Uint8List data)? backup,
    TResult Function()? deleted,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupResponseV2_Created() when created != null:
        return created();
      case MagicBackupResponseV2_Backup() when backup != null:
        return backup(_that.data);
      case MagicBackupResponseV2_Deleted() when deleted != null:
        return deleted();
      case MagicBackupResponseV2_Error() when error != null:
        return error(_that.error);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() created,
    required TResult Function(Uint8List data) backup,
    required TResult Function() deleted,
    required TResult Function(String error) error,
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupResponseV2_Created():
        return created();
      case MagicBackupResponseV2_Backup():
        return backup(_that.data);
      case MagicBackupResponseV2_Deleted():
        return deleted();
      case MagicBackupResponseV2_Error():
        return error(_that.error);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? created,
    TResult? Function(Uint8List data)? backup,
    TResult? Function()? deleted,
    TResult? Function(String error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupResponseV2_Created() when created != null:
        return created();
      case MagicBackupResponseV2_Backup() when backup != null:
        return backup(_that.data);
      case MagicBackupResponseV2_Deleted() when deleted != null:
        return deleted();
      case MagicBackupResponseV2_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class MagicBackupResponseV2_Created extends MagicBackupResponseV2 {
  const MagicBackupResponseV2_Created() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MagicBackupResponseV2_Created);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MagicBackupResponseV2.created()';
  }
}

/// @nodoc

class MagicBackupResponseV2_Backup extends MagicBackupResponseV2 {
  const MagicBackupResponseV2_Backup({required this.data}) : super._();

  final Uint8List data;

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MagicBackupResponseV2_BackupCopyWith<MagicBackupResponseV2_Backup>
      get copyWith => _$MagicBackupResponseV2_BackupCopyWithImpl<
          MagicBackupResponseV2_Backup>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MagicBackupResponseV2_Backup &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'MagicBackupResponseV2.backup(data: $data)';
  }
}

/// @nodoc
abstract mixin class $MagicBackupResponseV2_BackupCopyWith<$Res>
    implements $MagicBackupResponseV2CopyWith<$Res> {
  factory $MagicBackupResponseV2_BackupCopyWith(
          MagicBackupResponseV2_Backup value,
          $Res Function(MagicBackupResponseV2_Backup) _then) =
      _$MagicBackupResponseV2_BackupCopyWithImpl;
  @useResult
  $Res call({Uint8List data});
}

/// @nodoc
class _$MagicBackupResponseV2_BackupCopyWithImpl<$Res>
    implements $MagicBackupResponseV2_BackupCopyWith<$Res> {
  _$MagicBackupResponseV2_BackupCopyWithImpl(this._self, this._then);

  final MagicBackupResponseV2_Backup _self;
  final $Res Function(MagicBackupResponseV2_Backup) _then;

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
  }) {
    return _then(MagicBackupResponseV2_Backup(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ));
  }
}

/// @nodoc

class MagicBackupResponseV2_Deleted extends MagicBackupResponseV2 {
  const MagicBackupResponseV2_Deleted() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MagicBackupResponseV2_Deleted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MagicBackupResponseV2.deleted()';
  }
}

/// @nodoc

class MagicBackupResponseV2_Error extends MagicBackupResponseV2 {
  const MagicBackupResponseV2_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MagicBackupResponseV2_ErrorCopyWith<MagicBackupResponseV2_Error>
      get copyWith => _$MagicBackupResponseV2_ErrorCopyWithImpl<
          MagicBackupResponseV2_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MagicBackupResponseV2_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'MagicBackupResponseV2.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $MagicBackupResponseV2_ErrorCopyWith<$Res>
    implements $MagicBackupResponseV2CopyWith<$Res> {
  factory $MagicBackupResponseV2_ErrorCopyWith(
          MagicBackupResponseV2_Error value,
          $Res Function(MagicBackupResponseV2_Error) _then) =
      _$MagicBackupResponseV2_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$MagicBackupResponseV2_ErrorCopyWithImpl<$Res>
    implements $MagicBackupResponseV2_ErrorCopyWith<$Res> {
  _$MagicBackupResponseV2_ErrorCopyWithImpl(this._self, this._then);

  final MagicBackupResponseV2_Error _self;
  final $Res Function(MagicBackupResponseV2_Error) _then;

  /// Create a copy of MagicBackupResponseV2
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(MagicBackupResponseV2_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$RestoreMagicBackupEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RestoreMagicBackupEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RestoreMagicBackupEvent()';
  }
}

/// @nodoc
class $RestoreMagicBackupEventCopyWith<$Res> {
  $RestoreMagicBackupEventCopyWith(
      RestoreMagicBackupEvent _, $Res Function(RestoreMagicBackupEvent) __);
}

/// Adds pattern-matching-related methods to [RestoreMagicBackupEvent].
extension RestoreMagicBackupEventPatterns on RestoreMagicBackupEvent {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreMagicBackupEvent_NotFound value)? notFound,
    TResult Function(RestoreMagicBackupEvent_Starting value)? starting,
    TResult Function(RestoreMagicBackupEvent_Chunk value)? chunk,
    TResult Function(RestoreMagicBackupEvent_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RestoreMagicBackupEvent_NotFound() when notFound != null:
        return notFound(_that);
      case RestoreMagicBackupEvent_Starting() when starting != null:
        return starting(_that);
      case RestoreMagicBackupEvent_Chunk() when chunk != null:
        return chunk(_that);
      case RestoreMagicBackupEvent_Error() when error != null:
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreMagicBackupEvent_NotFound value) notFound,
    required TResult Function(RestoreMagicBackupEvent_Starting value) starting,
    required TResult Function(RestoreMagicBackupEvent_Chunk value) chunk,
    required TResult Function(RestoreMagicBackupEvent_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case RestoreMagicBackupEvent_NotFound():
        return notFound(_that);
      case RestoreMagicBackupEvent_Starting():
        return starting(_that);
      case RestoreMagicBackupEvent_Chunk():
        return chunk(_that);
      case RestoreMagicBackupEvent_Error():
        return error(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreMagicBackupEvent_NotFound value)? notFound,
    TResult? Function(RestoreMagicBackupEvent_Starting value)? starting,
    TResult? Function(RestoreMagicBackupEvent_Chunk value)? chunk,
    TResult? Function(RestoreMagicBackupEvent_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case RestoreMagicBackupEvent_NotFound() when notFound != null:
        return notFound(_that);
      case RestoreMagicBackupEvent_Starting() when starting != null:
        return starting(_that);
      case RestoreMagicBackupEvent_Chunk() when chunk != null:
        return chunk(_that);
      case RestoreMagicBackupEvent_Error() when error != null:
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notFound,
    TResult Function(BackupMetadata field0)? starting,
    TResult Function(BackupChunk field0)? chunk,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RestoreMagicBackupEvent_NotFound() when notFound != null:
        return notFound();
      case RestoreMagicBackupEvent_Starting() when starting != null:
        return starting(_that.field0);
      case RestoreMagicBackupEvent_Chunk() when chunk != null:
        return chunk(_that.field0);
      case RestoreMagicBackupEvent_Error() when error != null:
        return error(_that.error);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notFound,
    required TResult Function(BackupMetadata field0) starting,
    required TResult Function(BackupChunk field0) chunk,
    required TResult Function(String error) error,
  }) {
    final _that = this;
    switch (_that) {
      case RestoreMagicBackupEvent_NotFound():
        return notFound();
      case RestoreMagicBackupEvent_Starting():
        return starting(_that.field0);
      case RestoreMagicBackupEvent_Chunk():
        return chunk(_that.field0);
      case RestoreMagicBackupEvent_Error():
        return error(_that.error);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notFound,
    TResult? Function(BackupMetadata field0)? starting,
    TResult? Function(BackupChunk field0)? chunk,
    TResult? Function(String error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case RestoreMagicBackupEvent_NotFound() when notFound != null:
        return notFound();
      case RestoreMagicBackupEvent_Starting() when starting != null:
        return starting(_that.field0);
      case RestoreMagicBackupEvent_Chunk() when chunk != null:
        return chunk(_that.field0);
      case RestoreMagicBackupEvent_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class RestoreMagicBackupEvent_NotFound extends RestoreMagicBackupEvent {
  const RestoreMagicBackupEvent_NotFound() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RestoreMagicBackupEvent_NotFound);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RestoreMagicBackupEvent.notFound()';
  }
}

/// @nodoc

class RestoreMagicBackupEvent_Starting extends RestoreMagicBackupEvent {
  const RestoreMagicBackupEvent_Starting(this.field0) : super._();

  final BackupMetadata field0;

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RestoreMagicBackupEvent_StartingCopyWith<RestoreMagicBackupEvent_Starting>
      get copyWith => _$RestoreMagicBackupEvent_StartingCopyWithImpl<
          RestoreMagicBackupEvent_Starting>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RestoreMagicBackupEvent_Starting &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'RestoreMagicBackupEvent.starting(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $RestoreMagicBackupEvent_StartingCopyWith<$Res>
    implements $RestoreMagicBackupEventCopyWith<$Res> {
  factory $RestoreMagicBackupEvent_StartingCopyWith(
          RestoreMagicBackupEvent_Starting value,
          $Res Function(RestoreMagicBackupEvent_Starting) _then) =
      _$RestoreMagicBackupEvent_StartingCopyWithImpl;
  @useResult
  $Res call({BackupMetadata field0});
}

/// @nodoc
class _$RestoreMagicBackupEvent_StartingCopyWithImpl<$Res>
    implements $RestoreMagicBackupEvent_StartingCopyWith<$Res> {
  _$RestoreMagicBackupEvent_StartingCopyWithImpl(this._self, this._then);

  final RestoreMagicBackupEvent_Starting _self;
  final $Res Function(RestoreMagicBackupEvent_Starting) _then;

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(RestoreMagicBackupEvent_Starting(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BackupMetadata,
    ));
  }
}

/// @nodoc

class RestoreMagicBackupEvent_Chunk extends RestoreMagicBackupEvent {
  const RestoreMagicBackupEvent_Chunk(this.field0) : super._();

  final BackupChunk field0;

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RestoreMagicBackupEvent_ChunkCopyWith<RestoreMagicBackupEvent_Chunk>
      get copyWith => _$RestoreMagicBackupEvent_ChunkCopyWithImpl<
          RestoreMagicBackupEvent_Chunk>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RestoreMagicBackupEvent_Chunk &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'RestoreMagicBackupEvent.chunk(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $RestoreMagicBackupEvent_ChunkCopyWith<$Res>
    implements $RestoreMagicBackupEventCopyWith<$Res> {
  factory $RestoreMagicBackupEvent_ChunkCopyWith(
          RestoreMagicBackupEvent_Chunk value,
          $Res Function(RestoreMagicBackupEvent_Chunk) _then) =
      _$RestoreMagicBackupEvent_ChunkCopyWithImpl;
  @useResult
  $Res call({BackupChunk field0});
}

/// @nodoc
class _$RestoreMagicBackupEvent_ChunkCopyWithImpl<$Res>
    implements $RestoreMagicBackupEvent_ChunkCopyWith<$Res> {
  _$RestoreMagicBackupEvent_ChunkCopyWithImpl(this._self, this._then);

  final RestoreMagicBackupEvent_Chunk _self;
  final $Res Function(RestoreMagicBackupEvent_Chunk) _then;

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(RestoreMagicBackupEvent_Chunk(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BackupChunk,
    ));
  }
}

/// @nodoc

class RestoreMagicBackupEvent_Error extends RestoreMagicBackupEvent {
  const RestoreMagicBackupEvent_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RestoreMagicBackupEvent_ErrorCopyWith<RestoreMagicBackupEvent_Error>
      get copyWith => _$RestoreMagicBackupEvent_ErrorCopyWithImpl<
          RestoreMagicBackupEvent_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RestoreMagicBackupEvent_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'RestoreMagicBackupEvent.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $RestoreMagicBackupEvent_ErrorCopyWith<$Res>
    implements $RestoreMagicBackupEventCopyWith<$Res> {
  factory $RestoreMagicBackupEvent_ErrorCopyWith(
          RestoreMagicBackupEvent_Error value,
          $Res Function(RestoreMagicBackupEvent_Error) _then) =
      _$RestoreMagicBackupEvent_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$RestoreMagicBackupEvent_ErrorCopyWithImpl<$Res>
    implements $RestoreMagicBackupEvent_ErrorCopyWith<$Res> {
  _$RestoreMagicBackupEvent_ErrorCopyWithImpl(this._self, this._then);

  final RestoreMagicBackupEvent_Error _self;
  final $Res Function(RestoreMagicBackupEvent_Error) _then;

  /// Create a copy of RestoreMagicBackupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(RestoreMagicBackupEvent_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$RestoreMagicBackupResult {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RestoreMagicBackupResult);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RestoreMagicBackupResult()';
  }
}

/// @nodoc
class $RestoreMagicBackupResultCopyWith<$Res> {
  $RestoreMagicBackupResultCopyWith(
      RestoreMagicBackupResult _, $Res Function(RestoreMagicBackupResult) __);
}

/// Adds pattern-matching-related methods to [RestoreMagicBackupResult].
extension RestoreMagicBackupResultPatterns on RestoreMagicBackupResult {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreMagicBackupResult_Success value)? success,
    TResult Function(RestoreMagicBackupResult_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RestoreMagicBackupResult_Success() when success != null:
        return success(_that);
      case RestoreMagicBackupResult_Error() when error != null:
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreMagicBackupResult_Success value) success,
    required TResult Function(RestoreMagicBackupResult_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case RestoreMagicBackupResult_Success():
        return success(_that);
      case RestoreMagicBackupResult_Error():
        return error(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreMagicBackupResult_Success value)? success,
    TResult? Function(RestoreMagicBackupResult_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case RestoreMagicBackupResult_Success() when success != null:
        return success(_that);
      case RestoreMagicBackupResult_Error() when error != null:
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RestoreMagicBackupResult_Success() when success != null:
        return success();
      case RestoreMagicBackupResult_Error() when error != null:
        return error(_that.error);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() success,
    required TResult Function(String error) error,
  }) {
    final _that = this;
    switch (_that) {
      case RestoreMagicBackupResult_Success():
        return success();
      case RestoreMagicBackupResult_Error():
        return error(_that.error);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? success,
    TResult? Function(String error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case RestoreMagicBackupResult_Success() when success != null:
        return success();
      case RestoreMagicBackupResult_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class RestoreMagicBackupResult_Success extends RestoreMagicBackupResult {
  const RestoreMagicBackupResult_Success() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RestoreMagicBackupResult_Success);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RestoreMagicBackupResult.success()';
  }
}

/// @nodoc

class RestoreMagicBackupResult_Error extends RestoreMagicBackupResult {
  const RestoreMagicBackupResult_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of RestoreMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RestoreMagicBackupResult_ErrorCopyWith<RestoreMagicBackupResult_Error>
      get copyWith => _$RestoreMagicBackupResult_ErrorCopyWithImpl<
          RestoreMagicBackupResult_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RestoreMagicBackupResult_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'RestoreMagicBackupResult.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $RestoreMagicBackupResult_ErrorCopyWith<$Res>
    implements $RestoreMagicBackupResultCopyWith<$Res> {
  factory $RestoreMagicBackupResult_ErrorCopyWith(
          RestoreMagicBackupResult_Error value,
          $Res Function(RestoreMagicBackupResult_Error) _then) =
      _$RestoreMagicBackupResult_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$RestoreMagicBackupResult_ErrorCopyWithImpl<$Res>
    implements $RestoreMagicBackupResult_ErrorCopyWith<$Res> {
  _$RestoreMagicBackupResult_ErrorCopyWithImpl(this._self, this._then);

  final RestoreMagicBackupResult_Error _self;
  final $Res Function(RestoreMagicBackupResult_Error) _then;

  /// Create a copy of RestoreMagicBackupResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(RestoreMagicBackupResult_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$RestoreShardResponse {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RestoreShardResponse);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RestoreShardResponse()';
  }
}

/// @nodoc
class $RestoreShardResponseCopyWith<$Res> {
  $RestoreShardResponseCopyWith(
      RestoreShardResponse _, $Res Function(RestoreShardResponse) __);
}

/// Adds pattern-matching-related methods to [RestoreShardResponse].
extension RestoreShardResponsePatterns on RestoreShardResponse {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RestoreShardResponse_Success value)? success,
    TResult Function(RestoreShardResponse_Error value)? error,
    TResult Function(RestoreShardResponse_NotFound value)? notFound,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RestoreShardResponse_Success() when success != null:
        return success(_that);
      case RestoreShardResponse_Error() when error != null:
        return error(_that);
      case RestoreShardResponse_NotFound() when notFound != null:
        return notFound(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RestoreShardResponse_Success value) success,
    required TResult Function(RestoreShardResponse_Error value) error,
    required TResult Function(RestoreShardResponse_NotFound value) notFound,
  }) {
    final _that = this;
    switch (_that) {
      case RestoreShardResponse_Success():
        return success(_that);
      case RestoreShardResponse_Error():
        return error(_that);
      case RestoreShardResponse_NotFound():
        return notFound(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RestoreShardResponse_Success value)? success,
    TResult? Function(RestoreShardResponse_Error value)? error,
    TResult? Function(RestoreShardResponse_NotFound value)? notFound,
  }) {
    final _that = this;
    switch (_that) {
      case RestoreShardResponse_Success() when success != null:
        return success(_that);
      case RestoreShardResponse_Error() when error != null:
        return error(_that);
      case RestoreShardResponse_NotFound() when notFound != null:
        return notFound(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Shard shard)? success,
    TResult Function(String error)? error,
    TResult Function()? notFound,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RestoreShardResponse_Success() when success != null:
        return success(_that.shard);
      case RestoreShardResponse_Error() when error != null:
        return error(_that.error);
      case RestoreShardResponse_NotFound() when notFound != null:
        return notFound();
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Shard shard) success,
    required TResult Function(String error) error,
    required TResult Function() notFound,
  }) {
    final _that = this;
    switch (_that) {
      case RestoreShardResponse_Success():
        return success(_that.shard);
      case RestoreShardResponse_Error():
        return error(_that.error);
      case RestoreShardResponse_NotFound():
        return notFound();
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Shard shard)? success,
    TResult? Function(String error)? error,
    TResult? Function()? notFound,
  }) {
    final _that = this;
    switch (_that) {
      case RestoreShardResponse_Success() when success != null:
        return success(_that.shard);
      case RestoreShardResponse_Error() when error != null:
        return error(_that.error);
      case RestoreShardResponse_NotFound() when notFound != null:
        return notFound();
      case _:
        return null;
    }
  }
}

/// @nodoc

class RestoreShardResponse_Success extends RestoreShardResponse {
  const RestoreShardResponse_Success({required this.shard}) : super._();

  final Shard shard;

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RestoreShardResponse_SuccessCopyWith<RestoreShardResponse_Success>
      get copyWith => _$RestoreShardResponse_SuccessCopyWithImpl<
          RestoreShardResponse_Success>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RestoreShardResponse_Success &&
            (identical(other.shard, shard) || other.shard == shard));
  }

  @override
  int get hashCode => Object.hash(runtimeType, shard);

  @override
  String toString() {
    return 'RestoreShardResponse.success(shard: $shard)';
  }
}

/// @nodoc
abstract mixin class $RestoreShardResponse_SuccessCopyWith<$Res>
    implements $RestoreShardResponseCopyWith<$Res> {
  factory $RestoreShardResponse_SuccessCopyWith(
          RestoreShardResponse_Success value,
          $Res Function(RestoreShardResponse_Success) _then) =
      _$RestoreShardResponse_SuccessCopyWithImpl;
  @useResult
  $Res call({Shard shard});
}

/// @nodoc
class _$RestoreShardResponse_SuccessCopyWithImpl<$Res>
    implements $RestoreShardResponse_SuccessCopyWith<$Res> {
  _$RestoreShardResponse_SuccessCopyWithImpl(this._self, this._then);

  final RestoreShardResponse_Success _self;
  final $Res Function(RestoreShardResponse_Success) _then;

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? shard = null,
  }) {
    return _then(RestoreShardResponse_Success(
      shard: null == shard
          ? _self.shard
          : shard // ignore: cast_nullable_to_non_nullable
              as Shard,
    ));
  }
}

/// @nodoc

class RestoreShardResponse_Error extends RestoreShardResponse {
  const RestoreShardResponse_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RestoreShardResponse_ErrorCopyWith<RestoreShardResponse_Error>
      get copyWith =>
          _$RestoreShardResponse_ErrorCopyWithImpl<RestoreShardResponse_Error>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RestoreShardResponse_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'RestoreShardResponse.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $RestoreShardResponse_ErrorCopyWith<$Res>
    implements $RestoreShardResponseCopyWith<$Res> {
  factory $RestoreShardResponse_ErrorCopyWith(RestoreShardResponse_Error value,
          $Res Function(RestoreShardResponse_Error) _then) =
      _$RestoreShardResponse_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$RestoreShardResponse_ErrorCopyWithImpl<$Res>
    implements $RestoreShardResponse_ErrorCopyWith<$Res> {
  _$RestoreShardResponse_ErrorCopyWithImpl(this._self, this._then);

  final RestoreShardResponse_Error _self;
  final $Res Function(RestoreShardResponse_Error) _then;

  /// Create a copy of RestoreShardResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(RestoreShardResponse_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class RestoreShardResponse_NotFound extends RestoreShardResponse {
  const RestoreShardResponse_NotFound() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RestoreShardResponse_NotFound);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RestoreShardResponse.notFound()';
  }
}

// dart format on
