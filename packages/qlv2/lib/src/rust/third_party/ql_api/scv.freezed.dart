// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scv.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChallengeResponseResult {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ChallengeResponseResult);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ChallengeResponseResult()';
  }
}

/// @nodoc
class $ChallengeResponseResultCopyWith<$Res> {
  $ChallengeResponseResultCopyWith(
      ChallengeResponseResult _, $Res Function(ChallengeResponseResult) __);
}

/// Adds pattern-matching-related methods to [ChallengeResponseResult].
extension ChallengeResponseResultPatterns on ChallengeResponseResult {
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
    TResult Function(ChallengeResponseResult_Success value)? success,
    TResult Function(ChallengeResponseResult_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ChallengeResponseResult_Success() when success != null:
        return success(_that);
      case ChallengeResponseResult_Error() when error != null:
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
    required TResult Function(ChallengeResponseResult_Success value) success,
    required TResult Function(ChallengeResponseResult_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case ChallengeResponseResult_Success():
        return success(_that);
      case ChallengeResponseResult_Error():
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
    TResult? Function(ChallengeResponseResult_Success value)? success,
    TResult? Function(ChallengeResponseResult_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case ChallengeResponseResult_Success() when success != null:
        return success(_that);
      case ChallengeResponseResult_Error() when error != null:
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
    TResult Function(Uint8List data)? success,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ChallengeResponseResult_Success() when success != null:
        return success(_that.data);
      case ChallengeResponseResult_Error() when error != null:
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
    required TResult Function(Uint8List data) success,
    required TResult Function(String error) error,
  }) {
    final _that = this;
    switch (_that) {
      case ChallengeResponseResult_Success():
        return success(_that.data);
      case ChallengeResponseResult_Error():
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
    TResult? Function(Uint8List data)? success,
    TResult? Function(String error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case ChallengeResponseResult_Success() when success != null:
        return success(_that.data);
      case ChallengeResponseResult_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class ChallengeResponseResult_Success extends ChallengeResponseResult {
  const ChallengeResponseResult_Success({required this.data}) : super._();

  final Uint8List data;

  /// Create a copy of ChallengeResponseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChallengeResponseResult_SuccessCopyWith<ChallengeResponseResult_Success>
      get copyWith => _$ChallengeResponseResult_SuccessCopyWithImpl<
          ChallengeResponseResult_Success>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChallengeResponseResult_Success &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'ChallengeResponseResult.success(data: $data)';
  }
}

/// @nodoc
abstract mixin class $ChallengeResponseResult_SuccessCopyWith<$Res>
    implements $ChallengeResponseResultCopyWith<$Res> {
  factory $ChallengeResponseResult_SuccessCopyWith(
          ChallengeResponseResult_Success value,
          $Res Function(ChallengeResponseResult_Success) _then) =
      _$ChallengeResponseResult_SuccessCopyWithImpl;
  @useResult
  $Res call({Uint8List data});
}

/// @nodoc
class _$ChallengeResponseResult_SuccessCopyWithImpl<$Res>
    implements $ChallengeResponseResult_SuccessCopyWith<$Res> {
  _$ChallengeResponseResult_SuccessCopyWithImpl(this._self, this._then);

  final ChallengeResponseResult_Success _self;
  final $Res Function(ChallengeResponseResult_Success) _then;

  /// Create a copy of ChallengeResponseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
  }) {
    return _then(ChallengeResponseResult_Success(
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ));
  }
}

/// @nodoc

class ChallengeResponseResult_Error extends ChallengeResponseResult {
  const ChallengeResponseResult_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of ChallengeResponseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChallengeResponseResult_ErrorCopyWith<ChallengeResponseResult_Error>
      get copyWith => _$ChallengeResponseResult_ErrorCopyWithImpl<
          ChallengeResponseResult_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChallengeResponseResult_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'ChallengeResponseResult.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $ChallengeResponseResult_ErrorCopyWith<$Res>
    implements $ChallengeResponseResultCopyWith<$Res> {
  factory $ChallengeResponseResult_ErrorCopyWith(
          ChallengeResponseResult_Error value,
          $Res Function(ChallengeResponseResult_Error) _then) =
      _$ChallengeResponseResult_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$ChallengeResponseResult_ErrorCopyWithImpl<$Res>
    implements $ChallengeResponseResult_ErrorCopyWith<$Res> {
  _$ChallengeResponseResult_ErrorCopyWithImpl(this._self, this._then);

  final ChallengeResponseResult_Error _self;
  final $Res Function(ChallengeResponseResult_Error) _then;

  /// Create a copy of ChallengeResponseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(ChallengeResponseResult_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$RunSecurityCheckInitiatorEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RunSecurityCheckInitiatorEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RunSecurityCheckInitiatorEvent()';
  }
}

/// @nodoc
class $RunSecurityCheckInitiatorEventCopyWith<$Res> {
  $RunSecurityCheckInitiatorEventCopyWith(RunSecurityCheckInitiatorEvent _,
      $Res Function(RunSecurityCheckInitiatorEvent) __);
}

/// Adds pattern-matching-related methods to [RunSecurityCheckInitiatorEvent].
extension RunSecurityCheckInitiatorEventPatterns
    on RunSecurityCheckInitiatorEvent {
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
    TResult Function(RunSecurityCheckInitiatorEvent_Start value)? start,
    TResult Function(RunSecurityCheckInitiatorEvent_ChallengeResponse value)?
        challengeResponse,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RunSecurityCheckInitiatorEvent_Start() when start != null:
        return start(_that);
      case RunSecurityCheckInitiatorEvent_ChallengeResponse()
          when challengeResponse != null:
        return challengeResponse(_that);
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
    required TResult Function(RunSecurityCheckInitiatorEvent_Start value) start,
    required TResult Function(
            RunSecurityCheckInitiatorEvent_ChallengeResponse value)
        challengeResponse,
  }) {
    final _that = this;
    switch (_that) {
      case RunSecurityCheckInitiatorEvent_Start():
        return start(_that);
      case RunSecurityCheckInitiatorEvent_ChallengeResponse():
        return challengeResponse(_that);
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
    TResult? Function(RunSecurityCheckInitiatorEvent_Start value)? start,
    TResult? Function(RunSecurityCheckInitiatorEvent_ChallengeResponse value)?
        challengeResponse,
  }) {
    final _that = this;
    switch (_that) {
      case RunSecurityCheckInitiatorEvent_Start() when start != null:
        return start(_that);
      case RunSecurityCheckInitiatorEvent_ChallengeResponse()
          when challengeResponse != null:
        return challengeResponse(_that);
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
    TResult Function()? start,
    TResult Function(ChallengeResponseResult field0)? challengeResponse,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RunSecurityCheckInitiatorEvent_Start() when start != null:
        return start();
      case RunSecurityCheckInitiatorEvent_ChallengeResponse()
          when challengeResponse != null:
        return challengeResponse(_that.field0);
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
    required TResult Function() start,
    required TResult Function(ChallengeResponseResult field0) challengeResponse,
  }) {
    final _that = this;
    switch (_that) {
      case RunSecurityCheckInitiatorEvent_Start():
        return start();
      case RunSecurityCheckInitiatorEvent_ChallengeResponse():
        return challengeResponse(_that.field0);
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
    TResult? Function()? start,
    TResult? Function(ChallengeResponseResult field0)? challengeResponse,
  }) {
    final _that = this;
    switch (_that) {
      case RunSecurityCheckInitiatorEvent_Start() when start != null:
        return start();
      case RunSecurityCheckInitiatorEvent_ChallengeResponse()
          when challengeResponse != null:
        return challengeResponse(_that.field0);
      case _:
        return null;
    }
  }
}

/// @nodoc

class RunSecurityCheckInitiatorEvent_Start
    extends RunSecurityCheckInitiatorEvent {
  const RunSecurityCheckInitiatorEvent_Start() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RunSecurityCheckInitiatorEvent_Start);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RunSecurityCheckInitiatorEvent.start()';
  }
}

/// @nodoc

class RunSecurityCheckInitiatorEvent_ChallengeResponse
    extends RunSecurityCheckInitiatorEvent {
  const RunSecurityCheckInitiatorEvent_ChallengeResponse(this.field0)
      : super._();

  final ChallengeResponseResult field0;

  /// Create a copy of RunSecurityCheckInitiatorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RunSecurityCheckInitiatorEvent_ChallengeResponseCopyWith<
          RunSecurityCheckInitiatorEvent_ChallengeResponse>
      get copyWith =>
          _$RunSecurityCheckInitiatorEvent_ChallengeResponseCopyWithImpl<
                  RunSecurityCheckInitiatorEvent_ChallengeResponse>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RunSecurityCheckInitiatorEvent_ChallengeResponse &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'RunSecurityCheckInitiatorEvent.challengeResponse(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $RunSecurityCheckInitiatorEvent_ChallengeResponseCopyWith<
    $Res> implements $RunSecurityCheckInitiatorEventCopyWith<$Res> {
  factory $RunSecurityCheckInitiatorEvent_ChallengeResponseCopyWith(
          RunSecurityCheckInitiatorEvent_ChallengeResponse value,
          $Res Function(RunSecurityCheckInitiatorEvent_ChallengeResponse)
              _then) =
      _$RunSecurityCheckInitiatorEvent_ChallengeResponseCopyWithImpl;
  @useResult
  $Res call({ChallengeResponseResult field0});

  $ChallengeResponseResultCopyWith<$Res> get field0;
}

/// @nodoc
class _$RunSecurityCheckInitiatorEvent_ChallengeResponseCopyWithImpl<$Res>
    implements $RunSecurityCheckInitiatorEvent_ChallengeResponseCopyWith<$Res> {
  _$RunSecurityCheckInitiatorEvent_ChallengeResponseCopyWithImpl(
      this._self, this._then);

  final RunSecurityCheckInitiatorEvent_ChallengeResponse _self;
  final $Res Function(RunSecurityCheckInitiatorEvent_ChallengeResponse) _then;

  /// Create a copy of RunSecurityCheckInitiatorEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(RunSecurityCheckInitiatorEvent_ChallengeResponse(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ChallengeResponseResult,
    ));
  }

  /// Create a copy of RunSecurityCheckInitiatorEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeResponseResultCopyWith<$Res> get field0 {
    return $ChallengeResponseResultCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc
mixin _$RunSecurityCheckResponderEvent {
  Object get field0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RunSecurityCheckResponderEvent &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @override
  String toString() {
    return 'RunSecurityCheckResponderEvent(field0: $field0)';
  }
}

/// @nodoc
class $RunSecurityCheckResponderEventCopyWith<$Res> {
  $RunSecurityCheckResponderEventCopyWith(RunSecurityCheckResponderEvent _,
      $Res Function(RunSecurityCheckResponderEvent) __);
}

/// Adds pattern-matching-related methods to [RunSecurityCheckResponderEvent].
extension RunSecurityCheckResponderEventPatterns
    on RunSecurityCheckResponderEvent {
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
    TResult Function(RunSecurityCheckResponderEvent_ChallengeRequest value)?
        challengeRequest,
    TResult Function(RunSecurityCheckResponderEvent_VerificationResult value)?
        verificationResult,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RunSecurityCheckResponderEvent_ChallengeRequest()
          when challengeRequest != null:
        return challengeRequest(_that);
      case RunSecurityCheckResponderEvent_VerificationResult()
          when verificationResult != null:
        return verificationResult(_that);
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
    required TResult Function(
            RunSecurityCheckResponderEvent_ChallengeRequest value)
        challengeRequest,
    required TResult Function(
            RunSecurityCheckResponderEvent_VerificationResult value)
        verificationResult,
  }) {
    final _that = this;
    switch (_that) {
      case RunSecurityCheckResponderEvent_ChallengeRequest():
        return challengeRequest(_that);
      case RunSecurityCheckResponderEvent_VerificationResult():
        return verificationResult(_that);
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
    TResult? Function(RunSecurityCheckResponderEvent_ChallengeRequest value)?
        challengeRequest,
    TResult? Function(RunSecurityCheckResponderEvent_VerificationResult value)?
        verificationResult,
  }) {
    final _that = this;
    switch (_that) {
      case RunSecurityCheckResponderEvent_ChallengeRequest()
          when challengeRequest != null:
        return challengeRequest(_that);
      case RunSecurityCheckResponderEvent_VerificationResult()
          when verificationResult != null:
        return verificationResult(_that);
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
    TResult Function(ChallengeRequest field0)? challengeRequest,
    TResult Function(VerificationResult field0)? verificationResult,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RunSecurityCheckResponderEvent_ChallengeRequest()
          when challengeRequest != null:
        return challengeRequest(_that.field0);
      case RunSecurityCheckResponderEvent_VerificationResult()
          when verificationResult != null:
        return verificationResult(_that.field0);
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
    required TResult Function(ChallengeRequest field0) challengeRequest,
    required TResult Function(VerificationResult field0) verificationResult,
  }) {
    final _that = this;
    switch (_that) {
      case RunSecurityCheckResponderEvent_ChallengeRequest():
        return challengeRequest(_that.field0);
      case RunSecurityCheckResponderEvent_VerificationResult():
        return verificationResult(_that.field0);
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
    TResult? Function(ChallengeRequest field0)? challengeRequest,
    TResult? Function(VerificationResult field0)? verificationResult,
  }) {
    final _that = this;
    switch (_that) {
      case RunSecurityCheckResponderEvent_ChallengeRequest()
          when challengeRequest != null:
        return challengeRequest(_that.field0);
      case RunSecurityCheckResponderEvent_VerificationResult()
          when verificationResult != null:
        return verificationResult(_that.field0);
      case _:
        return null;
    }
  }
}

/// @nodoc

class RunSecurityCheckResponderEvent_ChallengeRequest
    extends RunSecurityCheckResponderEvent {
  const RunSecurityCheckResponderEvent_ChallengeRequest(this.field0)
      : super._();

  @override
  final ChallengeRequest field0;

  /// Create a copy of RunSecurityCheckResponderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RunSecurityCheckResponderEvent_ChallengeRequestCopyWith<
          RunSecurityCheckResponderEvent_ChallengeRequest>
      get copyWith =>
          _$RunSecurityCheckResponderEvent_ChallengeRequestCopyWithImpl<
                  RunSecurityCheckResponderEvent_ChallengeRequest>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RunSecurityCheckResponderEvent_ChallengeRequest &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'RunSecurityCheckResponderEvent.challengeRequest(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $RunSecurityCheckResponderEvent_ChallengeRequestCopyWith<
    $Res> implements $RunSecurityCheckResponderEventCopyWith<$Res> {
  factory $RunSecurityCheckResponderEvent_ChallengeRequestCopyWith(
          RunSecurityCheckResponderEvent_ChallengeRequest value,
          $Res Function(RunSecurityCheckResponderEvent_ChallengeRequest)
              _then) =
      _$RunSecurityCheckResponderEvent_ChallengeRequestCopyWithImpl;
  @useResult
  $Res call({ChallengeRequest field0});
}

/// @nodoc
class _$RunSecurityCheckResponderEvent_ChallengeRequestCopyWithImpl<$Res>
    implements $RunSecurityCheckResponderEvent_ChallengeRequestCopyWith<$Res> {
  _$RunSecurityCheckResponderEvent_ChallengeRequestCopyWithImpl(
      this._self, this._then);

  final RunSecurityCheckResponderEvent_ChallengeRequest _self;
  final $Res Function(RunSecurityCheckResponderEvent_ChallengeRequest) _then;

  /// Create a copy of RunSecurityCheckResponderEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(RunSecurityCheckResponderEvent_ChallengeRequest(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ChallengeRequest,
    ));
  }
}

/// @nodoc

class RunSecurityCheckResponderEvent_VerificationResult
    extends RunSecurityCheckResponderEvent {
  const RunSecurityCheckResponderEvent_VerificationResult(this.field0)
      : super._();

  @override
  final VerificationResult field0;

  /// Create a copy of RunSecurityCheckResponderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RunSecurityCheckResponderEvent_VerificationResultCopyWith<
          RunSecurityCheckResponderEvent_VerificationResult>
      get copyWith =>
          _$RunSecurityCheckResponderEvent_VerificationResultCopyWithImpl<
                  RunSecurityCheckResponderEvent_VerificationResult>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RunSecurityCheckResponderEvent_VerificationResult &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'RunSecurityCheckResponderEvent.verificationResult(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $RunSecurityCheckResponderEvent_VerificationResultCopyWith<
    $Res> implements $RunSecurityCheckResponderEventCopyWith<$Res> {
  factory $RunSecurityCheckResponderEvent_VerificationResultCopyWith(
          RunSecurityCheckResponderEvent_VerificationResult value,
          $Res Function(RunSecurityCheckResponderEvent_VerificationResult)
              _then) =
      _$RunSecurityCheckResponderEvent_VerificationResultCopyWithImpl;
  @useResult
  $Res call({VerificationResult field0});

  $VerificationResultCopyWith<$Res> get field0;
}

/// @nodoc
class _$RunSecurityCheckResponderEvent_VerificationResultCopyWithImpl<$Res>
    implements
        $RunSecurityCheckResponderEvent_VerificationResultCopyWith<$Res> {
  _$RunSecurityCheckResponderEvent_VerificationResultCopyWithImpl(
      this._self, this._then);

  final RunSecurityCheckResponderEvent_VerificationResult _self;
  final $Res Function(RunSecurityCheckResponderEvent_VerificationResult) _then;

  /// Create a copy of RunSecurityCheckResponderEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(RunSecurityCheckResponderEvent_VerificationResult(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as VerificationResult,
    ));
  }

  /// Create a copy of RunSecurityCheckResponderEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VerificationResultCopyWith<$Res> get field0 {
    return $VerificationResultCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc
mixin _$VerificationResult {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is VerificationResult);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VerificationResult()';
  }
}

/// @nodoc
class $VerificationResultCopyWith<$Res> {
  $VerificationResultCopyWith(
      VerificationResult _, $Res Function(VerificationResult) __);
}

/// Adds pattern-matching-related methods to [VerificationResult].
extension VerificationResultPatterns on VerificationResult {
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
    TResult Function(VerificationResult_Success value)? success,
    TResult Function(VerificationResult_Error value)? error,
    TResult Function(VerificationResult_Failure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case VerificationResult_Success() when success != null:
        return success(_that);
      case VerificationResult_Error() when error != null:
        return error(_that);
      case VerificationResult_Failure() when failure != null:
        return failure(_that);
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
    required TResult Function(VerificationResult_Success value) success,
    required TResult Function(VerificationResult_Error value) error,
    required TResult Function(VerificationResult_Failure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case VerificationResult_Success():
        return success(_that);
      case VerificationResult_Error():
        return error(_that);
      case VerificationResult_Failure():
        return failure(_that);
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
    TResult? Function(VerificationResult_Success value)? success,
    TResult? Function(VerificationResult_Error value)? error,
    TResult? Function(VerificationResult_Failure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case VerificationResult_Success() when success != null:
        return success(_that);
      case VerificationResult_Error() when error != null:
        return error(_that);
      case VerificationResult_Failure() when failure != null:
        return failure(_that);
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
    TResult Function()? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case VerificationResult_Success() when success != null:
        return success();
      case VerificationResult_Error() when error != null:
        return error(_that.error);
      case VerificationResult_Failure() when failure != null:
        return failure();
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
    required TResult Function() failure,
  }) {
    final _that = this;
    switch (_that) {
      case VerificationResult_Success():
        return success();
      case VerificationResult_Error():
        return error(_that.error);
      case VerificationResult_Failure():
        return failure();
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
    TResult? Function()? failure,
  }) {
    final _that = this;
    switch (_that) {
      case VerificationResult_Success() when success != null:
        return success();
      case VerificationResult_Error() when error != null:
        return error(_that.error);
      case VerificationResult_Failure() when failure != null:
        return failure();
      case _:
        return null;
    }
  }
}

/// @nodoc

class VerificationResult_Success extends VerificationResult {
  const VerificationResult_Success() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VerificationResult_Success);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VerificationResult.success()';
  }
}

/// @nodoc

class VerificationResult_Error extends VerificationResult {
  const VerificationResult_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VerificationResult_ErrorCopyWith<VerificationResult_Error> get copyWith =>
      _$VerificationResult_ErrorCopyWithImpl<VerificationResult_Error>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VerificationResult_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'VerificationResult.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $VerificationResult_ErrorCopyWith<$Res>
    implements $VerificationResultCopyWith<$Res> {
  factory $VerificationResult_ErrorCopyWith(VerificationResult_Error value,
          $Res Function(VerificationResult_Error) _then) =
      _$VerificationResult_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$VerificationResult_ErrorCopyWithImpl<$Res>
    implements $VerificationResult_ErrorCopyWith<$Res> {
  _$VerificationResult_ErrorCopyWithImpl(this._self, this._then);

  final VerificationResult_Error _self;
  final $Res Function(VerificationResult_Error) _then;

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(VerificationResult_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class VerificationResult_Failure extends VerificationResult {
  const VerificationResult_Failure() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VerificationResult_Failure);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VerificationResult.failure()';
  }
}

// dart format on
