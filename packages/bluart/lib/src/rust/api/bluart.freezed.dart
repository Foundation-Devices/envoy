// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bluart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BluartPeripheral {
  RustOpaque get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BtleplugPlatformPeripheral field0) ble,
    required TResult Function(StdNetTcpListener field0) tcp,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BtleplugPlatformPeripheral field0)? ble,
    TResult? Function(StdNetTcpListener field0)? tcp,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BtleplugPlatformPeripheral field0)? ble,
    TResult Function(StdNetTcpListener field0)? tcp,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BluartPeripheral_Ble value) ble,
    required TResult Function(BluartPeripheral_Tcp value) tcp,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BluartPeripheral_Ble value)? ble,
    TResult? Function(BluartPeripheral_Tcp value)? tcp,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BluartPeripheral_Ble value)? ble,
    TResult Function(BluartPeripheral_Tcp value)? tcp,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BluartPeripheralCopyWith<$Res> {
  factory $BluartPeripheralCopyWith(
          BluartPeripheral value, $Res Function(BluartPeripheral) then) =
      _$BluartPeripheralCopyWithImpl<$Res, BluartPeripheral>;
}

/// @nodoc
class _$BluartPeripheralCopyWithImpl<$Res, $Val extends BluartPeripheral>
    implements $BluartPeripheralCopyWith<$Res> {
  _$BluartPeripheralCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$BluartPeripheral_BleImplCopyWith<$Res> {
  factory _$$BluartPeripheral_BleImplCopyWith(_$BluartPeripheral_BleImpl value,
          $Res Function(_$BluartPeripheral_BleImpl) then) =
      __$$BluartPeripheral_BleImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BtleplugPlatformPeripheral field0});
}

/// @nodoc
class __$$BluartPeripheral_BleImplCopyWithImpl<$Res>
    extends _$BluartPeripheralCopyWithImpl<$Res, _$BluartPeripheral_BleImpl>
    implements _$$BluartPeripheral_BleImplCopyWith<$Res> {
  __$$BluartPeripheral_BleImplCopyWithImpl(_$BluartPeripheral_BleImpl _value,
      $Res Function(_$BluartPeripheral_BleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$BluartPeripheral_BleImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BtleplugPlatformPeripheral,
    ));
  }
}

/// @nodoc

class _$BluartPeripheral_BleImpl implements BluartPeripheral_Ble {
  const _$BluartPeripheral_BleImpl(this.field0);

  @override
  final BtleplugPlatformPeripheral field0;

  @override
  String toString() {
    return 'BluartPeripheral.ble(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BluartPeripheral_BleImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BluartPeripheral_BleImplCopyWith<_$BluartPeripheral_BleImpl>
      get copyWith =>
          __$$BluartPeripheral_BleImplCopyWithImpl<_$BluartPeripheral_BleImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BtleplugPlatformPeripheral field0) ble,
    required TResult Function(StdNetTcpListener field0) tcp,
  }) {
    return ble(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BtleplugPlatformPeripheral field0)? ble,
    TResult? Function(StdNetTcpListener field0)? tcp,
  }) {
    return ble?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BtleplugPlatformPeripheral field0)? ble,
    TResult Function(StdNetTcpListener field0)? tcp,
    required TResult orElse(),
  }) {
    if (ble != null) {
      return ble(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BluartPeripheral_Ble value) ble,
    required TResult Function(BluartPeripheral_Tcp value) tcp,
  }) {
    return ble(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BluartPeripheral_Ble value)? ble,
    TResult? Function(BluartPeripheral_Tcp value)? tcp,
  }) {
    return ble?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BluartPeripheral_Ble value)? ble,
    TResult Function(BluartPeripheral_Tcp value)? tcp,
    required TResult orElse(),
  }) {
    if (ble != null) {
      return ble(this);
    }
    return orElse();
  }
}

abstract class BluartPeripheral_Ble implements BluartPeripheral {
  const factory BluartPeripheral_Ble(final BtleplugPlatformPeripheral field0) =
      _$BluartPeripheral_BleImpl;

  @override
  BtleplugPlatformPeripheral get field0;
  @JsonKey(ignore: true)
  _$$BluartPeripheral_BleImplCopyWith<_$BluartPeripheral_BleImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BluartPeripheral_TcpImplCopyWith<$Res> {
  factory _$$BluartPeripheral_TcpImplCopyWith(_$BluartPeripheral_TcpImpl value,
          $Res Function(_$BluartPeripheral_TcpImpl) then) =
      __$$BluartPeripheral_TcpImplCopyWithImpl<$Res>;
  @useResult
  $Res call({StdNetTcpListener field0});
}

/// @nodoc
class __$$BluartPeripheral_TcpImplCopyWithImpl<$Res>
    extends _$BluartPeripheralCopyWithImpl<$Res, _$BluartPeripheral_TcpImpl>
    implements _$$BluartPeripheral_TcpImplCopyWith<$Res> {
  __$$BluartPeripheral_TcpImplCopyWithImpl(_$BluartPeripheral_TcpImpl _value,
      $Res Function(_$BluartPeripheral_TcpImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$BluartPeripheral_TcpImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as StdNetTcpListener,
    ));
  }
}

/// @nodoc

class _$BluartPeripheral_TcpImpl implements BluartPeripheral_Tcp {
  const _$BluartPeripheral_TcpImpl(this.field0);

  @override
  final StdNetTcpListener field0;

  @override
  String toString() {
    return 'BluartPeripheral.tcp(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BluartPeripheral_TcpImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BluartPeripheral_TcpImplCopyWith<_$BluartPeripheral_TcpImpl>
      get copyWith =>
          __$$BluartPeripheral_TcpImplCopyWithImpl<_$BluartPeripheral_TcpImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BtleplugPlatformPeripheral field0) ble,
    required TResult Function(StdNetTcpListener field0) tcp,
  }) {
    return tcp(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BtleplugPlatformPeripheral field0)? ble,
    TResult? Function(StdNetTcpListener field0)? tcp,
  }) {
    return tcp?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BtleplugPlatformPeripheral field0)? ble,
    TResult Function(StdNetTcpListener field0)? tcp,
    required TResult orElse(),
  }) {
    if (tcp != null) {
      return tcp(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BluartPeripheral_Ble value) ble,
    required TResult Function(BluartPeripheral_Tcp value) tcp,
  }) {
    return tcp(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BluartPeripheral_Ble value)? ble,
    TResult? Function(BluartPeripheral_Tcp value)? tcp,
  }) {
    return tcp?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BluartPeripheral_Ble value)? ble,
    TResult Function(BluartPeripheral_Tcp value)? tcp,
    required TResult orElse(),
  }) {
    if (tcp != null) {
      return tcp(this);
    }
    return orElse();
  }
}

abstract class BluartPeripheral_Tcp implements BluartPeripheral {
  const factory BluartPeripheral_Tcp(final StdNetTcpListener field0) =
      _$BluartPeripheral_TcpImpl;

  @override
  StdNetTcpListener get field0;
  @JsonKey(ignore: true)
  _$$BluartPeripheral_TcpImplCopyWith<_$BluartPeripheral_TcpImpl>
      get copyWith => throw _privateConstructorUsedError;
}
