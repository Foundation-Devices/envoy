// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Account _$AccountFromJson(Map<String, dynamic> json) {
  return _Account.fromJson(json);
}

/// @nodoc
mixin _$Account {
  Wallet get wallet =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(defaultValue: "Account")
  String get name => throw _privateConstructorUsedError;
  String get deviceSerial => throw _privateConstructorUsedError;
  DateTime get dateAdded => throw _privateConstructorUsedError;
  int get number =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(defaultValue: Account.generateNewId)
  String? get id =>
      throw _privateConstructorUsedError; // Flipped the first time we sync
// ignore: invalid_annotation_target
  @JsonKey(defaultValue: null)
  DateTime? get dateSynced => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccountCopyWith<Account> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountCopyWith<$Res> {
  factory $AccountCopyWith(Account value, $Res Function(Account) then) =
      _$AccountCopyWithImpl<$Res, Account>;
  @useResult
  $Res call(
      {Wallet wallet,
      @JsonKey(defaultValue: "Account") String name,
      String deviceSerial,
      DateTime dateAdded,
      int number,
      @JsonKey(defaultValue: Account.generateNewId) String? id,
      @JsonKey(defaultValue: null) DateTime? dateSynced});
}

/// @nodoc
class _$AccountCopyWithImpl<$Res, $Val extends Account>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wallet = null,
    Object? name = null,
    Object? deviceSerial = null,
    Object? dateAdded = null,
    Object? number = null,
    Object? id = freezed,
    Object? dateSynced = freezed,
  }) {
    return _then(_value.copyWith(
      wallet: null == wallet
          ? _value.wallet
          : wallet // ignore: cast_nullable_to_non_nullable
              as Wallet,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      deviceSerial: null == deviceSerial
          ? _value.deviceSerial
          : deviceSerial // ignore: cast_nullable_to_non_nullable
              as String,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as DateTime,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      dateSynced: freezed == dateSynced
          ? _value.dateSynced
          : dateSynced // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccountImplCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$$AccountImplCopyWith(
          _$AccountImpl value, $Res Function(_$AccountImpl) then) =
      __$$AccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Wallet wallet,
      @JsonKey(defaultValue: "Account") String name,
      String deviceSerial,
      DateTime dateAdded,
      int number,
      @JsonKey(defaultValue: Account.generateNewId) String? id,
      @JsonKey(defaultValue: null) DateTime? dateSynced});
}

/// @nodoc
class __$$AccountImplCopyWithImpl<$Res>
    extends _$AccountCopyWithImpl<$Res, _$AccountImpl>
    implements _$$AccountImplCopyWith<$Res> {
  __$$AccountImplCopyWithImpl(
      _$AccountImpl _value, $Res Function(_$AccountImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wallet = null,
    Object? name = null,
    Object? deviceSerial = null,
    Object? dateAdded = null,
    Object? number = null,
    Object? id = freezed,
    Object? dateSynced = freezed,
  }) {
    return _then(_$AccountImpl(
      wallet: null == wallet
          ? _value.wallet
          : wallet // ignore: cast_nullable_to_non_nullable
              as Wallet,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      deviceSerial: null == deviceSerial
          ? _value.deviceSerial
          : deviceSerial // ignore: cast_nullable_to_non_nullable
              as String,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as DateTime,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      dateSynced: freezed == dateSynced
          ? _value.dateSynced
          : dateSynced // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountImpl extends _Account {
  const _$AccountImpl(
      {required this.wallet,
      @JsonKey(defaultValue: "Account") required this.name,
      required this.deviceSerial,
      required this.dateAdded,
      required this.number,
      @JsonKey(defaultValue: Account.generateNewId) required this.id,
      @JsonKey(defaultValue: null) required this.dateSynced})
      : super._();

  factory _$AccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountImplFromJson(json);

  @override
  final Wallet wallet;
// ignore: invalid_annotation_target
  @override
  @JsonKey(defaultValue: "Account")
  final String name;
  @override
  final String deviceSerial;
  @override
  final DateTime dateAdded;
  @override
  final int number;
// ignore: invalid_annotation_target
  @override
  @JsonKey(defaultValue: Account.generateNewId)
  final String? id;
// Flipped the first time we sync
// ignore: invalid_annotation_target
  @override
  @JsonKey(defaultValue: null)
  final DateTime? dateSynced;

  @override
  String toString() {
    return 'Account(wallet: $wallet, name: $name, deviceSerial: $deviceSerial, dateAdded: $dateAdded, number: $number, id: $id, dateSynced: $dateSynced)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountImpl &&
            (identical(other.wallet, wallet) || other.wallet == wallet) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.deviceSerial, deviceSerial) ||
                other.deviceSerial == deviceSerial) &&
            (identical(other.dateAdded, dateAdded) ||
                other.dateAdded == dateAdded) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dateSynced, dateSynced) ||
                other.dateSynced == dateSynced));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, wallet, name, deviceSerial,
      dateAdded, number, id, dateSynced);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountImplCopyWith<_$AccountImpl> get copyWith =>
      __$$AccountImplCopyWithImpl<_$AccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountImplToJson(
      this,
    );
  }
}

abstract class _Account extends Account {
  const factory _Account(
      {required final Wallet wallet,
      @JsonKey(defaultValue: "Account") required final String name,
      required final String deviceSerial,
      required final DateTime dateAdded,
      required final int number,
      @JsonKey(defaultValue: Account.generateNewId) required final String? id,
      @JsonKey(defaultValue: null)
      required final DateTime? dateSynced}) = _$AccountImpl;
  const _Account._() : super._();

  factory _Account.fromJson(Map<String, dynamic> json) = _$AccountImpl.fromJson;

  @override
  Wallet get wallet;
  @override // ignore: invalid_annotation_target
  @JsonKey(defaultValue: "Account")
  String get name;
  @override
  String get deviceSerial;
  @override
  DateTime get dateAdded;
  @override
  int get number;
  @override // ignore: invalid_annotation_target
  @JsonKey(defaultValue: Account.generateNewId)
  String? get id;
  @override // Flipped the first time we sync
// ignore: invalid_annotation_target
  @JsonKey(defaultValue: null)
  DateTime? get dateSynced;
  @override
  @JsonKey(ignore: true)
  _$$AccountImplCopyWith<_$AccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
