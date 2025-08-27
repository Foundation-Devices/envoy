// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ble.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Event {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<BleDevice> field0) scanResult,
    required TResult Function() deviceDisconnected,
    required TResult Function(BleDevice field0) deviceConnected,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<BleDevice> field0)? scanResult,
    TResult? Function()? deviceDisconnected,
    TResult? Function(BleDevice field0)? deviceConnected,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<BleDevice> field0)? scanResult,
    TResult Function()? deviceDisconnected,
    TResult Function(BleDevice field0)? deviceConnected,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Event_ScanResult value) scanResult,
    required TResult Function(Event_DeviceDisconnected value)
        deviceDisconnected,
    required TResult Function(Event_DeviceConnected value) deviceConnected,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Event_ScanResult value)? scanResult,
    TResult? Function(Event_DeviceDisconnected value)? deviceDisconnected,
    TResult? Function(Event_DeviceConnected value)? deviceConnected,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Event_ScanResult value)? scanResult,
    TResult Function(Event_DeviceDisconnected value)? deviceDisconnected,
    TResult Function(Event_DeviceConnected value)? deviceConnected,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) then) =
      _$EventCopyWithImpl<$Res, Event>;
}

/// @nodoc
class _$EventCopyWithImpl<$Res, $Val extends Event>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$Event_ScanResultImplCopyWith<$Res> {
  factory _$$Event_ScanResultImplCopyWith(_$Event_ScanResultImpl value,
          $Res Function(_$Event_ScanResultImpl) then) =
      __$$Event_ScanResultImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<BleDevice> field0});
}

/// @nodoc
class __$$Event_ScanResultImplCopyWithImpl<$Res>
    extends _$EventCopyWithImpl<$Res, _$Event_ScanResultImpl>
    implements _$$Event_ScanResultImplCopyWith<$Res> {
  __$$Event_ScanResultImplCopyWithImpl(_$Event_ScanResultImpl _value,
      $Res Function(_$Event_ScanResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$Event_ScanResultImpl(
      null == field0
          ? _value._field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<BleDevice>,
    ));
  }
}

/// @nodoc

class _$Event_ScanResultImpl extends Event_ScanResult {
  const _$Event_ScanResultImpl(final List<BleDevice> field0)
      : _field0 = field0,
        super._();

  final List<BleDevice> _field0;
  @override
  List<BleDevice> get field0 {
    if (_field0 is EqualUnmodifiableListView) return _field0;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field0);
  }

  @override
  String toString() {
    return 'Event.scanResult(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Event_ScanResultImpl &&
            const DeepCollectionEquality().equals(other._field0, _field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_field0));

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Event_ScanResultImplCopyWith<_$Event_ScanResultImpl> get copyWith =>
      __$$Event_ScanResultImplCopyWithImpl<_$Event_ScanResultImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<BleDevice> field0) scanResult,
    required TResult Function() deviceDisconnected,
    required TResult Function(BleDevice field0) deviceConnected,
  }) {
    return scanResult(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<BleDevice> field0)? scanResult,
    TResult? Function()? deviceDisconnected,
    TResult? Function(BleDevice field0)? deviceConnected,
  }) {
    return scanResult?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<BleDevice> field0)? scanResult,
    TResult Function()? deviceDisconnected,
    TResult Function(BleDevice field0)? deviceConnected,
    required TResult orElse(),
  }) {
    if (scanResult != null) {
      return scanResult(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Event_ScanResult value) scanResult,
    required TResult Function(Event_DeviceDisconnected value)
        deviceDisconnected,
    required TResult Function(Event_DeviceConnected value) deviceConnected,
  }) {
    return scanResult(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Event_ScanResult value)? scanResult,
    TResult? Function(Event_DeviceDisconnected value)? deviceDisconnected,
    TResult? Function(Event_DeviceConnected value)? deviceConnected,
  }) {
    return scanResult?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Event_ScanResult value)? scanResult,
    TResult Function(Event_DeviceDisconnected value)? deviceDisconnected,
    TResult Function(Event_DeviceConnected value)? deviceConnected,
    required TResult orElse(),
  }) {
    if (scanResult != null) {
      return scanResult(this);
    }
    return orElse();
  }
}

abstract class Event_ScanResult extends Event {
  const factory Event_ScanResult(final List<BleDevice> field0) =
      _$Event_ScanResultImpl;
  const Event_ScanResult._() : super._();

  List<BleDevice> get field0;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Event_ScanResultImplCopyWith<_$Event_ScanResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$Event_DeviceDisconnectedImplCopyWith<$Res> {
  factory _$$Event_DeviceDisconnectedImplCopyWith(
          _$Event_DeviceDisconnectedImpl value,
          $Res Function(_$Event_DeviceDisconnectedImpl) then) =
      __$$Event_DeviceDisconnectedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$Event_DeviceDisconnectedImplCopyWithImpl<$Res>
    extends _$EventCopyWithImpl<$Res, _$Event_DeviceDisconnectedImpl>
    implements _$$Event_DeviceDisconnectedImplCopyWith<$Res> {
  __$$Event_DeviceDisconnectedImplCopyWithImpl(
      _$Event_DeviceDisconnectedImpl _value,
      $Res Function(_$Event_DeviceDisconnectedImpl) _then)
      : super(_value, _then);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$Event_DeviceDisconnectedImpl extends Event_DeviceDisconnected {
  const _$Event_DeviceDisconnectedImpl() : super._();

  @override
  String toString() {
    return 'Event.deviceDisconnected()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Event_DeviceDisconnectedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<BleDevice> field0) scanResult,
    required TResult Function() deviceDisconnected,
    required TResult Function(BleDevice field0) deviceConnected,
  }) {
    return deviceDisconnected();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<BleDevice> field0)? scanResult,
    TResult? Function()? deviceDisconnected,
    TResult? Function(BleDevice field0)? deviceConnected,
  }) {
    return deviceDisconnected?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<BleDevice> field0)? scanResult,
    TResult Function()? deviceDisconnected,
    TResult Function(BleDevice field0)? deviceConnected,
    required TResult orElse(),
  }) {
    if (deviceDisconnected != null) {
      return deviceDisconnected();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Event_ScanResult value) scanResult,
    required TResult Function(Event_DeviceDisconnected value)
        deviceDisconnected,
    required TResult Function(Event_DeviceConnected value) deviceConnected,
  }) {
    return deviceDisconnected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Event_ScanResult value)? scanResult,
    TResult? Function(Event_DeviceDisconnected value)? deviceDisconnected,
    TResult? Function(Event_DeviceConnected value)? deviceConnected,
  }) {
    return deviceDisconnected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Event_ScanResult value)? scanResult,
    TResult Function(Event_DeviceDisconnected value)? deviceDisconnected,
    TResult Function(Event_DeviceConnected value)? deviceConnected,
    required TResult orElse(),
  }) {
    if (deviceDisconnected != null) {
      return deviceDisconnected(this);
    }
    return orElse();
  }
}

abstract class Event_DeviceDisconnected extends Event {
  const factory Event_DeviceDisconnected() = _$Event_DeviceDisconnectedImpl;
  const Event_DeviceDisconnected._() : super._();
}

/// @nodoc
abstract class _$$Event_DeviceConnectedImplCopyWith<$Res> {
  factory _$$Event_DeviceConnectedImplCopyWith(
          _$Event_DeviceConnectedImpl value,
          $Res Function(_$Event_DeviceConnectedImpl) then) =
      __$$Event_DeviceConnectedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BleDevice field0});
}

/// @nodoc
class __$$Event_DeviceConnectedImplCopyWithImpl<$Res>
    extends _$EventCopyWithImpl<$Res, _$Event_DeviceConnectedImpl>
    implements _$$Event_DeviceConnectedImplCopyWith<$Res> {
  __$$Event_DeviceConnectedImplCopyWithImpl(_$Event_DeviceConnectedImpl _value,
      $Res Function(_$Event_DeviceConnectedImpl) _then)
      : super(_value, _then);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$Event_DeviceConnectedImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BleDevice,
    ));
  }
}

/// @nodoc

class _$Event_DeviceConnectedImpl extends Event_DeviceConnected {
  const _$Event_DeviceConnectedImpl(this.field0) : super._();

  @override
  final BleDevice field0;

  @override
  String toString() {
    return 'Event.deviceConnected(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Event_DeviceConnectedImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Event_DeviceConnectedImplCopyWith<_$Event_DeviceConnectedImpl>
      get copyWith => __$$Event_DeviceConnectedImplCopyWithImpl<
          _$Event_DeviceConnectedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<BleDevice> field0) scanResult,
    required TResult Function() deviceDisconnected,
    required TResult Function(BleDevice field0) deviceConnected,
  }) {
    return deviceConnected(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<BleDevice> field0)? scanResult,
    TResult? Function()? deviceDisconnected,
    TResult? Function(BleDevice field0)? deviceConnected,
  }) {
    return deviceConnected?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<BleDevice> field0)? scanResult,
    TResult Function()? deviceDisconnected,
    TResult Function(BleDevice field0)? deviceConnected,
    required TResult orElse(),
  }) {
    if (deviceConnected != null) {
      return deviceConnected(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Event_ScanResult value) scanResult,
    required TResult Function(Event_DeviceDisconnected value)
        deviceDisconnected,
    required TResult Function(Event_DeviceConnected value) deviceConnected,
  }) {
    return deviceConnected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Event_ScanResult value)? scanResult,
    TResult? Function(Event_DeviceDisconnected value)? deviceDisconnected,
    TResult? Function(Event_DeviceConnected value)? deviceConnected,
  }) {
    return deviceConnected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Event_ScanResult value)? scanResult,
    TResult Function(Event_DeviceDisconnected value)? deviceDisconnected,
    TResult Function(Event_DeviceConnected value)? deviceConnected,
    required TResult orElse(),
  }) {
    if (deviceConnected != null) {
      return deviceConnected(this);
    }
    return orElse();
  }
}

abstract class Event_DeviceConnected extends Event {
  const factory Event_DeviceConnected(final BleDevice field0) =
      _$Event_DeviceConnectedImpl;
  const Event_DeviceConnected._() : super._();

  BleDevice get field0;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Event_DeviceConnectedImplCopyWith<_$Event_DeviceConnectedImpl>
      get copyWith => throw _privateConstructorUsedError;
}
