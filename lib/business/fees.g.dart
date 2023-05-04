// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fees.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fees _$FeesFromJson(Map<String, dynamic> json) => Fees()
  ..fees = (json['fees'] as Map<String, dynamic>).map(
    (k, e) => MapEntry($enumDecode(_$NetworkEnumMap, k),
        FeeRates.fromJson(e as Map<String, dynamic>)),
  );

Map<String, dynamic> _$FeesToJson(Fees instance) => <String, dynamic>{
      'fees': instance.fees.map((k, e) => MapEntry(_$NetworkEnumMap[k]!, e)),
    };

const _$NetworkEnumMap = {
  Network.Mainnet: 'Mainnet',
  Network.Testnet: 'Testnet',
  Network.Signet: 'Signet',
  Network.Regtest: 'Regtest',
};
