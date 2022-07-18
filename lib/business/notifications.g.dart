// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnvoyNotification _$EnvoyNotificationFromJson(Map<String, dynamic> json) =>
    EnvoyNotification(
      json['title'] as String,
      DateTime.parse(json['date'] as String),
      $enumDecode(_$EnvoyNotificationTypeEnumMap, json['type']),
      json['body'] as String,
      json['id'] as String,
      amount: json['amount'] as int?,
      walletName: json['walletName'] as String?,
    );

Map<String, dynamic> _$EnvoyNotificationToJson(EnvoyNotification instance) =>
    <String, dynamic>{
      'title': instance.title,
      'date': instance.date.toIso8601String(),
      'type': _$EnvoyNotificationTypeEnumMap[instance.type],
      'body': instance.body,
      'id': instance.id,
      'amount': instance.amount,
      'walletName': instance.walletName,
    };

const _$EnvoyNotificationTypeEnumMap = {
  EnvoyNotificationType.firmware: 'firmware',
  EnvoyNotificationType.transaction: 'transaction',
  EnvoyNotificationType.security: 'security',
};
