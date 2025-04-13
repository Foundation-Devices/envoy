// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'envoy_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EnvoyAccount {
  String get name => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String? get deviceSerial => throw _privateConstructorUsedError;
  String? get dateAdded => throw _privateConstructorUsedError;
  AddressType get addressType => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  String get internalDescriptor => throw _privateConstructorUsedError;
  String? get externalDescriptor => throw _privateConstructorUsedError;
  String? get dateSynced => throw _privateConstructorUsedError;
  String? get walletPath => throw _privateConstructorUsedError;
  Network get network => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  String get nextAddress => throw _privateConstructorUsedError;
  BigInt get balance => throw _privateConstructorUsedError;
  bool get isHot => throw _privateConstructorUsedError;
  List<BitcoinTransaction> get transactions =>
      throw _privateConstructorUsedError;
  List<Output> get utxo => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  /// Create a copy of EnvoyAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnvoyAccountCopyWith<EnvoyAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnvoyAccountCopyWith<$Res> {
  factory $EnvoyAccountCopyWith(
          EnvoyAccount value, $Res Function(EnvoyAccount) then) =
      _$EnvoyAccountCopyWithImpl<$Res, EnvoyAccount>;
  @useResult
  $Res call(
      {String name,
      String color,
      String? deviceSerial,
      String? dateAdded,
      AddressType addressType,
      int index,
      String internalDescriptor,
      String? externalDescriptor,
      String? dateSynced,
      String? walletPath,
      Network network,
      String id,
      String nextAddress,
      BigInt balance,
      bool isHot,
      List<BitcoinTransaction> transactions,
      List<Output> utxo,
      List<String> tags});
}

/// @nodoc
class _$EnvoyAccountCopyWithImpl<$Res, $Val extends EnvoyAccount>
    implements $EnvoyAccountCopyWith<$Res> {
  _$EnvoyAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EnvoyAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? color = null,
    Object? deviceSerial = freezed,
    Object? dateAdded = freezed,
    Object? addressType = null,
    Object? index = null,
    Object? internalDescriptor = null,
    Object? externalDescriptor = freezed,
    Object? dateSynced = freezed,
    Object? walletPath = freezed,
    Object? network = null,
    Object? id = null,
    Object? nextAddress = null,
    Object? balance = null,
    Object? isHot = null,
    Object? transactions = null,
    Object? utxo = null,
    Object? tags = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      deviceSerial: freezed == deviceSerial
          ? _value.deviceSerial
          : deviceSerial // ignore: cast_nullable_to_non_nullable
              as String?,
      dateAdded: freezed == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as String?,
      addressType: null == addressType
          ? _value.addressType
          : addressType // ignore: cast_nullable_to_non_nullable
              as AddressType,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      internalDescriptor: null == internalDescriptor
          ? _value.internalDescriptor
          : internalDescriptor // ignore: cast_nullable_to_non_nullable
              as String,
      externalDescriptor: freezed == externalDescriptor
          ? _value.externalDescriptor
          : externalDescriptor // ignore: cast_nullable_to_non_nullable
              as String?,
      dateSynced: freezed == dateSynced
          ? _value.dateSynced
          : dateSynced // ignore: cast_nullable_to_non_nullable
              as String?,
      walletPath: freezed == walletPath
          ? _value.walletPath
          : walletPath // ignore: cast_nullable_to_non_nullable
              as String?,
      network: null == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as Network,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nextAddress: null == nextAddress
          ? _value.nextAddress
          : nextAddress // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as BigInt,
      isHot: null == isHot
          ? _value.isHot
          : isHot // ignore: cast_nullable_to_non_nullable
              as bool,
      transactions: null == transactions
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<BitcoinTransaction>,
      utxo: null == utxo
          ? _value.utxo
          : utxo // ignore: cast_nullable_to_non_nullable
              as List<Output>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EnvoyAccountImplCopyWith<$Res>
    implements $EnvoyAccountCopyWith<$Res> {
  factory _$$EnvoyAccountImplCopyWith(
          _$EnvoyAccountImpl value, $Res Function(_$EnvoyAccountImpl) then) =
      __$$EnvoyAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String color,
      String? deviceSerial,
      String? dateAdded,
      AddressType addressType,
      int index,
      String internalDescriptor,
      String? externalDescriptor,
      String? dateSynced,
      String? walletPath,
      Network network,
      String id,
      String nextAddress,
      BigInt balance,
      bool isHot,
      List<BitcoinTransaction> transactions,
      List<Output> utxo,
      List<String> tags});
}

/// @nodoc
class __$$EnvoyAccountImplCopyWithImpl<$Res>
    extends _$EnvoyAccountCopyWithImpl<$Res, _$EnvoyAccountImpl>
    implements _$$EnvoyAccountImplCopyWith<$Res> {
  __$$EnvoyAccountImplCopyWithImpl(
      _$EnvoyAccountImpl _value, $Res Function(_$EnvoyAccountImpl) _then)
      : super(_value, _then);

  /// Create a copy of EnvoyAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? color = null,
    Object? deviceSerial = freezed,
    Object? dateAdded = freezed,
    Object? addressType = null,
    Object? index = null,
    Object? internalDescriptor = null,
    Object? externalDescriptor = freezed,
    Object? dateSynced = freezed,
    Object? walletPath = freezed,
    Object? network = null,
    Object? id = null,
    Object? nextAddress = null,
    Object? balance = null,
    Object? isHot = null,
    Object? transactions = null,
    Object? utxo = null,
    Object? tags = null,
  }) {
    return _then(_$EnvoyAccountImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      deviceSerial: freezed == deviceSerial
          ? _value.deviceSerial
          : deviceSerial // ignore: cast_nullable_to_non_nullable
              as String?,
      dateAdded: freezed == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as String?,
      addressType: null == addressType
          ? _value.addressType
          : addressType // ignore: cast_nullable_to_non_nullable
              as AddressType,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      internalDescriptor: null == internalDescriptor
          ? _value.internalDescriptor
          : internalDescriptor // ignore: cast_nullable_to_non_nullable
              as String,
      externalDescriptor: freezed == externalDescriptor
          ? _value.externalDescriptor
          : externalDescriptor // ignore: cast_nullable_to_non_nullable
              as String?,
      dateSynced: freezed == dateSynced
          ? _value.dateSynced
          : dateSynced // ignore: cast_nullable_to_non_nullable
              as String?,
      walletPath: freezed == walletPath
          ? _value.walletPath
          : walletPath // ignore: cast_nullable_to_non_nullable
              as String?,
      network: null == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as Network,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nextAddress: null == nextAddress
          ? _value.nextAddress
          : nextAddress // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as BigInt,
      isHot: null == isHot
          ? _value.isHot
          : isHot // ignore: cast_nullable_to_non_nullable
              as bool,
      transactions: null == transactions
          ? _value._transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<BitcoinTransaction>,
      utxo: null == utxo
          ? _value._utxo
          : utxo // ignore: cast_nullable_to_non_nullable
              as List<Output>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$EnvoyAccountImpl implements _EnvoyAccount {
  const _$EnvoyAccountImpl(
      {required this.name,
      required this.color,
      this.deviceSerial,
      this.dateAdded,
      required this.addressType,
      required this.index,
      required this.internalDescriptor,
      this.externalDescriptor,
      this.dateSynced,
      this.walletPath,
      required this.network,
      required this.id,
      required this.nextAddress,
      required this.balance,
      required this.isHot,
      required final List<BitcoinTransaction> transactions,
      required final List<Output> utxo,
      required final List<String> tags})
      : _transactions = transactions,
        _utxo = utxo,
        _tags = tags;

  @override
  final String name;
  @override
  final String color;
  @override
  final String? deviceSerial;
  @override
  final String? dateAdded;
  @override
  final AddressType addressType;
  @override
  final int index;
  @override
  final String internalDescriptor;
  @override
  final String? externalDescriptor;
  @override
  final String? dateSynced;
  @override
  final String? walletPath;
  @override
  final Network network;
  @override
  final String id;
  @override
  final String nextAddress;
  @override
  final BigInt balance;
  @override
  final bool isHot;
  final List<BitcoinTransaction> _transactions;
  @override
  List<BitcoinTransaction> get transactions {
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactions);
  }

  final List<Output> _utxo;
  @override
  List<Output> get utxo {
    if (_utxo is EqualUnmodifiableListView) return _utxo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_utxo);
  }

  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'EnvoyAccount(name: $name, color: $color, deviceSerial: $deviceSerial, dateAdded: $dateAdded, addressType: $addressType, index: $index, internalDescriptor: $internalDescriptor, externalDescriptor: $externalDescriptor, dateSynced: $dateSynced, walletPath: $walletPath, network: $network, id: $id, nextAddress: $nextAddress, balance: $balance, isHot: $isHot, transactions: $transactions, utxo: $utxo, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnvoyAccountImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.deviceSerial, deviceSerial) ||
                other.deviceSerial == deviceSerial) &&
            (identical(other.dateAdded, dateAdded) ||
                other.dateAdded == dateAdded) &&
            (identical(other.addressType, addressType) ||
                other.addressType == addressType) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.internalDescriptor, internalDescriptor) ||
                other.internalDescriptor == internalDescriptor) &&
            (identical(other.externalDescriptor, externalDescriptor) ||
                other.externalDescriptor == externalDescriptor) &&
            (identical(other.dateSynced, dateSynced) ||
                other.dateSynced == dateSynced) &&
            (identical(other.walletPath, walletPath) ||
                other.walletPath == walletPath) &&
            (identical(other.network, network) || other.network == network) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nextAddress, nextAddress) ||
                other.nextAddress == nextAddress) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.isHot, isHot) || other.isHot == isHot) &&
            const DeepCollectionEquality()
                .equals(other._transactions, _transactions) &&
            const DeepCollectionEquality().equals(other._utxo, _utxo) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      color,
      deviceSerial,
      dateAdded,
      addressType,
      index,
      internalDescriptor,
      externalDescriptor,
      dateSynced,
      walletPath,
      network,
      id,
      nextAddress,
      balance,
      isHot,
      const DeepCollectionEquality().hash(_transactions),
      const DeepCollectionEquality().hash(_utxo),
      const DeepCollectionEquality().hash(_tags));

  /// Create a copy of EnvoyAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnvoyAccountImplCopyWith<_$EnvoyAccountImpl> get copyWith =>
      __$$EnvoyAccountImplCopyWithImpl<_$EnvoyAccountImpl>(this, _$identity);
}

abstract class _EnvoyAccount implements EnvoyAccount {
  const factory _EnvoyAccount(
      {required final String name,
      required final String color,
      final String? deviceSerial,
      final String? dateAdded,
      required final AddressType addressType,
      required final int index,
      required final String internalDescriptor,
      final String? externalDescriptor,
      final String? dateSynced,
      final String? walletPath,
      required final Network network,
      required final String id,
      required final String nextAddress,
      required final BigInt balance,
      required final bool isHot,
      required final List<BitcoinTransaction> transactions,
      required final List<Output> utxo,
      required final List<String> tags}) = _$EnvoyAccountImpl;

  @override
  String get name;
  @override
  String get color;
  @override
  String? get deviceSerial;
  @override
  String? get dateAdded;
  @override
  AddressType get addressType;
  @override
  int get index;
  @override
  String get internalDescriptor;
  @override
  String? get externalDescriptor;
  @override
  String? get dateSynced;
  @override
  String? get walletPath;
  @override
  Network get network;
  @override
  String get id;
  @override
  String get nextAddress;
  @override
  BigInt get balance;
  @override
  bool get isHot;
  @override
  List<BitcoinTransaction> get transactions;
  @override
  List<Output> get utxo;
  @override
  List<String> get tags;

  /// Create a copy of EnvoyAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnvoyAccountImplCopyWith<_$EnvoyAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
