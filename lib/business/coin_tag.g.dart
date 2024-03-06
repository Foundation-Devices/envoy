// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinTag _$CoinTagFromJson(Map<String, dynamic> json) => CoinTag(
      id: json['id'] as String? ?? CoinTag.generateNewId(),
      name: json['name'] as String,
      account: json['account'] as String,
    )..coinsId =
        (json['coins_id'] as List<dynamic>).map((e) => e as String).toSet();

Map<String, dynamic> _$CoinTagToJson(CoinTag instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'account': instance.account,
      'coins_id': instance.coinsId.toList(),
    };
