import 'package:json_annotation/json_annotation.dart';

part 'legacy_account.g.dart';

@JsonSerializable()
class LegacyAccount {
  @JsonKey(name: 'wallet')
  final LegacyWallet wallet;

  final String name;
  final String deviceSerial;
  final String dateAdded;
  final int number;
  final String id;
  final String? dateSynced;

  LegacyAccount({
    required this.wallet,
    required this.name,
    required this.deviceSerial,
    required this.dateAdded,
    required this.number,
    required this.id,
    required this.dateSynced,
  });

  // Factory constructor to create a LegacyAccount from JSON
  factory LegacyAccount.fromJson(Map<String, dynamic> json) =>
      _$LegacyAccountFromJson(json);

  // Method to convert LegacyAccount to JSON
  Map<String, dynamic> toJson() => _$LegacyAccountToJson(this);
}

@JsonSerializable()
class LegacyWallet {
  final String name;
  final String externalDescriptor;
  final String internalDescriptor;

  final String? publicExternalDescriptor;

  final String? publicInternalDescriptor;

  final String type;
  final String network;
  final bool hot;
  final bool hasPassphrase;

  @JsonKey(defaultValue: [])
  final List<dynamic> transactions;

  final List<dynamic> utxos;
  final int balance;
  final double feeRateFast;
  final double feeRateSlow;

  LegacyWallet({
    required this.name,
    required this.externalDescriptor,
    required this.internalDescriptor,
    this.publicExternalDescriptor,
    this.publicInternalDescriptor,
    required this.type,
    required this.network,
    required this.hot,
    required this.hasPassphrase,
    this.transactions = const [],
    required this.utxos,
    required this.balance,
    required this.feeRateFast,
    required this.feeRateSlow,
  });

  // Factory constructor to create a Wallet from JSON
  factory LegacyWallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

  // Method to convert Wallet to JSON
  Map<String, dynamic> toJson() => _$WalletToJson(this);



}