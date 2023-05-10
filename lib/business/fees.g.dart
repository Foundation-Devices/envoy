// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fees.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fees _$FeesFromJson(Map<String, dynamic> json) => Fees()
  ..fees = json['fees'] == null
      ? Fees._defaultFees()
      : Fees._feesFromJson(json['fees'] as Map<String, dynamic>);

Map<String, dynamic> _$FeesToJson(Fees instance) => <String, dynamic>{
      'fees': Fees._feesToJson(instance.fees),
    };
