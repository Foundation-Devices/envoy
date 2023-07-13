// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinTag _$CoinTagFromJson(Map<String, dynamic> json) => CoinTag(
      id: json['id'] as String,
      name: json['name'] as String,
      coins: (json['coins'] as List<dynamic>)
          .map((e) => Coin.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CoinTagToJson(CoinTag instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'coins': instance.coins,
    };
