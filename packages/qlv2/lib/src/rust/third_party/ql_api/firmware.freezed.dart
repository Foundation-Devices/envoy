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
mixin _$DownloadFirmwareHeader {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is DownloadFirmwareHeader);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'DownloadFirmwareHeader()';
  }
}

/// @nodoc
class $DownloadFirmwareHeaderCopyWith<$Res> {
  $DownloadFirmwareHeaderCopyWith(
      DownloadFirmwareHeader _, $Res Function(DownloadFirmwareHeader) __);
}

/// Adds pattern-matching-related methods to [DownloadFirmwareHeader].
extension DownloadFirmwareHeaderPatterns on DownloadFirmwareHeader {
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
    TResult Function(DownloadFirmwareHeader_Available value)? available,
    TResult Function(DownloadFirmwareHeader_NotAvailable value)? notAvailable,
    TResult Function(DownloadFirmwareHeader_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case DownloadFirmwareHeader_Available() when available != null:
        return available(_that);
      case DownloadFirmwareHeader_NotAvailable() when notAvailable != null:
        return notAvailable(_that);
      case DownloadFirmwareHeader_Error() when error != null:
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
    required TResult Function(DownloadFirmwareHeader_Available value) available,
    required TResult Function(DownloadFirmwareHeader_NotAvailable value)
        notAvailable,
    required TResult Function(DownloadFirmwareHeader_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case DownloadFirmwareHeader_Available():
        return available(_that);
      case DownloadFirmwareHeader_NotAvailable():
        return notAvailable(_that);
      case DownloadFirmwareHeader_Error():
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
    TResult? Function(DownloadFirmwareHeader_Available value)? available,
    TResult? Function(DownloadFirmwareHeader_NotAvailable value)? notAvailable,
    TResult? Function(DownloadFirmwareHeader_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case DownloadFirmwareHeader_Available() when available != null:
        return available(_that);
      case DownloadFirmwareHeader_NotAvailable() when notAvailable != null:
        return notAvailable(_that);
      case DownloadFirmwareHeader_Error() when error != null:
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
    TResult Function(FirmwareUpdateAvailable field0)? available,
    TResult Function()? notAvailable,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case DownloadFirmwareHeader_Available() when available != null:
        return available(_that.field0);
      case DownloadFirmwareHeader_NotAvailable() when notAvailable != null:
        return notAvailable();
      case DownloadFirmwareHeader_Error() when error != null:
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
    required TResult Function(FirmwareUpdateAvailable field0) available,
    required TResult Function() notAvailable,
    required TResult Function(String error) error,
  }) {
    final _that = this;
    switch (_that) {
      case DownloadFirmwareHeader_Available():
        return available(_that.field0);
      case DownloadFirmwareHeader_NotAvailable():
        return notAvailable();
      case DownloadFirmwareHeader_Error():
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
    TResult? Function(FirmwareUpdateAvailable field0)? available,
    TResult? Function()? notAvailable,
    TResult? Function(String error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case DownloadFirmwareHeader_Available() when available != null:
        return available(_that.field0);
      case DownloadFirmwareHeader_NotAvailable() when notAvailable != null:
        return notAvailable();
      case DownloadFirmwareHeader_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class DownloadFirmwareHeader_Available extends DownloadFirmwareHeader {
  const DownloadFirmwareHeader_Available(this.field0) : super._();

  final FirmwareUpdateAvailable field0;

  /// Create a copy of DownloadFirmwareHeader
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadFirmwareHeader_AvailableCopyWith<DownloadFirmwareHeader_Available>
      get copyWith => _$DownloadFirmwareHeader_AvailableCopyWithImpl<
          DownloadFirmwareHeader_Available>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadFirmwareHeader_Available &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'DownloadFirmwareHeader.available(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $DownloadFirmwareHeader_AvailableCopyWith<$Res>
    implements $DownloadFirmwareHeaderCopyWith<$Res> {
  factory $DownloadFirmwareHeader_AvailableCopyWith(
          DownloadFirmwareHeader_Available value,
          $Res Function(DownloadFirmwareHeader_Available) _then) =
      _$DownloadFirmwareHeader_AvailableCopyWithImpl;
  @useResult
  $Res call({FirmwareUpdateAvailable field0});
}

/// @nodoc
class _$DownloadFirmwareHeader_AvailableCopyWithImpl<$Res>
    implements $DownloadFirmwareHeader_AvailableCopyWith<$Res> {
  _$DownloadFirmwareHeader_AvailableCopyWithImpl(this._self, this._then);

  final DownloadFirmwareHeader_Available _self;
  final $Res Function(DownloadFirmwareHeader_Available) _then;

  /// Create a copy of DownloadFirmwareHeader
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(DownloadFirmwareHeader_Available(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as FirmwareUpdateAvailable,
    ));
  }
}

/// @nodoc

class DownloadFirmwareHeader_NotAvailable extends DownloadFirmwareHeader {
  const DownloadFirmwareHeader_NotAvailable() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadFirmwareHeader_NotAvailable);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'DownloadFirmwareHeader.notAvailable()';
  }
}

/// @nodoc

class DownloadFirmwareHeader_Error extends DownloadFirmwareHeader {
  const DownloadFirmwareHeader_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of DownloadFirmwareHeader
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadFirmwareHeader_ErrorCopyWith<DownloadFirmwareHeader_Error>
      get copyWith => _$DownloadFirmwareHeader_ErrorCopyWithImpl<
          DownloadFirmwareHeader_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadFirmwareHeader_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'DownloadFirmwareHeader.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $DownloadFirmwareHeader_ErrorCopyWith<$Res>
    implements $DownloadFirmwareHeaderCopyWith<$Res> {
  factory $DownloadFirmwareHeader_ErrorCopyWith(
          DownloadFirmwareHeader_Error value,
          $Res Function(DownloadFirmwareHeader_Error) _then) =
      _$DownloadFirmwareHeader_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$DownloadFirmwareHeader_ErrorCopyWithImpl<$Res>
    implements $DownloadFirmwareHeader_ErrorCopyWith<$Res> {
  _$DownloadFirmwareHeader_ErrorCopyWithImpl(this._self, this._then);

  final DownloadFirmwareHeader_Error _self;
  final $Res Function(DownloadFirmwareHeader_Error) _then;

  /// Create a copy of DownloadFirmwareHeader
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(DownloadFirmwareHeader_Error(
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
    TResult Function(FirmwareInstallEvent_Installing value)? installing,
    TResult Function(FirmwareInstallEvent_Rebooting value)? rebooting,
    TResult Function(FirmwareInstallEvent_Success value)? success,
    TResult Function(FirmwareInstallEvent_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
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
    required TResult Function(FirmwareInstallEvent_Installing value) installing,
    required TResult Function(FirmwareInstallEvent_Rebooting value) rebooting,
    required TResult Function(FirmwareInstallEvent_Success value) success,
    required TResult Function(FirmwareInstallEvent_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
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
    TResult? Function(FirmwareInstallEvent_Installing value)? installing,
    TResult? Function(FirmwareInstallEvent_Rebooting value)? rebooting,
    TResult? Function(FirmwareInstallEvent_Success value)? success,
    TResult? Function(FirmwareInstallEvent_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
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
    TResult Function()? installing,
    TResult Function()? rebooting,
    TResult Function(String installedVersion)? success,
    TResult Function(String error, InstallErrorStage stage)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
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
    required TResult Function() installing,
    required TResult Function() rebooting,
    required TResult Function(String installedVersion) success,
    required TResult Function(String error, InstallErrorStage stage) error,
  }) {
    final _that = this;
    switch (_that) {
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
    TResult? Function()? installing,
    TResult? Function()? rebooting,
    TResult? Function(String installedVersion)? success,
    TResult? Function(String error, InstallErrorStage stage)? error,
  }) {
    final _that = this;
    switch (_that) {
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
