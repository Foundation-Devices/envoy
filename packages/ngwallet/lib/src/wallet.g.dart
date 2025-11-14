// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      json['memo'] as String,
      json['txId'] as String,
      DateTime.parse(json['date'] as String),
      (json['fee'] as num).toInt(),
      (json['received'] as num).toInt(),
      (json['sent'] as num).toInt(),
      (json['blockHeight'] as num).toInt(),
      json['address'] as String?,
      type: $enumDecodeNullable(_$TransactionTypeEnumMap, json['type']) ??
          TransactionType.normal,
      outputs:
          (json['outputs'] as List<dynamic>?)?.map((e) => e as String).toList(),
      inputs:
          (json['inputs'] as List<dynamic>?)?.map((e) => e as String).toList(),
      vsize: (json['vsize'] as num?)?.toInt(),
      pullPaymentId: json['pullPaymentId'] as String?,
      purchaseViewToken: json['purchaseViewToken'] as String?,
      currencyAmount: json['currencyAmount'] as String?,
      currency: json['currency'] as String?,
      payoutId: json['payoutId'] as String?,
      btcPayVoucherUri: json['btcPayVoucherUri'] as String?,
      rampFee: (json['rampFee'] as num?)?.toInt(),
      rampId: json['rampId'] as String?,
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'memo': instance.memo,
      'txId': instance.txId,
      'date': instance.date.toIso8601String(),
      'fee': instance.fee,
      'sent': instance.sent,
      'received': instance.received,
      'blockHeight': instance.blockHeight,
      'outputs': instance.outputs,
      'inputs': instance.inputs,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'address': instance.address,
      'vsize': instance.vsize,
      'pullPaymentId': instance.pullPaymentId,
      'purchaseViewToken': instance.purchaseViewToken,
      'currencyAmount': instance.currencyAmount,
      'currency': instance.currency,
      'payoutId': instance.payoutId,
      'btcPayVoucherUri': instance.btcPayVoucherUri,
      'rampId': instance.rampId,
      'rampFee': instance.rampFee,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.normal: 'normal',
  TransactionType.azteco: 'azteco',
  TransactionType.pending: 'pending',
  TransactionType.btcPay: 'btcPay',
  TransactionType.ramp: 'ramp',
  TransactionType.stripe: 'stripe',
};

Wallet _$WalletFromJson(Map<String, dynamic> json) => Wallet(
      json['name'] as String,
      $enumDecodeNullable(_$WalletNetworkEnumMap, json['network']) ??
          WalletNetwork.Mainnet,
      json['externalDescriptor'] as String?,
      json['internalDescriptor'] as String?,
      hot: json['hot'] as bool? ?? false,
      hasPassphrase: json['hasPassphrase'] as bool? ?? false,
      publicExternalDescriptor: json['publicExternalDescriptor'] as String?,
      publicInternalDescriptor: json['publicInternalDescriptor'] as String?,
      type: $enumDecodeNullable(_$WalletTypeEnumMap, json['type']) ??
          WalletType.witnessPublicKeyHash,
    )
      ..transactions = (json['transactions'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList()
      ..utxos = (json['utxos'] as List<dynamic>?)
              ?.map((e) => Utxo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..balance = (json['balance'] as num).toInt()
      ..feeRateFast = (json['feeRateFast'] as num).toDouble()
      ..feeRateSlow = (json['feeRateSlow'] as num).toDouble();

Map<String, dynamic> _$WalletToJson(Wallet instance) => <String, dynamic>{
      'name': instance.name,
      'externalDescriptor': instance.externalDescriptor,
      'internalDescriptor': instance.internalDescriptor,
      'publicExternalDescriptor': instance.publicExternalDescriptor,
      'publicInternalDescriptor': instance.publicInternalDescriptor,
      'type': _$WalletTypeEnumMap[instance.type]!,
      'network': _$WalletNetworkEnumMap[instance.network]!,
      'hot': instance.hot,
      'hasPassphrase': instance.hasPassphrase,
      'transactions': instance.transactions,
      'utxos': instance.utxos,
      'balance': instance.balance,
      'feeRateFast': instance.feeRateFast,
      'feeRateSlow': instance.feeRateSlow,
    };

const _$WalletNetworkEnumMap = {
  WalletNetwork.Mainnet: 'Mainnet',
  WalletNetwork.Testnet: 'Testnet',
  WalletNetwork.Signet: 'Signet',
  WalletNetwork.Regtest: 'Regtest',
};

const _$WalletTypeEnumMap = {
  WalletType.witnessPublicKeyHash: 'witnessPublicKeyHash',
  WalletType.taproot: 'taproot',
  WalletType.superWallet: 'superWallet',
};

_$UtxoImpl _$$UtxoImplFromJson(Map<String, dynamic> json) => _$UtxoImpl(
      txid: json['txid'] as String,
      vout: (json['vout'] as num).toInt(),
      value: (json['value'] as num).toInt(),
    );

Map<String, dynamic> _$$UtxoImplToJson(_$UtxoImpl instance) =>
    <String, dynamic>{
      'txid': instance.txid,
      'vout': instance.vout,
      'value': instance.value,
    };
