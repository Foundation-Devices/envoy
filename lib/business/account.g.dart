// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountImpl _$$AccountImplFromJson(Map<String, dynamic> json) =>
    _$AccountImpl(
      wallet: Wallet.fromJson(json['wallet'] as Map<String, dynamic>),
      name: json['name'] as String? ?? 'Account',
      deviceSerial: json['deviceSerial'] as String,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      number: json['number'] as int,
      id: json['id'] as String? ?? Account.generateNewId(),
      dateSynced: json['dateSynced'] == null
          ? null
          : DateTime.parse(json['dateSynced'] as String),
    );

Map<String, dynamic> _$$AccountImplToJson(_$AccountImpl instance) =>
    <String, dynamic>{
      'wallet': instance.wallet,
      'name': instance.name,
      'deviceSerial': instance.deviceSerial,
      'dateAdded': instance.dateAdded.toIso8601String(),
      'number': instance.number,
      'id': instance.id,
      'dateSynced': instance.dateSynced?.toIso8601String(),
    };
