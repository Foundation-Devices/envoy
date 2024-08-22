// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnvoyNotification _$EnvoyNotificationFromJson(Map<String, dynamic> json) =>
    EnvoyNotification(
      json['title'] as String,
      json['date'] == null ? null : DateTime.parse(json['date'] as String),
      $enumDecode(_$EnvoyNotificationTypeEnumMap, json['type']),
      json['body'] as String,
      json['id'] as String,
      amount: (json['amount'] as num?)?.toInt(),
      accountId: json['accountId'] as String?,
    );

Map<String, dynamic> _$EnvoyNotificationToJson(EnvoyNotification instance) =>
    <String, dynamic>{
      'title': instance.title,
      'date': instance.date?.toIso8601String(),
      'type': _$EnvoyNotificationTypeEnumMap[instance.type]!,
      'body': instance.body,
      'id': instance.id,
      'amount': instance.amount,
      'accountId': instance.accountId,
    };

const _$EnvoyNotificationTypeEnumMap = {
  EnvoyNotificationType.firmware: 'firmware',
  EnvoyNotificationType.transaction: 'transaction',
  EnvoyNotificationType.security: 'security',
  EnvoyNotificationType.envoyUpdate: 'envoyUpdate',
};
