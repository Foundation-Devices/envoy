// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coins.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coin _$CoinFromJson(Map<String, dynamic> json) => Coin(
      hash: json['hash'] as String,
      index: json['index'] as int,
      locked: json['locked'] as bool,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$CoinToJson(Coin instance) => <String, dynamic>{
      'hash': instance.hash,
      'index': instance.index,
      'locked': instance.locked,
      'amount': instance.amount,
    };
