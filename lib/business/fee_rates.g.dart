// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_rates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeeRates _$FeeRatesFromJson(Map<String, dynamic> json) => FeeRates()
  ..mempoolFastestRate = (json['mempoolFastestRate'] as num).toInt()
  ..mempoolHalfHourRate = (json['mempoolHalfHourRate'] as num).toInt()
  ..mempoolHourRate = (json['mempoolHourRate'] as num).toInt()
  ..mempoolEconomyRate = (json['mempoolEconomyRate'] as num).toInt()
  ..mempoolMinimumRate = (json['mempoolMinimumRate'] as num).toInt()
  ..electrumFastRate = (json['electrumFastRate'] as num).toInt()
  ..electrumSlowRate = (json['electrumSlowRate'] as num).toInt()
  ..mempoolBlocksMedianFeeRate =
      (json['mempoolBlocksMedianFeeRate'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [];

Map<String, dynamic> _$FeeRatesToJson(FeeRates instance) => <String, dynamic>{
      'mempoolFastestRate': instance.mempoolFastestRate,
      'mempoolHalfHourRate': instance.mempoolHalfHourRate,
      'mempoolHourRate': instance.mempoolHourRate,
      'mempoolEconomyRate': instance.mempoolEconomyRate,
      'mempoolMinimumRate': instance.mempoolMinimumRate,
      'electrumFastRate': instance.electrumFastRate,
      'electrumSlowRate': instance.electrumSlowRate,
      'mempoolBlocksMedianFeeRate': instance.mempoolBlocksMedianFeeRate,
    };
