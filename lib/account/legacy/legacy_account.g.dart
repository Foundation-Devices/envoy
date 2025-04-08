// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legacy_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LegacyAccount _$LegacyAccountFromJson(Map<String, dynamic> json) =>
    LegacyAccount(
      wallet: LegacyWallet.fromJson(json['wallet'] as Map<String, dynamic>),
      name: json['name'] as String,
      deviceSerial: json['deviceSerial'] as String,
      dateAdded: json['dateAdded'] as String,
      number: (json['number'] as num).toInt(),
      id: json['id'] as String,
      dateSynced: json['dateSynced'] as String?,
    );

Map<String, dynamic> _$LegacyAccountToJson(LegacyAccount instance) =>
    <String, dynamic>{
      'wallet': instance.wallet,
      'name': instance.name,
      'deviceSerial': instance.deviceSerial,
      'dateAdded': instance.dateAdded,
      'number': instance.number,
      'id': instance.id,
      'dateSynced': instance.dateSynced,
    };

LegacyWallet _$WalletFromJson(Map<String, dynamic> json) => LegacyWallet(
      name: json['name'] as String,
      externalDescriptor: json['externalDescriptor'] as String,
      internalDescriptor: json['internalDescriptor'] as String,
      publicExternalDescriptor: json['publicExternalDescriptor'] as String?,
      publicInternalDescriptor: json['publicInternalDescriptor'] as String?,
      type: json['type'] as String,
      network: json['network'] as String,
      hot: json['hot'] as bool,
      hasPassphrase: json['hasPassphrase'] as bool,
      transactions: json['transactions'] as List<dynamic>? ?? [],
      utxos: json['utxos'] as List<dynamic>,
      balance: (json['balance'] as num).toInt(),
      feeRateFast: (json['feeRateFast'] as num).toDouble(),
      feeRateSlow: (json['feeRateSlow'] as num).toDouble(),
    );

Map<String, dynamic> _$WalletToJson(LegacyWallet instance) => <String, dynamic>{
      'name': instance.name,
      'externalDescriptor': instance.externalDescriptor,
      'internalDescriptor': instance.internalDescriptor,
      'publicExternalDescriptor': instance.publicExternalDescriptor,
      'publicInternalDescriptor': instance.publicInternalDescriptor,
      'type': instance.type,
      'network': instance.network,
      'hot': instance.hot,
      'hasPassphrase': instance.hasPassphrase,
      'transactions': instance.transactions,
      'utxos': instance.utxos,
      'balance': instance.balance,
      'feeRateFast': instance.feeRateFast,
      'feeRateSlow': instance.feeRateSlow,
    };
