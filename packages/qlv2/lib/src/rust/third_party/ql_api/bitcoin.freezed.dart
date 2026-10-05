// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bitcoin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BroadcastTransactionResponse {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BroadcastTransactionResponse);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'BroadcastTransactionResponse()';
  }
}

/// @nodoc
class $BroadcastTransactionResponseCopyWith<$Res> {
  $BroadcastTransactionResponseCopyWith(BroadcastTransactionResponse _,
      $Res Function(BroadcastTransactionResponse) __);
}

/// Adds pattern-matching-related methods to [BroadcastTransactionResponse].
extension BroadcastTransactionResponsePatterns on BroadcastTransactionResponse {
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
    TResult Function(BroadcastTransactionResponse_Broadcast value)? broadcast,
    TResult Function(BroadcastTransactionResponse_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case BroadcastTransactionResponse_Broadcast() when broadcast != null:
        return broadcast(_that);
      case BroadcastTransactionResponse_Error() when error != null:
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
    required TResult Function(BroadcastTransactionResponse_Broadcast value)
        broadcast,
    required TResult Function(BroadcastTransactionResponse_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case BroadcastTransactionResponse_Broadcast():
        return broadcast(_that);
      case BroadcastTransactionResponse_Error():
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
    TResult? Function(BroadcastTransactionResponse_Broadcast value)? broadcast,
    TResult? Function(BroadcastTransactionResponse_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case BroadcastTransactionResponse_Broadcast() when broadcast != null:
        return broadcast(_that);
      case BroadcastTransactionResponse_Error() when error != null:
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
    TResult Function(String txid)? broadcast,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case BroadcastTransactionResponse_Broadcast() when broadcast != null:
        return broadcast(_that.txid);
      case BroadcastTransactionResponse_Error() when error != null:
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
    required TResult Function(String txid) broadcast,
    required TResult Function(String error) error,
  }) {
    final _that = this;
    switch (_that) {
      case BroadcastTransactionResponse_Broadcast():
        return broadcast(_that.txid);
      case BroadcastTransactionResponse_Error():
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
    TResult? Function(String txid)? broadcast,
    TResult? Function(String error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case BroadcastTransactionResponse_Broadcast() when broadcast != null:
        return broadcast(_that.txid);
      case BroadcastTransactionResponse_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class BroadcastTransactionResponse_Broadcast
    extends BroadcastTransactionResponse {
  const BroadcastTransactionResponse_Broadcast({required this.txid})
      : super._();

  final String txid;

  /// Create a copy of BroadcastTransactionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BroadcastTransactionResponse_BroadcastCopyWith<
          BroadcastTransactionResponse_Broadcast>
      get copyWith => _$BroadcastTransactionResponse_BroadcastCopyWithImpl<
          BroadcastTransactionResponse_Broadcast>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BroadcastTransactionResponse_Broadcast &&
            (identical(other.txid, txid) || other.txid == txid));
  }

  @override
  int get hashCode => Object.hash(runtimeType, txid);

  @override
  String toString() {
    return 'BroadcastTransactionResponse.broadcast(txid: $txid)';
  }
}

/// @nodoc
abstract mixin class $BroadcastTransactionResponse_BroadcastCopyWith<$Res>
    implements $BroadcastTransactionResponseCopyWith<$Res> {
  factory $BroadcastTransactionResponse_BroadcastCopyWith(
          BroadcastTransactionResponse_Broadcast value,
          $Res Function(BroadcastTransactionResponse_Broadcast) _then) =
      _$BroadcastTransactionResponse_BroadcastCopyWithImpl;
  @useResult
  $Res call({String txid});
}

/// @nodoc
class _$BroadcastTransactionResponse_BroadcastCopyWithImpl<$Res>
    implements $BroadcastTransactionResponse_BroadcastCopyWith<$Res> {
  _$BroadcastTransactionResponse_BroadcastCopyWithImpl(this._self, this._then);

  final BroadcastTransactionResponse_Broadcast _self;
  final $Res Function(BroadcastTransactionResponse_Broadcast) _then;

  /// Create a copy of BroadcastTransactionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? txid = null,
  }) {
    return _then(BroadcastTransactionResponse_Broadcast(
      txid: null == txid
          ? _self.txid
          : txid // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class BroadcastTransactionResponse_Error extends BroadcastTransactionResponse {
  const BroadcastTransactionResponse_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of BroadcastTransactionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BroadcastTransactionResponse_ErrorCopyWith<
          BroadcastTransactionResponse_Error>
      get copyWith => _$BroadcastTransactionResponse_ErrorCopyWithImpl<
          BroadcastTransactionResponse_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BroadcastTransactionResponse_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'BroadcastTransactionResponse.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $BroadcastTransactionResponse_ErrorCopyWith<$Res>
    implements $BroadcastTransactionResponseCopyWith<$Res> {
  factory $BroadcastTransactionResponse_ErrorCopyWith(
          BroadcastTransactionResponse_Error value,
          $Res Function(BroadcastTransactionResponse_Error) _then) =
      _$BroadcastTransactionResponse_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$BroadcastTransactionResponse_ErrorCopyWithImpl<$Res>
    implements $BroadcastTransactionResponse_ErrorCopyWith<$Res> {
  _$BroadcastTransactionResponse_ErrorCopyWithImpl(this._self, this._then);

  final BroadcastTransactionResponse_Error _self;
  final $Res Function(BroadcastTransactionResponse_Error) _then;

  /// Create a copy of BroadcastTransactionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(BroadcastTransactionResponse_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$SignPsbtResponse {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SignPsbtResponse);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SignPsbtResponse()';
  }
}

/// @nodoc
class $SignPsbtResponseCopyWith<$Res> {
  $SignPsbtResponseCopyWith(
      SignPsbtResponse _, $Res Function(SignPsbtResponse) __);
}

/// Adds pattern-matching-related methods to [SignPsbtResponse].
extension SignPsbtResponsePatterns on SignPsbtResponse {
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
    TResult Function(SignPsbtResponse_Signed value)? signed,
    TResult Function(SignPsbtResponse_Rejected value)? rejected,
    TResult Function(SignPsbtResponse_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SignPsbtResponse_Signed() when signed != null:
        return signed(_that);
      case SignPsbtResponse_Rejected() when rejected != null:
        return rejected(_that);
      case SignPsbtResponse_Error() when error != null:
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
    required TResult Function(SignPsbtResponse_Signed value) signed,
    required TResult Function(SignPsbtResponse_Rejected value) rejected,
    required TResult Function(SignPsbtResponse_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case SignPsbtResponse_Signed():
        return signed(_that);
      case SignPsbtResponse_Rejected():
        return rejected(_that);
      case SignPsbtResponse_Error():
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
    TResult? Function(SignPsbtResponse_Signed value)? signed,
    TResult? Function(SignPsbtResponse_Rejected value)? rejected,
    TResult? Function(SignPsbtResponse_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case SignPsbtResponse_Signed() when signed != null:
        return signed(_that);
      case SignPsbtResponse_Rejected() when rejected != null:
        return rejected(_that);
      case SignPsbtResponse_Error() when error != null:
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
    TResult Function(Uint8List psbt)? signed,
    TResult Function()? rejected,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SignPsbtResponse_Signed() when signed != null:
        return signed(_that.psbt);
      case SignPsbtResponse_Rejected() when rejected != null:
        return rejected();
      case SignPsbtResponse_Error() when error != null:
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
    required TResult Function(Uint8List psbt) signed,
    required TResult Function() rejected,
    required TResult Function(String error) error,
  }) {
    final _that = this;
    switch (_that) {
      case SignPsbtResponse_Signed():
        return signed(_that.psbt);
      case SignPsbtResponse_Rejected():
        return rejected();
      case SignPsbtResponse_Error():
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
    TResult? Function(Uint8List psbt)? signed,
    TResult? Function()? rejected,
    TResult? Function(String error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case SignPsbtResponse_Signed() when signed != null:
        return signed(_that.psbt);
      case SignPsbtResponse_Rejected() when rejected != null:
        return rejected();
      case SignPsbtResponse_Error() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class SignPsbtResponse_Signed extends SignPsbtResponse {
  const SignPsbtResponse_Signed({required this.psbt}) : super._();

  final Uint8List psbt;

  /// Create a copy of SignPsbtResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SignPsbtResponse_SignedCopyWith<SignPsbtResponse_Signed> get copyWith =>
      _$SignPsbtResponse_SignedCopyWithImpl<SignPsbtResponse_Signed>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SignPsbtResponse_Signed &&
            const DeepCollectionEquality().equals(other.psbt, psbt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(psbt));

  @override
  String toString() {
    return 'SignPsbtResponse.signed(psbt: $psbt)';
  }
}

/// @nodoc
abstract mixin class $SignPsbtResponse_SignedCopyWith<$Res>
    implements $SignPsbtResponseCopyWith<$Res> {
  factory $SignPsbtResponse_SignedCopyWith(SignPsbtResponse_Signed value,
          $Res Function(SignPsbtResponse_Signed) _then) =
      _$SignPsbtResponse_SignedCopyWithImpl;
  @useResult
  $Res call({Uint8List psbt});
}

/// @nodoc
class _$SignPsbtResponse_SignedCopyWithImpl<$Res>
    implements $SignPsbtResponse_SignedCopyWith<$Res> {
  _$SignPsbtResponse_SignedCopyWithImpl(this._self, this._then);

  final SignPsbtResponse_Signed _self;
  final $Res Function(SignPsbtResponse_Signed) _then;

  /// Create a copy of SignPsbtResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? psbt = null,
  }) {
    return _then(SignPsbtResponse_Signed(
      psbt: null == psbt
          ? _self.psbt
          : psbt // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ));
  }
}

/// @nodoc

class SignPsbtResponse_Rejected extends SignPsbtResponse {
  const SignPsbtResponse_Rejected() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SignPsbtResponse_Rejected);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SignPsbtResponse.rejected()';
  }
}

/// @nodoc

class SignPsbtResponse_Error extends SignPsbtResponse {
  const SignPsbtResponse_Error({required this.error}) : super._();

  final String error;

  /// Create a copy of SignPsbtResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SignPsbtResponse_ErrorCopyWith<SignPsbtResponse_Error> get copyWith =>
      _$SignPsbtResponse_ErrorCopyWithImpl<SignPsbtResponse_Error>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SignPsbtResponse_Error &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'SignPsbtResponse.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $SignPsbtResponse_ErrorCopyWith<$Res>
    implements $SignPsbtResponseCopyWith<$Res> {
  factory $SignPsbtResponse_ErrorCopyWith(SignPsbtResponse_Error value,
          $Res Function(SignPsbtResponse_Error) _then) =
      _$SignPsbtResponse_ErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$SignPsbtResponse_ErrorCopyWithImpl<$Res>
    implements $SignPsbtResponse_ErrorCopyWith<$Res> {
  _$SignPsbtResponse_ErrorCopyWithImpl(this._self, this._then);

  final SignPsbtResponse_Error _self;
  final $Res Function(SignPsbtResponse_Error) _then;

  /// Create a copy of SignPsbtResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(SignPsbtResponse_Error(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
