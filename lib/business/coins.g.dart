// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coins.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coin _$CoinFromJson(Map<String, dynamic> json) => Coin(
      Utxo.fromJson(json['utxo'] as Map<String, Object?>),
      locked: json['locked'] as bool? ?? false,
      account: json['account'] as String,
    );

Map<String, dynamic> _$CoinToJson(Coin instance) => <String, dynamic>{
      'utxo': _utxoToJson(instance.utxo),
      'locked': instance.locked,
      'account': instance.account,
    };

InputCoinHistory _$InputCoinHistoryFromJson(Map<String, dynamic> json) =>
    InputCoinHistory(
      json['accountId'] as String,
      json['tagName'] as String,
      json['txId'] as String,
      Coin.fromJson(json['coin'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InputCoinHistoryToJson(InputCoinHistory instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'tagName': instance.tagName,
      'txId': instance.txId,
      'coin': _coinToJson(instance.coin),
    };
