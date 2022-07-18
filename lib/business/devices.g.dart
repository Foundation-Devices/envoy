// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
      json['name'] as String,
      $enumDecode(_$DeviceTypeEnumMap, json['type']),
      json['serial'] as String,
      DateTime.parse(json['datePaired'] as String),
      json['firmwareVersion'] as String,
      colorFromJson(json['color'] as String),
    )..pairedAccountIds = (json['pairedAccountIds'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'name': instance.name,
      'type': _$DeviceTypeEnumMap[instance.type],
      'serial': instance.serial,
      'datePaired': instance.datePaired.toIso8601String(),
      'firmwareVersion': instance.firmwareVersion,
      'pairedAccountIds': instance.pairedAccountIds,
      'color': colorToJson(instance.color),
    };

const _$DeviceTypeEnumMap = {
  DeviceType.passportGen1: 'passportGen1',
  DeviceType.passportGen12: 'passportGen12',
  DeviceType.passportGen2: 'passportGen2',
};
