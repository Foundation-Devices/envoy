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
  AddressType get preferredAddressType => throw _privateConstructorUsedError;
  bool get seedHasPassphrase => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  List<NgDescriptor> get descriptors => throw _privateConstructorUsedError;
  String? get dateSynced => throw _privateConstructorUsedError;
  Network get network => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  List<(String, AddressType)> get nextAddress =>
      throw _privateConstructorUsedError;
  BigInt get balance => throw _privateConstructorUsedError;
  BigInt get unlockedBalance => throw _privateConstructorUsedError;
  bool get isHot => throw _privateConstructorUsedError;
  List<BitcoinTransaction> get transactions =>
      throw _privateConstructorUsedError;
  List<Output> get utxo => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get xfp => throw _privateConstructorUsedError;
  List<(AddressType, String)> get externalPublicDescriptors =>
      throw _privateConstructorUsedError;

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
      AddressType preferredAddressType,
      bool seedHasPassphrase,
      int index,
      List<NgDescriptor> descriptors,
      String? dateSynced,
      Network network,
      String id,
      List<(String, AddressType)> nextAddress,
      BigInt balance,
      BigInt unlockedBalance,
      bool isHot,
      List<BitcoinTransaction> transactions,
      List<Output> utxo,
      List<String> tags,
      String xfp,
      List<(AddressType, String)> externalPublicDescriptors});
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
    Object? preferredAddressType = null,
    Object? seedHasPassphrase = null,
    Object? index = null,
    Object? descriptors = null,
    Object? dateSynced = freezed,
    Object? network = null,
    Object? id = null,
    Object? nextAddress = null,
    Object? balance = null,
    Object? unlockedBalance = null,
    Object? isHot = null,
    Object? transactions = null,
    Object? utxo = null,
    Object? tags = null,
    Object? xfp = null,
    Object? externalPublicDescriptors = null,
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
      preferredAddressType: null == preferredAddressType
          ? _value.preferredAddressType
          : preferredAddressType // ignore: cast_nullable_to_non_nullable
              as AddressType,
      seedHasPassphrase: null == seedHasPassphrase
          ? _value.seedHasPassphrase
          : seedHasPassphrase // ignore: cast_nullable_to_non_nullable
              as bool,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      descriptors: null == descriptors
          ? _value.descriptors
          : descriptors // ignore: cast_nullable_to_non_nullable
              as List<NgDescriptor>,
      dateSynced: freezed == dateSynced
          ? _value.dateSynced
          : dateSynced // ignore: cast_nullable_to_non_nullable
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
              as List<(String, AddressType)>,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as BigInt,
      unlockedBalance: null == unlockedBalance
          ? _value.unlockedBalance
          : unlockedBalance // ignore: cast_nullable_to_non_nullable
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
      xfp: null == xfp
          ? _value.xfp
          : xfp // ignore: cast_nullable_to_non_nullable
              as String,
      externalPublicDescriptors: null == externalPublicDescriptors
          ? _value.externalPublicDescriptors
          : externalPublicDescriptors // ignore: cast_nullable_to_non_nullable
              as List<(AddressType, String)>,
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
      AddressType preferredAddressType,
      bool seedHasPassphrase,
      int index,
      List<NgDescriptor> descriptors,
      String? dateSynced,
      Network network,
      String id,
      List<(String, AddressType)> nextAddress,
      BigInt balance,
      BigInt unlockedBalance,
      bool isHot,
      List<BitcoinTransaction> transactions,
      List<Output> utxo,
      List<String> tags,
      String xfp,
      List<(AddressType, String)> externalPublicDescriptors});
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
    Object? preferredAddressType = null,
    Object? seedHasPassphrase = null,
    Object? index = null,
    Object? descriptors = null,
    Object? dateSynced = freezed,
    Object? network = null,
    Object? id = null,
    Object? nextAddress = null,
    Object? balance = null,
    Object? unlockedBalance = null,
    Object? isHot = null,
    Object? transactions = null,
    Object? utxo = null,
    Object? tags = null,
    Object? xfp = null,
    Object? externalPublicDescriptors = null,
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
      preferredAddressType: null == preferredAddressType
          ? _value.preferredAddressType
          : preferredAddressType // ignore: cast_nullable_to_non_nullable
              as AddressType,
      seedHasPassphrase: null == seedHasPassphrase
          ? _value.seedHasPassphrase
          : seedHasPassphrase // ignore: cast_nullable_to_non_nullable
              as bool,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      descriptors: null == descriptors
          ? _value._descriptors
          : descriptors // ignore: cast_nullable_to_non_nullable
              as List<NgDescriptor>,
      dateSynced: freezed == dateSynced
          ? _value.dateSynced
          : dateSynced // ignore: cast_nullable_to_non_nullable
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
          ? _value._nextAddress
          : nextAddress // ignore: cast_nullable_to_non_nullable
              as List<(String, AddressType)>,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as BigInt,
      unlockedBalance: null == unlockedBalance
          ? _value.unlockedBalance
          : unlockedBalance // ignore: cast_nullable_to_non_nullable
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
      xfp: null == xfp
          ? _value.xfp
          : xfp // ignore: cast_nullable_to_non_nullable
              as String,
      externalPublicDescriptors: null == externalPublicDescriptors
          ? _value._externalPublicDescriptors
          : externalPublicDescriptors // ignore: cast_nullable_to_non_nullable
              as List<(AddressType, String)>,
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
      required this.preferredAddressType,
      required this.seedHasPassphrase,
      required this.index,
      required final List<NgDescriptor> descriptors,
      this.dateSynced,
      required this.network,
      required this.id,
      required final List<(String, AddressType)> nextAddress,
      required this.balance,
      required this.unlockedBalance,
      required this.isHot,
      required final List<BitcoinTransaction> transactions,
      required final List<Output> utxo,
      required final List<String> tags,
      required this.xfp,
      required final List<(AddressType, String)> externalPublicDescriptors})
      : _descriptors = descriptors,
        _nextAddress = nextAddress,
        _transactions = transactions,
        _utxo = utxo,
        _tags = tags,
        _externalPublicDescriptors = externalPublicDescriptors;

  @override
  final String name;
  @override
  final String color;
  @override
  final String? deviceSerial;
  @override
  final String? dateAdded;
  @override
  final AddressType preferredAddressType;
  @override
  final bool seedHasPassphrase;
  @override
  final int index;
  final List<NgDescriptor> _descriptors;
  @override
  List<NgDescriptor> get descriptors {
    if (_descriptors is EqualUnmodifiableListView) return _descriptors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_descriptors);
  }

  @override
  final String? dateSynced;
  @override
  final Network network;
  @override
  final String id;
  final List<(String, AddressType)> _nextAddress;
  @override
  List<(String, AddressType)> get nextAddress {
    if (_nextAddress is EqualUnmodifiableListView) return _nextAddress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nextAddress);
  }

  @override
  final BigInt balance;
  @override
  final BigInt unlockedBalance;
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
  final String xfp;
  final List<(AddressType, String)> _externalPublicDescriptors;
  @override
  List<(AddressType, String)> get externalPublicDescriptors {
    if (_externalPublicDescriptors is EqualUnmodifiableListView)
      return _externalPublicDescriptors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_externalPublicDescriptors);
  }

  @override
  String toString() {
    return 'EnvoyAccount(name: $name, color: $color, deviceSerial: $deviceSerial, dateAdded: $dateAdded, preferredAddressType: $preferredAddressType, seedHasPassphrase: $seedHasPassphrase, index: $index, descriptors: $descriptors, dateSynced: $dateSynced, network: $network, id: $id, nextAddress: $nextAddress, balance: $balance, unlockedBalance: $unlockedBalance, isHot: $isHot, transactions: $transactions, utxo: $utxo, tags: $tags, xfp: $xfp, externalPublicDescriptors: $externalPublicDescriptors)';
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
            (identical(other.preferredAddressType, preferredAddressType) ||
                other.preferredAddressType == preferredAddressType) &&
            (identical(other.seedHasPassphrase, seedHasPassphrase) ||
                other.seedHasPassphrase == seedHasPassphrase) &&
            (identical(other.index, index) || other.index == index) &&
            const DeepCollectionEquality()
                .equals(other._descriptors, _descriptors) &&
            (identical(other.dateSynced, dateSynced) ||
                other.dateSynced == dateSynced) &&
            (identical(other.network, network) || other.network == network) &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._nextAddress, _nextAddress) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.unlockedBalance, unlockedBalance) ||
                other.unlockedBalance == unlockedBalance) &&
            (identical(other.isHot, isHot) || other.isHot == isHot) &&
            const DeepCollectionEquality()
                .equals(other._transactions, _transactions) &&
            const DeepCollectionEquality().equals(other._utxo, _utxo) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.xfp, xfp) || other.xfp == xfp) &&
            const DeepCollectionEquality().equals(
                other._externalPublicDescriptors, _externalPublicDescriptors));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        name,
        color,
        deviceSerial,
        dateAdded,
        preferredAddressType,
        seedHasPassphrase,
        index,
        const DeepCollectionEquality().hash(_descriptors),
        dateSynced,
        network,
        id,
        const DeepCollectionEquality().hash(_nextAddress),
        balance,
        unlockedBalance,
        isHot,
        const DeepCollectionEquality().hash(_transactions),
        const DeepCollectionEquality().hash(_utxo),
        const DeepCollectionEquality().hash(_tags),
        xfp,
        const DeepCollectionEquality().hash(_externalPublicDescriptors)
      ]);

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
      required final AddressType preferredAddressType,
      required final bool seedHasPassphrase,
      required final int index,
      required final List<NgDescriptor> descriptors,
      final String? dateSynced,
      required final Network network,
      required final String id,
      required final List<(String, AddressType)> nextAddress,
      required final BigInt balance,
      required final BigInt unlockedBalance,
      required final bool isHot,
      required final List<BitcoinTransaction> transactions,
      required final List<Output> utxo,
      required final List<String> tags,
      required final String xfp,
      required final List<(AddressType, String)>
          externalPublicDescriptors}) = _$EnvoyAccountImpl;

  @override
  String get name;
  @override
  String get color;
  @override
  String? get deviceSerial;
  @override
  String? get dateAdded;
  @override
  AddressType get preferredAddressType;
  @override
  bool get seedHasPassphrase;
  @override
  int get index;
  @override
  List<NgDescriptor> get descriptors;
  @override
  String? get dateSynced;
  @override
  Network get network;
  @override
  String get id;
  @override
  List<(String, AddressType)> get nextAddress;
  @override
  BigInt get balance;
  @override
  BigInt get unlockedBalance;
  @override
  bool get isHot;
  @override
  List<BitcoinTransaction> get transactions;
  @override
  List<Output> get utxo;
  @override
  List<String> get tags;
  @override
  String get xfp;
  @override
  List<(AddressType, String)> get externalPublicDescriptors;

  /// Create a copy of EnvoyAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnvoyAccountImplCopyWith<_$EnvoyAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
