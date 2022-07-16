// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      json['memo'] as String,
      json['txId'] as String,
      DateTime.parse(json['date'] as String),
      json['fee'] as int,
      json['received'] as int,
      json['sent'] as int,
      json['blockHeight'] as int,
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
    };

Wallet _$WalletFromJson(Map<String, dynamic> json) => Wallet(
    json['name'] as String,
    json['testnet'] as bool,
    json['externalDescriptor'] as String,
    json['internalDescriptor'] as String)
  ..transactions = (json['transactions'] as List<dynamic>)
      .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
      .toList()
  ..balance = json['balance'] as int
  ..feeRateFast = (json['feeRateFast'] as num).toDouble()
  ..feeRateSlow = (json['feeRateSlow'] as num).toDouble();

Map<String, dynamic> _$WalletToJson(Wallet instance) => <String, dynamic>{
      'name': instance.name,
      'externalDescriptor': instance.externalDescriptor,
      'internalDescriptor': instance.internalDescriptor,
      'testnet': instance.testnet,
      'transactions': instance.transactions,
      'balance': instance.balance,
      'feeRateFast': instance.feeRateFast,
      'feeRateSlow': instance.feeRateSlow,
    };
