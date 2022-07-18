// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

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
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'wallet': instance.wallet,
      'deviceSerial': instance.deviceSerial,
      'name': instance.name,
      'dateAdded': instance.dateAdded.toIso8601String(),
      'number': instance.number,
    };
