// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fees.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fees _$FeesFromJson(Map<String, dynamic> json) => Fees()
  ..mempoolFastestRate = (json['mempoolFastestRate'] as num).toDouble()
  ..mempoolHalfHourRate = (json['mempoolHalfHourRate'] as num).toDouble()
  ..mempoolHourRate = (json['mempoolHourRate'] as num).toDouble()
  ..mempoolEconomyRate = (json['mempoolEconomyRate'] as num).toDouble()
  ..mempoolMinimumRate = (json['mempoolMinimumRate'] as num).toDouble()
  ..electrumFastRate = (json['electrumFastRate'] as num).toDouble()
  ..electrumSlowRate = (json['electrumSlowRate'] as num).toDouble();

Map<String, dynamic> _$FeesToJson(Fees instance) => <String, dynamic>{
      'mempoolFastestRate': instance.mempoolFastestRate,
      'mempoolHalfHourRate': instance.mempoolHalfHourRate,
      'mempoolHourRate': instance.mempoolHourRate,
      'mempoolEconomyRate': instance.mempoolEconomyRate,
      'mempoolMinimumRate': instance.mempoolMinimumRate,
      'electrumFastRate': instance.electrumFastRate,
      'electrumSlowRate': instance.electrumSlowRate,
    };
