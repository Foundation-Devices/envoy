// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'errors.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ComposeTxError {
  Object get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) coinSelectionError,
    required TResult Function(String field0) error,
    required TResult Function(String field0) insufficientFunds,
    required TResult Function(BigInt field0) insufficientFees,
    required TResult Function(BigInt field0) insufficientFeeRate,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? coinSelectionError,
    TResult? Function(String field0)? error,
    TResult? Function(String field0)? insufficientFunds,
    TResult? Function(BigInt field0)? insufficientFees,
    TResult? Function(BigInt field0)? insufficientFeeRate,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? coinSelectionError,
    TResult Function(String field0)? error,
    TResult Function(String field0)? insufficientFunds,
    TResult Function(BigInt field0)? insufficientFees,
    TResult Function(BigInt field0)? insufficientFeeRate,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ComposeTxError_CoinSelectionError value)
        coinSelectionError,
    required TResult Function(ComposeTxError_Error value) error,
    required TResult Function(ComposeTxError_InsufficientFunds value)
        insufficientFunds,
    required TResult Function(ComposeTxError_InsufficientFees value)
        insufficientFees,
    required TResult Function(ComposeTxError_InsufficientFeeRate value)
        insufficientFeeRate,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ComposeTxError_CoinSelectionError value)?
        coinSelectionError,
    TResult? Function(ComposeTxError_Error value)? error,
    TResult? Function(ComposeTxError_InsufficientFunds value)?
        insufficientFunds,
    TResult? Function(ComposeTxError_InsufficientFees value)? insufficientFees,
    TResult? Function(ComposeTxError_InsufficientFeeRate value)?
        insufficientFeeRate,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ComposeTxError_CoinSelectionError value)?
        coinSelectionError,
    TResult Function(ComposeTxError_Error value)? error,
    TResult Function(ComposeTxError_InsufficientFunds value)? insufficientFunds,
    TResult Function(ComposeTxError_InsufficientFees value)? insufficientFees,
    TResult Function(ComposeTxError_InsufficientFeeRate value)?
        insufficientFeeRate,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComposeTxErrorCopyWith<$Res> {
  factory $ComposeTxErrorCopyWith(
          ComposeTxError value, $Res Function(ComposeTxError) then) =
      _$ComposeTxErrorCopyWithImpl<$Res, ComposeTxError>;
}

/// @nodoc
class _$ComposeTxErrorCopyWithImpl<$Res, $Val extends ComposeTxError>
    implements $ComposeTxErrorCopyWith<$Res> {
  _$ComposeTxErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ComposeTxError_CoinSelectionErrorImplCopyWith<$Res> {
  factory _$$ComposeTxError_CoinSelectionErrorImplCopyWith(
          _$ComposeTxError_CoinSelectionErrorImpl value,
          $Res Function(_$ComposeTxError_CoinSelectionErrorImpl) then) =
      __$$ComposeTxError_CoinSelectionErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$ComposeTxError_CoinSelectionErrorImplCopyWithImpl<$Res>
    extends _$ComposeTxErrorCopyWithImpl<$Res,
        _$ComposeTxError_CoinSelectionErrorImpl>
    implements _$$ComposeTxError_CoinSelectionErrorImplCopyWith<$Res> {
  __$$ComposeTxError_CoinSelectionErrorImplCopyWithImpl(
      _$ComposeTxError_CoinSelectionErrorImpl _value,
      $Res Function(_$ComposeTxError_CoinSelectionErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$ComposeTxError_CoinSelectionErrorImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ComposeTxError_CoinSelectionErrorImpl
    extends ComposeTxError_CoinSelectionError {
  const _$ComposeTxError_CoinSelectionErrorImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'ComposeTxError.coinSelectionError(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeTxError_CoinSelectionErrorImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeTxError_CoinSelectionErrorImplCopyWith<
          _$ComposeTxError_CoinSelectionErrorImpl>
      get copyWith => __$$ComposeTxError_CoinSelectionErrorImplCopyWithImpl<
          _$ComposeTxError_CoinSelectionErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) coinSelectionError,
    required TResult Function(String field0) error,
    required TResult Function(String field0) insufficientFunds,
    required TResult Function(BigInt field0) insufficientFees,
    required TResult Function(BigInt field0) insufficientFeeRate,
  }) {
    return coinSelectionError(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? coinSelectionError,
    TResult? Function(String field0)? error,
    TResult? Function(String field0)? insufficientFunds,
    TResult? Function(BigInt field0)? insufficientFees,
    TResult? Function(BigInt field0)? insufficientFeeRate,
  }) {
    return coinSelectionError?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? coinSelectionError,
    TResult Function(String field0)? error,
    TResult Function(String field0)? insufficientFunds,
    TResult Function(BigInt field0)? insufficientFees,
    TResult Function(BigInt field0)? insufficientFeeRate,
    required TResult orElse(),
  }) {
    if (coinSelectionError != null) {
      return coinSelectionError(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ComposeTxError_CoinSelectionError value)
        coinSelectionError,
    required TResult Function(ComposeTxError_Error value) error,
    required TResult Function(ComposeTxError_InsufficientFunds value)
        insufficientFunds,
    required TResult Function(ComposeTxError_InsufficientFees value)
        insufficientFees,
    required TResult Function(ComposeTxError_InsufficientFeeRate value)
        insufficientFeeRate,
  }) {
    return coinSelectionError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ComposeTxError_CoinSelectionError value)?
        coinSelectionError,
    TResult? Function(ComposeTxError_Error value)? error,
    TResult? Function(ComposeTxError_InsufficientFunds value)?
        insufficientFunds,
    TResult? Function(ComposeTxError_InsufficientFees value)? insufficientFees,
    TResult? Function(ComposeTxError_InsufficientFeeRate value)?
        insufficientFeeRate,
  }) {
    return coinSelectionError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ComposeTxError_CoinSelectionError value)?
        coinSelectionError,
    TResult Function(ComposeTxError_Error value)? error,
    TResult Function(ComposeTxError_InsufficientFunds value)? insufficientFunds,
    TResult Function(ComposeTxError_InsufficientFees value)? insufficientFees,
    TResult Function(ComposeTxError_InsufficientFeeRate value)?
        insufficientFeeRate,
    required TResult orElse(),
  }) {
    if (coinSelectionError != null) {
      return coinSelectionError(this);
    }
    return orElse();
  }
}

abstract class ComposeTxError_CoinSelectionError extends ComposeTxError {
  const factory ComposeTxError_CoinSelectionError(final String field0) =
      _$ComposeTxError_CoinSelectionErrorImpl;
  const ComposeTxError_CoinSelectionError._() : super._();

  @override
  String get field0;

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComposeTxError_CoinSelectionErrorImplCopyWith<
          _$ComposeTxError_CoinSelectionErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ComposeTxError_ErrorImplCopyWith<$Res> {
  factory _$$ComposeTxError_ErrorImplCopyWith(_$ComposeTxError_ErrorImpl value,
          $Res Function(_$ComposeTxError_ErrorImpl) then) =
      __$$ComposeTxError_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$ComposeTxError_ErrorImplCopyWithImpl<$Res>
    extends _$ComposeTxErrorCopyWithImpl<$Res, _$ComposeTxError_ErrorImpl>
    implements _$$ComposeTxError_ErrorImplCopyWith<$Res> {
  __$$ComposeTxError_ErrorImplCopyWithImpl(_$ComposeTxError_ErrorImpl _value,
      $Res Function(_$ComposeTxError_ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$ComposeTxError_ErrorImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ComposeTxError_ErrorImpl extends ComposeTxError_Error {
  const _$ComposeTxError_ErrorImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'ComposeTxError.error(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeTxError_ErrorImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeTxError_ErrorImplCopyWith<_$ComposeTxError_ErrorImpl>
      get copyWith =>
          __$$ComposeTxError_ErrorImplCopyWithImpl<_$ComposeTxError_ErrorImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) coinSelectionError,
    required TResult Function(String field0) error,
    required TResult Function(String field0) insufficientFunds,
    required TResult Function(BigInt field0) insufficientFees,
    required TResult Function(BigInt field0) insufficientFeeRate,
  }) {
    return error(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? coinSelectionError,
    TResult? Function(String field0)? error,
    TResult? Function(String field0)? insufficientFunds,
    TResult? Function(BigInt field0)? insufficientFees,
    TResult? Function(BigInt field0)? insufficientFeeRate,
  }) {
    return error?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? coinSelectionError,
    TResult Function(String field0)? error,
    TResult Function(String field0)? insufficientFunds,
    TResult Function(BigInt field0)? insufficientFees,
    TResult Function(BigInt field0)? insufficientFeeRate,
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
    required TResult Function(ComposeTxError_CoinSelectionError value)
        coinSelectionError,
    required TResult Function(ComposeTxError_Error value) error,
    required TResult Function(ComposeTxError_InsufficientFunds value)
        insufficientFunds,
    required TResult Function(ComposeTxError_InsufficientFees value)
        insufficientFees,
    required TResult Function(ComposeTxError_InsufficientFeeRate value)
        insufficientFeeRate,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ComposeTxError_CoinSelectionError value)?
        coinSelectionError,
    TResult? Function(ComposeTxError_Error value)? error,
    TResult? Function(ComposeTxError_InsufficientFunds value)?
        insufficientFunds,
    TResult? Function(ComposeTxError_InsufficientFees value)? insufficientFees,
    TResult? Function(ComposeTxError_InsufficientFeeRate value)?
        insufficientFeeRate,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ComposeTxError_CoinSelectionError value)?
        coinSelectionError,
    TResult Function(ComposeTxError_Error value)? error,
    TResult Function(ComposeTxError_InsufficientFunds value)? insufficientFunds,
    TResult Function(ComposeTxError_InsufficientFees value)? insufficientFees,
    TResult Function(ComposeTxError_InsufficientFeeRate value)?
        insufficientFeeRate,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ComposeTxError_Error extends ComposeTxError {
  const factory ComposeTxError_Error(final String field0) =
      _$ComposeTxError_ErrorImpl;
  const ComposeTxError_Error._() : super._();

  @override
  String get field0;

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComposeTxError_ErrorImplCopyWith<_$ComposeTxError_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ComposeTxError_InsufficientFundsImplCopyWith<$Res> {
  factory _$$ComposeTxError_InsufficientFundsImplCopyWith(
          _$ComposeTxError_InsufficientFundsImpl value,
          $Res Function(_$ComposeTxError_InsufficientFundsImpl) then) =
      __$$ComposeTxError_InsufficientFundsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$ComposeTxError_InsufficientFundsImplCopyWithImpl<$Res>
    extends _$ComposeTxErrorCopyWithImpl<$Res,
        _$ComposeTxError_InsufficientFundsImpl>
    implements _$$ComposeTxError_InsufficientFundsImplCopyWith<$Res> {
  __$$ComposeTxError_InsufficientFundsImplCopyWithImpl(
      _$ComposeTxError_InsufficientFundsImpl _value,
      $Res Function(_$ComposeTxError_InsufficientFundsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$ComposeTxError_InsufficientFundsImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ComposeTxError_InsufficientFundsImpl
    extends ComposeTxError_InsufficientFunds {
  const _$ComposeTxError_InsufficientFundsImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'ComposeTxError.insufficientFunds(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeTxError_InsufficientFundsImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeTxError_InsufficientFundsImplCopyWith<
          _$ComposeTxError_InsufficientFundsImpl>
      get copyWith => __$$ComposeTxError_InsufficientFundsImplCopyWithImpl<
          _$ComposeTxError_InsufficientFundsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) coinSelectionError,
    required TResult Function(String field0) error,
    required TResult Function(String field0) insufficientFunds,
    required TResult Function(BigInt field0) insufficientFees,
    required TResult Function(BigInt field0) insufficientFeeRate,
  }) {
    return insufficientFunds(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? coinSelectionError,
    TResult? Function(String field0)? error,
    TResult? Function(String field0)? insufficientFunds,
    TResult? Function(BigInt field0)? insufficientFees,
    TResult? Function(BigInt field0)? insufficientFeeRate,
  }) {
    return insufficientFunds?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? coinSelectionError,
    TResult Function(String field0)? error,
    TResult Function(String field0)? insufficientFunds,
    TResult Function(BigInt field0)? insufficientFees,
    TResult Function(BigInt field0)? insufficientFeeRate,
    required TResult orElse(),
  }) {
    if (insufficientFunds != null) {
      return insufficientFunds(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ComposeTxError_CoinSelectionError value)
        coinSelectionError,
    required TResult Function(ComposeTxError_Error value) error,
    required TResult Function(ComposeTxError_InsufficientFunds value)
        insufficientFunds,
    required TResult Function(ComposeTxError_InsufficientFees value)
        insufficientFees,
    required TResult Function(ComposeTxError_InsufficientFeeRate value)
        insufficientFeeRate,
  }) {
    return insufficientFunds(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ComposeTxError_CoinSelectionError value)?
        coinSelectionError,
    TResult? Function(ComposeTxError_Error value)? error,
    TResult? Function(ComposeTxError_InsufficientFunds value)?
        insufficientFunds,
    TResult? Function(ComposeTxError_InsufficientFees value)? insufficientFees,
    TResult? Function(ComposeTxError_InsufficientFeeRate value)?
        insufficientFeeRate,
  }) {
    return insufficientFunds?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ComposeTxError_CoinSelectionError value)?
        coinSelectionError,
    TResult Function(ComposeTxError_Error value)? error,
    TResult Function(ComposeTxError_InsufficientFunds value)? insufficientFunds,
    TResult Function(ComposeTxError_InsufficientFees value)? insufficientFees,
    TResult Function(ComposeTxError_InsufficientFeeRate value)?
        insufficientFeeRate,
    required TResult orElse(),
  }) {
    if (insufficientFunds != null) {
      return insufficientFunds(this);
    }
    return orElse();
  }
}

abstract class ComposeTxError_InsufficientFunds extends ComposeTxError {
  const factory ComposeTxError_InsufficientFunds(final String field0) =
      _$ComposeTxError_InsufficientFundsImpl;
  const ComposeTxError_InsufficientFunds._() : super._();

  @override
  String get field0;

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComposeTxError_InsufficientFundsImplCopyWith<
          _$ComposeTxError_InsufficientFundsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ComposeTxError_InsufficientFeesImplCopyWith<$Res> {
  factory _$$ComposeTxError_InsufficientFeesImplCopyWith(
          _$ComposeTxError_InsufficientFeesImpl value,
          $Res Function(_$ComposeTxError_InsufficientFeesImpl) then) =
      __$$ComposeTxError_InsufficientFeesImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt field0});
}

/// @nodoc
class __$$ComposeTxError_InsufficientFeesImplCopyWithImpl<$Res>
    extends _$ComposeTxErrorCopyWithImpl<$Res,
        _$ComposeTxError_InsufficientFeesImpl>
    implements _$$ComposeTxError_InsufficientFeesImplCopyWith<$Res> {
  __$$ComposeTxError_InsufficientFeesImplCopyWithImpl(
      _$ComposeTxError_InsufficientFeesImpl _value,
      $Res Function(_$ComposeTxError_InsufficientFeesImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$ComposeTxError_InsufficientFeesImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BigInt,
    ));
  }
}

/// @nodoc

class _$ComposeTxError_InsufficientFeesImpl
    extends ComposeTxError_InsufficientFees {
  const _$ComposeTxError_InsufficientFeesImpl(this.field0) : super._();

  @override
  final BigInt field0;

  @override
  String toString() {
    return 'ComposeTxError.insufficientFees(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeTxError_InsufficientFeesImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeTxError_InsufficientFeesImplCopyWith<
          _$ComposeTxError_InsufficientFeesImpl>
      get copyWith => __$$ComposeTxError_InsufficientFeesImplCopyWithImpl<
          _$ComposeTxError_InsufficientFeesImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) coinSelectionError,
    required TResult Function(String field0) error,
    required TResult Function(String field0) insufficientFunds,
    required TResult Function(BigInt field0) insufficientFees,
    required TResult Function(BigInt field0) insufficientFeeRate,
  }) {
    return insufficientFees(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? coinSelectionError,
    TResult? Function(String field0)? error,
    TResult? Function(String field0)? insufficientFunds,
    TResult? Function(BigInt field0)? insufficientFees,
    TResult? Function(BigInt field0)? insufficientFeeRate,
  }) {
    return insufficientFees?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? coinSelectionError,
    TResult Function(String field0)? error,
    TResult Function(String field0)? insufficientFunds,
    TResult Function(BigInt field0)? insufficientFees,
    TResult Function(BigInt field0)? insufficientFeeRate,
    required TResult orElse(),
  }) {
    if (insufficientFees != null) {
      return insufficientFees(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ComposeTxError_CoinSelectionError value)
        coinSelectionError,
    required TResult Function(ComposeTxError_Error value) error,
    required TResult Function(ComposeTxError_InsufficientFunds value)
        insufficientFunds,
    required TResult Function(ComposeTxError_InsufficientFees value)
        insufficientFees,
    required TResult Function(ComposeTxError_InsufficientFeeRate value)
        insufficientFeeRate,
  }) {
    return insufficientFees(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ComposeTxError_CoinSelectionError value)?
        coinSelectionError,
    TResult? Function(ComposeTxError_Error value)? error,
    TResult? Function(ComposeTxError_InsufficientFunds value)?
        insufficientFunds,
    TResult? Function(ComposeTxError_InsufficientFees value)? insufficientFees,
    TResult? Function(ComposeTxError_InsufficientFeeRate value)?
        insufficientFeeRate,
  }) {
    return insufficientFees?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ComposeTxError_CoinSelectionError value)?
        coinSelectionError,
    TResult Function(ComposeTxError_Error value)? error,
    TResult Function(ComposeTxError_InsufficientFunds value)? insufficientFunds,
    TResult Function(ComposeTxError_InsufficientFees value)? insufficientFees,
    TResult Function(ComposeTxError_InsufficientFeeRate value)?
        insufficientFeeRate,
    required TResult orElse(),
  }) {
    if (insufficientFees != null) {
      return insufficientFees(this);
    }
    return orElse();
  }
}

abstract class ComposeTxError_InsufficientFees extends ComposeTxError {
  const factory ComposeTxError_InsufficientFees(final BigInt field0) =
      _$ComposeTxError_InsufficientFeesImpl;
  const ComposeTxError_InsufficientFees._() : super._();

  @override
  BigInt get field0;

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComposeTxError_InsufficientFeesImplCopyWith<
          _$ComposeTxError_InsufficientFeesImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ComposeTxError_InsufficientFeeRateImplCopyWith<$Res> {
  factory _$$ComposeTxError_InsufficientFeeRateImplCopyWith(
          _$ComposeTxError_InsufficientFeeRateImpl value,
          $Res Function(_$ComposeTxError_InsufficientFeeRateImpl) then) =
      __$$ComposeTxError_InsufficientFeeRateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt field0});
}

/// @nodoc
class __$$ComposeTxError_InsufficientFeeRateImplCopyWithImpl<$Res>
    extends _$ComposeTxErrorCopyWithImpl<$Res,
        _$ComposeTxError_InsufficientFeeRateImpl>
    implements _$$ComposeTxError_InsufficientFeeRateImplCopyWith<$Res> {
  __$$ComposeTxError_InsufficientFeeRateImplCopyWithImpl(
      _$ComposeTxError_InsufficientFeeRateImpl _value,
      $Res Function(_$ComposeTxError_InsufficientFeeRateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$ComposeTxError_InsufficientFeeRateImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BigInt,
    ));
  }
}

/// @nodoc

class _$ComposeTxError_InsufficientFeeRateImpl
    extends ComposeTxError_InsufficientFeeRate {
  const _$ComposeTxError_InsufficientFeeRateImpl(this.field0) : super._();

  @override
  final BigInt field0;

  @override
  String toString() {
    return 'ComposeTxError.insufficientFeeRate(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComposeTxError_InsufficientFeeRateImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComposeTxError_InsufficientFeeRateImplCopyWith<
          _$ComposeTxError_InsufficientFeeRateImpl>
      get copyWith => __$$ComposeTxError_InsufficientFeeRateImplCopyWithImpl<
          _$ComposeTxError_InsufficientFeeRateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) coinSelectionError,
    required TResult Function(String field0) error,
    required TResult Function(String field0) insufficientFunds,
    required TResult Function(BigInt field0) insufficientFees,
    required TResult Function(BigInt field0) insufficientFeeRate,
  }) {
    return insufficientFeeRate(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? coinSelectionError,
    TResult? Function(String field0)? error,
    TResult? Function(String field0)? insufficientFunds,
    TResult? Function(BigInt field0)? insufficientFees,
    TResult? Function(BigInt field0)? insufficientFeeRate,
  }) {
    return insufficientFeeRate?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? coinSelectionError,
    TResult Function(String field0)? error,
    TResult Function(String field0)? insufficientFunds,
    TResult Function(BigInt field0)? insufficientFees,
    TResult Function(BigInt field0)? insufficientFeeRate,
    required TResult orElse(),
  }) {
    if (insufficientFeeRate != null) {
      return insufficientFeeRate(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ComposeTxError_CoinSelectionError value)
        coinSelectionError,
    required TResult Function(ComposeTxError_Error value) error,
    required TResult Function(ComposeTxError_InsufficientFunds value)
        insufficientFunds,
    required TResult Function(ComposeTxError_InsufficientFees value)
        insufficientFees,
    required TResult Function(ComposeTxError_InsufficientFeeRate value)
        insufficientFeeRate,
  }) {
    return insufficientFeeRate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ComposeTxError_CoinSelectionError value)?
        coinSelectionError,
    TResult? Function(ComposeTxError_Error value)? error,
    TResult? Function(ComposeTxError_InsufficientFunds value)?
        insufficientFunds,
    TResult? Function(ComposeTxError_InsufficientFees value)? insufficientFees,
    TResult? Function(ComposeTxError_InsufficientFeeRate value)?
        insufficientFeeRate,
  }) {
    return insufficientFeeRate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ComposeTxError_CoinSelectionError value)?
        coinSelectionError,
    TResult Function(ComposeTxError_Error value)? error,
    TResult Function(ComposeTxError_InsufficientFunds value)? insufficientFunds,
    TResult Function(ComposeTxError_InsufficientFees value)? insufficientFees,
    TResult Function(ComposeTxError_InsufficientFeeRate value)?
        insufficientFeeRate,
    required TResult orElse(),
  }) {
    if (insufficientFeeRate != null) {
      return insufficientFeeRate(this);
    }
    return orElse();
  }
}

abstract class ComposeTxError_InsufficientFeeRate extends ComposeTxError {
  const factory ComposeTxError_InsufficientFeeRate(final BigInt field0) =
      _$ComposeTxError_InsufficientFeeRateImpl;
  const ComposeTxError_InsufficientFeeRate._() : super._();

  @override
  BigInt get field0;

  /// Create a copy of ComposeTxError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComposeTxError_InsufficientFeeRateImplCopyWith<
          _$ComposeTxError_InsufficientFeeRateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
