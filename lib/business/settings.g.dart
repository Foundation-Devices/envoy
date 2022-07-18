// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings()
  ..displayUnit = $enumDecode(_$DisplayUnitEnumMap, json['displayUnit'])
  ..selectedFiat = json['selectedFiat'] as String?
  ..environment = $enumDecode(_$EnvironmentEnumMap, json['environment'])
  ..selectedElectrumAddress = json['selectedElectrumAddress'] as String
  ..usingDefaultElectrumServer =
      json['usingDefaultElectrumServer'] as bool? ?? true
  ..usingTor = json['usingTor'] as bool
  ..nguServerAddress = json['nguServerAddress'] as String
  ..usingTestnet = json['usingTestnet'] as bool;

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'displayUnit': _$DisplayUnitEnumMap[instance.displayUnit],
      'selectedFiat': instance.selectedFiat,
      'environment': _$EnvironmentEnumMap[instance.environment],
      'selectedElectrumAddress': instance.selectedElectrumAddress,
      'usingDefaultElectrumServer': instance.usingDefaultElectrumServer,
      'usingTor': instance.usingTor,
      'nguServerAddress': instance.nguServerAddress,
      'usingTestnet': instance.usingTestnet,
    };

const _$DisplayUnitEnumMap = {
  DisplayUnit.btc: 'btc',
  DisplayUnit.sat: 'sat',
};

const _$EnvironmentEnumMap = {
  Environment.local: 'local',
  Environment.development: 'development',
  Environment.staging: 'staging',
  Environment.production: 'production',
};
