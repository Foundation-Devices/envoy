// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'firmware.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FirmwareFetchEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is FirmwareFetchEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'FirmwareFetchEvent()';
  }
}

/// @nodoc
class $FirmwareFetchEventCopyWith<$Res> {
  $FirmwareFetchEventCopyWith(
      FirmwareFetchEvent _, $Res Function(FirmwareFetchEvent) __);
}

/// Adds pattern-matching-related methods to [FirmwareFetchEvent].
extension FirmwareFetchEventPatterns on FirmwareFetchEvent {
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
    TResult Function(FirmwareFetchEvent_UpdateNotAvailable value)?
        updateNotAvailable,
    TResult Function(FirmwareFetchEvent_Starting value)? starting,
    TResult Function(FirmwareFetchEvent_Downloading value)? downloading,
    TResult Function(FirmwareFetchEvent_Chunk value)? chunk,
    TResult Function(FirmwareFetchEvent_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareFetchEvent_UpdateNotAvailable()
          when updateNotAvailable != null:
        return updateNotAvailable(_that);
      case FirmwareFetchEvent_Starting() when starting != null:
        return starting(_that);
      case FirmwareFetchEvent_Downloading() when downloading != null:
        return downloading(_that);
      case FirmwareFetchEvent_Chunk() when chunk != null:
        return chunk(_that);
      case FirmwareFetchEvent_Error() when error != null:
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
    required TResult Function(FirmwareFetchEvent_UpdateNotAvailable value)
        updateNotAvailable,
    required TResult Function(FirmwareFetchEvent_Starting value) starting,
    required TResult Function(FirmwareFetchEvent_Downloading value) downloading,
    required TResult Function(FirmwareFetchEvent_Chunk value) chunk,
    required TResult Function(FirmwareFetchEvent_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareFetchEvent_UpdateNotAvailable():
        return updateNotAvailable(_that);
      case FirmwareFetchEvent_Starting():
        return starting(_that);
      case FirmwareFetchEvent_Downloading():
        return downloading(_that);
      case FirmwareFetchEvent_Chunk():
        return chunk(_that);
      case FirmwareFetchEvent_Error():
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
    TResult? Function(FirmwareFetchEvent_UpdateNotAvailable value)?
        updateNotAvailable,
    TResult? Function(FirmwareFetchEvent_Starting value)? starting,
    TResult? Function(FirmwareFetchEvent_Downloading value)? downloading,
    TResult? Function(FirmwareFetchEvent_Chunk value)? chunk,
    TResult? Function(FirmwareFetchEvent_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareFetchEvent_UpdateNotAvailable()
          when updateNotAvailable != null:
        return updateNotAvailable(_that);
      case FirmwareFetchEvent_Starting() when starting != null:
        return starting(_that);
      case FirmwareFetchEvent_Downloading() when downloading != null:
        return downloading(_that);
      case FirmwareFetchEvent_Chunk() when chunk != null:
        return chunk(_that);
      case FirmwareFetchEvent_Error() when error != null:
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
    TResult Function()? updateNotAvailable,
    TResult Function(FirmwareUpdateAvailable field0)? starting,
    TResult Function()? downloading,
    TResult Function(FirmwareChunk field0)? chunk,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareFetchEvent_UpdateNotAvailable()
          when updateNotAvailable != null:
        return updateNotAvailable();
      case FirmwareFetchEvent_Starting() when starting != null:
        return starting(_that.field0);
      case FirmwareFetchEvent_Downloading() when downloading != null:
        return downloading();
      case FirmwareFetchEvent_Chunk() when chunk != null:
        return chunk(_that.field0);
      case FirmwareFetchEvent_Error() when error != null:
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
    required TResult Function() updateNotAvailable,
    required TResult Function(FirmwareUpdateAvailable field0) starting,
    required TResult Function() downloading,
    required TResult Function(FirmwareChunk field0) chunk,
    required TResult Function(String error) error,
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareFetchEvent_UpdateNotAvailable():
        return updateNotAvailable();
      case FirmwareFetchEvent_Starting():
        return starting(_that.field0);
      case FirmwareFetchEvent_Downloading():
        return downloading();
      case FirmwareFetchEvent_Chunk():
        return chunk(_that.field0);
      case FirmwareFetchEvent_Error():
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
    TResult? Function()? updateNotAvailable,
    TResult? Function(FirmwareUpdateAvailable field0)? starting,
    TResult? Function()? downloading,
    TResult? Function(FirmwareChunk field0)? chunk,
    TResult? Function(String error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareFetchEvent_UpdateNotAvailable()
          when updateNotAvailable != null:
        return updateNotAvailable();
      case FirmwareFetchEvent_Starting() when starting != null:
        return starting(_that.field0);
      case FirmwareFetchEvent_Downloading() when downloading != null:
        return downloading();
      case FirmwareFetchEvent_Chunk() when chunk != null:
        return chunk(_that.field0);
      case FirmwareFetchEvent_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class FirmwareFetchEvent_UpdateNotAvailable extends FirmwareFetchEvent {
  const FirmwareFetchEvent_UpdateNotAvailable() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareFetchEvent_UpdateNotAvailable);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'FirmwareFetchEvent.updateNotAvailable()';
  }
}

/// @nodoc

class FirmwareFetchEvent_Starting extends FirmwareFetchEvent {
  const FirmwareFetchEvent_Starting(this.field0) : super._();

  final FirmwareUpdateAvailable field0;

  /// Create a copy of FirmwareFetchEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FirmwareFetchEvent_StartingCopyWith<FirmwareFetchEvent_Starting>
      get copyWith => _$FirmwareFetchEvent_StartingCopyWithImpl<
          FirmwareFetchEvent_Starting>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareFetchEvent_Starting &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'FirmwareFetchEvent.starting(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $FirmwareFetchEvent_StartingCopyWith<$Res>
    implements $FirmwareFetchEventCopyWith<$Res> {
  factory $FirmwareFetchEvent_StartingCopyWith(
          FirmwareFetchEvent_Starting value,
          $Res Function(FirmwareFetchEvent_Starting) _then) =
      _$FirmwareFetchEvent_StartingCopyWithImpl;
  @useResult
  $Res call({FirmwareUpdateAvailable field0});
}

/// @nodoc
class _$FirmwareFetchEvent_StartingCopyWithImpl<$Res>
    implements $FirmwareFetchEvent_StartingCopyWith<$Res> {
  _$FirmwareFetchEvent_StartingCopyWithImpl(this._self, this._then);

  final FirmwareFetchEvent_Starting _self;
  final $Res Function(FirmwareFetchEvent_Starting) _then;

  /// Create a copy of FirmwareFetchEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(FirmwareFetchEvent_Starting(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as FirmwareUpdateAvailable,
    ));
  }
}

/// @nodoc

class FirmwareFetchEvent_Downloading extends FirmwareFetchEvent {
  const FirmwareFetchEvent_Downloading() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareFetchEvent_Downloading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'FirmwareFetchEvent.downloading()';
  }
}

/// @nodoc

class FirmwareFetchEvent_Chunk extends FirmwareFetchEvent {
  const FirmwareFetchEvent_Chunk(this.field0) : super._();

  final FirmwareChunk field0;

  /// Create a copy of FirmwareFetchEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FirmwareFetchEvent_ChunkCopyWith<FirmwareFetchEvent_Chunk> get copyWith =>
      _$FirmwareFetchEvent_ChunkCopyWithImpl<FirmwareFetchEvent_Chunk>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareFetchEvent_Chunk &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'FirmwareFetchEvent.chunk(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $FirmwareFetchEvent_ChunkCopyWith<$Res>
    implements $FirmwareFetchEventCopyWith<$Res> {
  factory $FirmwareFetchEvent_ChunkCopyWith(FirmwareFetchEvent_Chunk value,
          $Res Function(FirmwareFetchEvent_Chunk) _then) =
      _$FirmwareFetchEvent_ChunkCopyWithImpl;
  @useResult
  $Res call({FirmwareChunk field0});
}

/// @nodoc
class _$FirmwareFetchEvent_ChunkCopyWithImpl<$Res>
    implements $FirmwareFetchEvent_ChunkCopyWith<$Res> {
  _$FirmwareFetchEvent_ChunkCopyWithImpl(this._self, this._then);

  final FirmwareFetchEvent_Chunk _self;
  final $Res Function(FirmwareFetchEvent_Chunk) _then;

  /// Create a copy of FirmwareFetchEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(FirmwareFetchEvent_Chunk(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as FirmwareChunk,
    ));
  }
}

/// @nodoc

class FirmwareFetchEvent_Error extends FirmwareFetchEvent {
  const FirmwareFetchEvent_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of FirmwareFetchEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FirmwareFetchEvent_ErrorCopyWith<FirmwareFetchEvent_Error> get copyWith =>
      _$FirmwareFetchEvent_ErrorCopyWithImpl<FirmwareFetchEvent_Error>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareFetchEvent_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'FirmwareFetchEvent.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $FirmwareFetchEvent_ErrorCopyWith<$Res>
    implements $FirmwareFetchEventCopyWith<$Res> {
  factory $FirmwareFetchEvent_ErrorCopyWith(FirmwareFetchEvent_Error value,
          $Res Function(FirmwareFetchEvent_Error) _then) =
      _$FirmwareFetchEvent_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$FirmwareFetchEvent_ErrorCopyWithImpl<$Res>
    implements $FirmwareFetchEvent_ErrorCopyWith<$Res> {
  _$FirmwareFetchEvent_ErrorCopyWithImpl(this._self, this._then);

  final FirmwareFetchEvent_Error _self;
  final $Res Function(FirmwareFetchEvent_Error) _then;

  /// Create a copy of FirmwareFetchEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(FirmwareFetchEvent_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$FirmwareInstallEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is FirmwareInstallEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'FirmwareInstallEvent()';
  }
}

/// @nodoc
class $FirmwareInstallEventCopyWith<$Res> {
  $FirmwareInstallEventCopyWith(
      FirmwareInstallEvent _, $Res Function(FirmwareInstallEvent) __);
}

/// Adds pattern-matching-related methods to [FirmwareInstallEvent].
extension FirmwareInstallEventPatterns on FirmwareInstallEvent {
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
    TResult Function(FirmwareInstallEvent_UpdateVerified value)? updateVerified,
    TResult Function(FirmwareInstallEvent_Installing value)? installing,
    TResult Function(FirmwareInstallEvent_Rebooting value)? rebooting,
    TResult Function(FirmwareInstallEvent_Success value)? success,
    TResult Function(FirmwareInstallEvent_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareInstallEvent_UpdateVerified() when updateVerified != null:
        return updateVerified(_that);
      case FirmwareInstallEvent_Installing() when installing != null:
        return installing(_that);
      case FirmwareInstallEvent_Rebooting() when rebooting != null:
        return rebooting(_that);
      case FirmwareInstallEvent_Success() when success != null:
        return success(_that);
      case FirmwareInstallEvent_Error() when error != null:
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
    required TResult Function(FirmwareInstallEvent_UpdateVerified value)
        updateVerified,
    required TResult Function(FirmwareInstallEvent_Installing value) installing,
    required TResult Function(FirmwareInstallEvent_Rebooting value) rebooting,
    required TResult Function(FirmwareInstallEvent_Success value) success,
    required TResult Function(FirmwareInstallEvent_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareInstallEvent_UpdateVerified():
        return updateVerified(_that);
      case FirmwareInstallEvent_Installing():
        return installing(_that);
      case FirmwareInstallEvent_Rebooting():
        return rebooting(_that);
      case FirmwareInstallEvent_Success():
        return success(_that);
      case FirmwareInstallEvent_Error():
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
    TResult? Function(FirmwareInstallEvent_UpdateVerified value)?
        updateVerified,
    TResult? Function(FirmwareInstallEvent_Installing value)? installing,
    TResult? Function(FirmwareInstallEvent_Rebooting value)? rebooting,
    TResult? Function(FirmwareInstallEvent_Success value)? success,
    TResult? Function(FirmwareInstallEvent_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareInstallEvent_UpdateVerified() when updateVerified != null:
        return updateVerified(_that);
      case FirmwareInstallEvent_Installing() when installing != null:
        return installing(_that);
      case FirmwareInstallEvent_Rebooting() when rebooting != null:
        return rebooting(_that);
      case FirmwareInstallEvent_Success() when success != null:
        return success(_that);
      case FirmwareInstallEvent_Error() when error != null:
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
    TResult Function()? updateVerified,
    TResult Function()? installing,
    TResult Function()? rebooting,
    TResult Function(String installedVersion)? success,
    TResult Function(String error, InstallErrorStage stage)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareInstallEvent_UpdateVerified() when updateVerified != null:
        return updateVerified();
      case FirmwareInstallEvent_Installing() when installing != null:
        return installing();
      case FirmwareInstallEvent_Rebooting() when rebooting != null:
        return rebooting();
      case FirmwareInstallEvent_Success() when success != null:
        return success(_that.installedVersion);
      case FirmwareInstallEvent_Error() when error != null:
        return error(_that.error, _that.stage);
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
    required TResult Function() updateVerified,
    required TResult Function() installing,
    required TResult Function() rebooting,
    required TResult Function(String installedVersion) success,
    required TResult Function(String error, InstallErrorStage stage) error,
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareInstallEvent_UpdateVerified():
        return updateVerified();
      case FirmwareInstallEvent_Installing():
        return installing();
      case FirmwareInstallEvent_Rebooting():
        return rebooting();
      case FirmwareInstallEvent_Success():
        return success(_that.installedVersion);
      case FirmwareInstallEvent_Error():
        return error(_that.error, _that.stage);
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
    TResult? Function()? updateVerified,
    TResult? Function()? installing,
    TResult? Function()? rebooting,
    TResult? Function(String installedVersion)? success,
    TResult? Function(String error, InstallErrorStage stage)? error,
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareInstallEvent_UpdateVerified() when updateVerified != null:
        return updateVerified();
      case FirmwareInstallEvent_Installing() when installing != null:
        return installing();
      case FirmwareInstallEvent_Rebooting() when rebooting != null:
        return rebooting();
      case FirmwareInstallEvent_Success() when success != null:
        return success(_that.installedVersion);
      case FirmwareInstallEvent_Error() when error != null:
        return error(_that.error, _that.stage);
      case _:
        return null;
    }
  }
}

/// @nodoc

class FirmwareInstallEvent_UpdateVerified extends FirmwareInstallEvent {
  const FirmwareInstallEvent_UpdateVerified() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareInstallEvent_UpdateVerified);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'FirmwareInstallEvent.updateVerified()';
  }
}

/// @nodoc

class FirmwareInstallEvent_Installing extends FirmwareInstallEvent {
  const FirmwareInstallEvent_Installing() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareInstallEvent_Installing);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'FirmwareInstallEvent.installing()';
  }
}

/// @nodoc

class FirmwareInstallEvent_Rebooting extends FirmwareInstallEvent {
  const FirmwareInstallEvent_Rebooting() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareInstallEvent_Rebooting);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'FirmwareInstallEvent.rebooting()';
  }
}

/// @nodoc

class FirmwareInstallEvent_Success extends FirmwareInstallEvent {
  const FirmwareInstallEvent_Success({required this.installedVersion})
      : super._();

  final String installedVersion;

  /// Create a copy of FirmwareInstallEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FirmwareInstallEvent_SuccessCopyWith<FirmwareInstallEvent_Success>
      get copyWith => _$FirmwareInstallEvent_SuccessCopyWithImpl<
          FirmwareInstallEvent_Success>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareInstallEvent_Success &&
            (identical(other.installedVersion, installedVersion) ||
                other.installedVersion == installedVersion));
  }

  @override
  int get hashCode => Object.hash(runtimeType, installedVersion);

  @override
  String toString() {
    return 'FirmwareInstallEvent.success(installedVersion: $installedVersion)';
  }
}

/// @nodoc
abstract mixin class $FirmwareInstallEvent_SuccessCopyWith<$Res>
    implements $FirmwareInstallEventCopyWith<$Res> {
  factory $FirmwareInstallEvent_SuccessCopyWith(
          FirmwareInstallEvent_Success value,
          $Res Function(FirmwareInstallEvent_Success) _then) =
      _$FirmwareInstallEvent_SuccessCopyWithImpl;
  @useResult
  $Res call({String installedVersion});
}

/// @nodoc
class _$FirmwareInstallEvent_SuccessCopyWithImpl<$Res>
    implements $FirmwareInstallEvent_SuccessCopyWith<$Res> {
  _$FirmwareInstallEvent_SuccessCopyWithImpl(this._self, this._then);

  final FirmwareInstallEvent_Success _self;
  final $Res Function(FirmwareInstallEvent_Success) _then;

  /// Create a copy of FirmwareInstallEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? installedVersion = null,
  }) {
    return _then(FirmwareInstallEvent_Success(
      installedVersion: null == installedVersion
          ? _self.installedVersion
          : installedVersion // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class FirmwareInstallEvent_Error extends FirmwareInstallEvent {
  const FirmwareInstallEvent_Error({required this.error, required this.stage})
      : super._();

  final String error;
  final InstallErrorStage stage;

  /// Create a copy of FirmwareInstallEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FirmwareInstallEvent_ErrorCopyWith<FirmwareInstallEvent_Error>
      get copyWith =>
          _$FirmwareInstallEvent_ErrorCopyWithImpl<FirmwareInstallEvent_Error>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareInstallEvent_Error &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.stage, stage) || other.stage == stage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error, stage);

  @override
  String toString() {
    return 'FirmwareInstallEvent.error(error: $error, stage: $stage)';
  }
}

/// @nodoc
abstract mixin class $FirmwareInstallEvent_ErrorCopyWith<$Res>
    implements $FirmwareInstallEventCopyWith<$Res> {
  factory $FirmwareInstallEvent_ErrorCopyWith(FirmwareInstallEvent_Error value,
          $Res Function(FirmwareInstallEvent_Error) _then) =
      _$FirmwareInstallEvent_ErrorCopyWithImpl;
  @useResult
  $Res call({String error, InstallErrorStage stage});
}

/// @nodoc
class _$FirmwareInstallEvent_ErrorCopyWithImpl<$Res>
    implements $FirmwareInstallEvent_ErrorCopyWith<$Res> {
  _$FirmwareInstallEvent_ErrorCopyWithImpl(this._self, this._then);

  final FirmwareInstallEvent_Error _self;
  final $Res Function(FirmwareInstallEvent_Error) _then;

  /// Create a copy of FirmwareInstallEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
    Object? stage = null,
  }) {
    return _then(FirmwareInstallEvent_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
      stage: null == stage
          ? _self.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as InstallErrorStage,
    ));
  }
}

/// @nodoc
mixin _$FirmwareUpdateCheckResponse {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareUpdateCheckResponse);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'FirmwareUpdateCheckResponse()';
  }
}

/// @nodoc
class $FirmwareUpdateCheckResponseCopyWith<$Res> {
  $FirmwareUpdateCheckResponseCopyWith(FirmwareUpdateCheckResponse _,
      $Res Function(FirmwareUpdateCheckResponse) __);
}

/// Adds pattern-matching-related methods to [FirmwareUpdateCheckResponse].
extension FirmwareUpdateCheckResponsePatterns on FirmwareUpdateCheckResponse {
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
    TResult Function(FirmwareUpdateCheckResponse_Available value)? available,
    TResult Function(FirmwareUpdateCheckResponse_NotAvailable value)?
        notAvailable,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareUpdateCheckResponse_Available() when available != null:
        return available(_that);
      case FirmwareUpdateCheckResponse_NotAvailable() when notAvailable != null:
        return notAvailable(_that);
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
    required TResult Function(FirmwareUpdateCheckResponse_Available value)
        available,
    required TResult Function(FirmwareUpdateCheckResponse_NotAvailable value)
        notAvailable,
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareUpdateCheckResponse_Available():
        return available(_that);
      case FirmwareUpdateCheckResponse_NotAvailable():
        return notAvailable(_that);
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
    TResult? Function(FirmwareUpdateCheckResponse_Available value)? available,
    TResult? Function(FirmwareUpdateCheckResponse_NotAvailable value)?
        notAvailable,
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareUpdateCheckResponse_Available() when available != null:
        return available(_that);
      case FirmwareUpdateCheckResponse_NotAvailable() when notAvailable != null:
        return notAvailable(_that);
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
    TResult Function(FirmwareUpdateAvailable field0)? available,
    TResult Function()? notAvailable,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareUpdateCheckResponse_Available() when available != null:
        return available(_that.field0);
      case FirmwareUpdateCheckResponse_NotAvailable() when notAvailable != null:
        return notAvailable();
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
    required TResult Function(FirmwareUpdateAvailable field0) available,
    required TResult Function() notAvailable,
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareUpdateCheckResponse_Available():
        return available(_that.field0);
      case FirmwareUpdateCheckResponse_NotAvailable():
        return notAvailable();
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
    TResult? Function(FirmwareUpdateAvailable field0)? available,
    TResult? Function()? notAvailable,
  }) {
    final _that = this;
    switch (_that) {
      case FirmwareUpdateCheckResponse_Available() when available != null:
        return available(_that.field0);
      case FirmwareUpdateCheckResponse_NotAvailable() when notAvailable != null:
        return notAvailable();
      case _:
        return null;
    }
  }
}

/// @nodoc

class FirmwareUpdateCheckResponse_Available
    extends FirmwareUpdateCheckResponse {
  const FirmwareUpdateCheckResponse_Available(this.field0) : super._();

  final FirmwareUpdateAvailable field0;

  /// Create a copy of FirmwareUpdateCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FirmwareUpdateCheckResponse_AvailableCopyWith<
          FirmwareUpdateCheckResponse_Available>
      get copyWith => _$FirmwareUpdateCheckResponse_AvailableCopyWithImpl<
          FirmwareUpdateCheckResponse_Available>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareUpdateCheckResponse_Available &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'FirmwareUpdateCheckResponse.available(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $FirmwareUpdateCheckResponse_AvailableCopyWith<$Res>
    implements $FirmwareUpdateCheckResponseCopyWith<$Res> {
  factory $FirmwareUpdateCheckResponse_AvailableCopyWith(
          FirmwareUpdateCheckResponse_Available value,
          $Res Function(FirmwareUpdateCheckResponse_Available) _then) =
      _$FirmwareUpdateCheckResponse_AvailableCopyWithImpl;
  @useResult
  $Res call({FirmwareUpdateAvailable field0});
}

/// @nodoc
class _$FirmwareUpdateCheckResponse_AvailableCopyWithImpl<$Res>
    implements $FirmwareUpdateCheckResponse_AvailableCopyWith<$Res> {
  _$FirmwareUpdateCheckResponse_AvailableCopyWithImpl(this._self, this._then);

  final FirmwareUpdateCheckResponse_Available _self;
  final $Res Function(FirmwareUpdateCheckResponse_Available) _then;

  /// Create a copy of FirmwareUpdateCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(FirmwareUpdateCheckResponse_Available(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as FirmwareUpdateAvailable,
    ));
  }
}

/// @nodoc

class FirmwareUpdateCheckResponse_NotAvailable
    extends FirmwareUpdateCheckResponse {
  const FirmwareUpdateCheckResponse_NotAvailable() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FirmwareUpdateCheckResponse_NotAvailable);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'FirmwareUpdateCheckResponse.notAvailable()';
  }
}

// dart format on
