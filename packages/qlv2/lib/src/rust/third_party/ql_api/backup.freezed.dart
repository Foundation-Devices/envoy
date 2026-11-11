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
mixin _$DownloadMagicBackupHeader {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadMagicBackupHeader);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'DownloadMagicBackupHeader()';
  }
}

/// @nodoc
class $DownloadMagicBackupHeaderCopyWith<$Res> {
  $DownloadMagicBackupHeaderCopyWith(
      DownloadMagicBackupHeader _, $Res Function(DownloadMagicBackupHeader) __);
}

/// Adds pattern-matching-related methods to [DownloadMagicBackupHeader].
extension DownloadMagicBackupHeaderPatterns on DownloadMagicBackupHeader {
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
    TResult Function(DownloadMagicBackupHeader_Found value)? found,
    TResult Function(DownloadMagicBackupHeader_NotFound value)? notFound,
    TResult Function(DownloadMagicBackupHeader_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case DownloadMagicBackupHeader_Found() when found != null:
        return found(_that);
      case DownloadMagicBackupHeader_NotFound() when notFound != null:
        return notFound(_that);
      case DownloadMagicBackupHeader_Error() when error != null:
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
    required TResult Function(DownloadMagicBackupHeader_Found value) found,
    required TResult Function(DownloadMagicBackupHeader_NotFound value)
        notFound,
    required TResult Function(DownloadMagicBackupHeader_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case DownloadMagicBackupHeader_Found():
        return found(_that);
      case DownloadMagicBackupHeader_NotFound():
        return notFound(_that);
      case DownloadMagicBackupHeader_Error():
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
    TResult? Function(DownloadMagicBackupHeader_Found value)? found,
    TResult? Function(DownloadMagicBackupHeader_NotFound value)? notFound,
    TResult? Function(DownloadMagicBackupHeader_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case DownloadMagicBackupHeader_Found() when found != null:
        return found(_that);
      case DownloadMagicBackupHeader_NotFound() when notFound != null:
        return notFound(_that);
      case DownloadMagicBackupHeader_Error() when error != null:
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
    TResult Function(BackupMetadata field0)? found,
    TResult Function()? notFound,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case DownloadMagicBackupHeader_Found() when found != null:
        return found(_that.field0);
      case DownloadMagicBackupHeader_NotFound() when notFound != null:
        return notFound();
      case DownloadMagicBackupHeader_Error() when error != null:
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
    required TResult Function(BackupMetadata field0) found,
    required TResult Function() notFound,
    required TResult Function(String error) error,
  }) {
    final _that = this;
    switch (_that) {
      case DownloadMagicBackupHeader_Found():
        return found(_that.field0);
      case DownloadMagicBackupHeader_NotFound():
        return notFound();
      case DownloadMagicBackupHeader_Error():
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
    TResult? Function(BackupMetadata field0)? found,
    TResult? Function()? notFound,
    TResult? Function(String error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case DownloadMagicBackupHeader_Found() when found != null:
        return found(_that.field0);
      case DownloadMagicBackupHeader_NotFound() when notFound != null:
        return notFound();
      case DownloadMagicBackupHeader_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class DownloadMagicBackupHeader_Found extends DownloadMagicBackupHeader {
  const DownloadMagicBackupHeader_Found(this.field0) : super._();

  final BackupMetadata field0;

  /// Create a copy of DownloadMagicBackupHeader
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadMagicBackupHeader_FoundCopyWith<DownloadMagicBackupHeader_Found>
      get copyWith => _$DownloadMagicBackupHeader_FoundCopyWithImpl<
          DownloadMagicBackupHeader_Found>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadMagicBackupHeader_Found &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'DownloadMagicBackupHeader.found(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $DownloadMagicBackupHeader_FoundCopyWith<$Res>
    implements $DownloadMagicBackupHeaderCopyWith<$Res> {
  factory $DownloadMagicBackupHeader_FoundCopyWith(
          DownloadMagicBackupHeader_Found value,
          $Res Function(DownloadMagicBackupHeader_Found) _then) =
      _$DownloadMagicBackupHeader_FoundCopyWithImpl;
  @useResult
  $Res call({BackupMetadata field0});
}

/// @nodoc
class _$DownloadMagicBackupHeader_FoundCopyWithImpl<$Res>
    implements $DownloadMagicBackupHeader_FoundCopyWith<$Res> {
  _$DownloadMagicBackupHeader_FoundCopyWithImpl(this._self, this._then);

  final DownloadMagicBackupHeader_Found _self;
  final $Res Function(DownloadMagicBackupHeader_Found) _then;

  /// Create a copy of DownloadMagicBackupHeader
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(DownloadMagicBackupHeader_Found(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BackupMetadata,
    ));
  }
}

/// @nodoc

class DownloadMagicBackupHeader_NotFound extends DownloadMagicBackupHeader {
  const DownloadMagicBackupHeader_NotFound() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadMagicBackupHeader_NotFound);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'DownloadMagicBackupHeader.notFound()';
  }
}

/// @nodoc

class DownloadMagicBackupHeader_Error extends DownloadMagicBackupHeader {
  const DownloadMagicBackupHeader_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of DownloadMagicBackupHeader
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadMagicBackupHeader_ErrorCopyWith<DownloadMagicBackupHeader_Error>
      get copyWith => _$DownloadMagicBackupHeader_ErrorCopyWithImpl<
          DownloadMagicBackupHeader_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadMagicBackupHeader_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'DownloadMagicBackupHeader.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $DownloadMagicBackupHeader_ErrorCopyWith<$Res>
    implements $DownloadMagicBackupHeaderCopyWith<$Res> {
  factory $DownloadMagicBackupHeader_ErrorCopyWith(
          DownloadMagicBackupHeader_Error value,
          $Res Function(DownloadMagicBackupHeader_Error) _then) =
      _$DownloadMagicBackupHeader_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$DownloadMagicBackupHeader_ErrorCopyWithImpl<$Res>
    implements $DownloadMagicBackupHeader_ErrorCopyWith<$Res> {
  _$DownloadMagicBackupHeader_ErrorCopyWithImpl(this._self, this._then);

  final DownloadMagicBackupHeader_Error _self;
  final $Res Function(DownloadMagicBackupHeader_Error) _then;

  /// Create a copy of DownloadMagicBackupHeader
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(DownloadMagicBackupHeader_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$MagicBackupRestoreResult {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is MagicBackupRestoreResult);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MagicBackupRestoreResult()';
  }
}

/// @nodoc
class $MagicBackupRestoreResultCopyWith<$Res> {
  $MagicBackupRestoreResultCopyWith(
      MagicBackupRestoreResult _, $Res Function(MagicBackupRestoreResult) __);
}

/// Adds pattern-matching-related methods to [MagicBackupRestoreResult].
extension MagicBackupRestoreResultPatterns on MagicBackupRestoreResult {
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
    TResult Function(MagicBackupRestoreResult_Success value)? success,
    TResult Function(MagicBackupRestoreResult_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupRestoreResult_Success() when success != null:
        return success(_that);
      case MagicBackupRestoreResult_Error() when error != null:
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
    required TResult Function(MagicBackupRestoreResult_Success value) success,
    required TResult Function(MagicBackupRestoreResult_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupRestoreResult_Success():
        return success(_that);
      case MagicBackupRestoreResult_Error():
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
    TResult? Function(MagicBackupRestoreResult_Success value)? success,
    TResult? Function(MagicBackupRestoreResult_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case MagicBackupRestoreResult_Success() when success != null:
        return success(_that);
      case MagicBackupRestoreResult_Error() when error != null:
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
      case MagicBackupRestoreResult_Success() when success != null:
        return success();
      case MagicBackupRestoreResult_Error() when error != null:
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
      case MagicBackupRestoreResult_Success():
        return success();
      case MagicBackupRestoreResult_Error():
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
      case MagicBackupRestoreResult_Success() when success != null:
        return success();
      case MagicBackupRestoreResult_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class MagicBackupRestoreResult_Success extends MagicBackupRestoreResult {
  const MagicBackupRestoreResult_Success() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MagicBackupRestoreResult_Success);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MagicBackupRestoreResult.success()';
  }
}

/// @nodoc

class MagicBackupRestoreResult_Error extends MagicBackupRestoreResult {
  const MagicBackupRestoreResult_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of MagicBackupRestoreResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MagicBackupRestoreResult_ErrorCopyWith<MagicBackupRestoreResult_Error>
      get copyWith => _$MagicBackupRestoreResult_ErrorCopyWithImpl<
          MagicBackupRestoreResult_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MagicBackupRestoreResult_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'MagicBackupRestoreResult.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $MagicBackupRestoreResult_ErrorCopyWith<$Res>
    implements $MagicBackupRestoreResultCopyWith<$Res> {
  factory $MagicBackupRestoreResult_ErrorCopyWith(
          MagicBackupRestoreResult_Error value,
          $Res Function(MagicBackupRestoreResult_Error) _then) =
      _$MagicBackupRestoreResult_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$MagicBackupRestoreResult_ErrorCopyWithImpl<$Res>
    implements $MagicBackupRestoreResult_ErrorCopyWith<$Res> {
  _$MagicBackupRestoreResult_ErrorCopyWithImpl(this._self, this._then);

  final MagicBackupRestoreResult_Error _self;
  final $Res Function(MagicBackupRestoreResult_Error) _then;

  /// Create a copy of MagicBackupRestoreResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(MagicBackupRestoreResult_Error(
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

/// @nodoc
mixin _$UploadMagicBackupResponse {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UploadMagicBackupResponse);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'UploadMagicBackupResponse()';
  }
}

/// @nodoc
class $UploadMagicBackupResponseCopyWith<$Res> {
  $UploadMagicBackupResponseCopyWith(
      UploadMagicBackupResponse _, $Res Function(UploadMagicBackupResponse) __);
}

/// Adds pattern-matching-related methods to [UploadMagicBackupResponse].
extension UploadMagicBackupResponsePatterns on UploadMagicBackupResponse {
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
    TResult Function(UploadMagicBackupResponse_Success value)? success,
    TResult Function(UploadMagicBackupResponse_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case UploadMagicBackupResponse_Success() when success != null:
        return success(_that);
      case UploadMagicBackupResponse_Error() when error != null:
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
    required TResult Function(UploadMagicBackupResponse_Success value) success,
    required TResult Function(UploadMagicBackupResponse_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case UploadMagicBackupResponse_Success():
        return success(_that);
      case UploadMagicBackupResponse_Error():
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
    TResult? Function(UploadMagicBackupResponse_Success value)? success,
    TResult? Function(UploadMagicBackupResponse_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case UploadMagicBackupResponse_Success() when success != null:
        return success(_that);
      case UploadMagicBackupResponse_Error() when error != null:
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
      case UploadMagicBackupResponse_Success() when success != null:
        return success();
      case UploadMagicBackupResponse_Error() when error != null:
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
      case UploadMagicBackupResponse_Success():
        return success();
      case UploadMagicBackupResponse_Error():
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
      case UploadMagicBackupResponse_Success() when success != null:
        return success();
      case UploadMagicBackupResponse_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class UploadMagicBackupResponse_Success extends UploadMagicBackupResponse {
  const UploadMagicBackupResponse_Success() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UploadMagicBackupResponse_Success);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'UploadMagicBackupResponse.success()';
  }
}

/// @nodoc

class UploadMagicBackupResponse_Error extends UploadMagicBackupResponse {
  const UploadMagicBackupResponse_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of UploadMagicBackupResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UploadMagicBackupResponse_ErrorCopyWith<UploadMagicBackupResponse_Error>
      get copyWith => _$UploadMagicBackupResponse_ErrorCopyWithImpl<
          UploadMagicBackupResponse_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UploadMagicBackupResponse_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'UploadMagicBackupResponse.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $UploadMagicBackupResponse_ErrorCopyWith<$Res>
    implements $UploadMagicBackupResponseCopyWith<$Res> {
  factory $UploadMagicBackupResponse_ErrorCopyWith(
          UploadMagicBackupResponse_Error value,
          $Res Function(UploadMagicBackupResponse_Error) _then) =
      _$UploadMagicBackupResponse_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$UploadMagicBackupResponse_ErrorCopyWithImpl<$Res>
    implements $UploadMagicBackupResponse_ErrorCopyWith<$Res> {
  _$UploadMagicBackupResponse_ErrorCopyWithImpl(this._self, this._then);

  final UploadMagicBackupResponse_Error _self;
  final $Res Function(UploadMagicBackupResponse_Error) _then;

  /// Create a copy of UploadMagicBackupResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(UploadMagicBackupResponse_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
