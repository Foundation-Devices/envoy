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
  ..syncToCloudSetting = json['syncToCloudSetting'] as bool? ?? false
  ..allowScreenshotsSetting = json['allowScreenshotsSetting'] as bool? ?? false
  ..showTestnetAccountsSetting =
      json['showTestnetAccountsSetting'] as bool? ?? false
  ..showSignetAccountsSetting =
      json['showSignetAccountsSetting'] as bool? ?? false
  ..enableTaprootSetting = json['enableTaprootSetting'] as bool? ?? false;

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'displayUnit': _$DisplayUnitEnumMap[instance.displayUnit]!,
      'selectedFiat': instance.selectedFiat,
      'environment': _$EnvironmentEnumMap[instance.environment]!,
      'selectedElectrumAddress': instance.selectedElectrumAddress,
      'usingDefaultElectrumServer': instance.usingDefaultElectrumServer,
      'usingTor': instance.usingTor,
      'syncToCloudSetting': instance.syncToCloudSetting,
      'allowScreenshotsSetting': instance.allowScreenshotsSetting,
      'showTestnetAccountsSetting': instance.showTestnetAccountsSetting,
      'showSignetAccountsSetting': instance.showSignetAccountsSetting,
      'enableTaprootSetting': instance.enableTaprootSetting,
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
