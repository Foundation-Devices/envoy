// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      Wallet.fromJson(json['wallet'] as Map<String, dynamic>),
      json['name'] as String? ?? 'Account',
      json['deviceSerial'] as String,
      DateTime.parse(json['dateAdded'] as String),
      json['number'] as int,
    )..initialSyncCompleted = json['initialSyncCompleted'] as bool? ?? true;

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'wallet': instance.wallet,
      'deviceSerial': instance.deviceSerial,
      'name': instance.name,
      'dateAdded': instance.dateAdded.toIso8601String(),
      'number': instance.number,
      'initialSyncCompleted': instance.initialSyncCompleted,
    };
