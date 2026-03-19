// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings()
  ..displayUnit = $enumDecode(_$DisplayUnitEnumMap, json['displayUnit'])
  ..selectedFiat = json['selectedFiat'] as String?
  ..sendUnit = $enumDecodeNullable(_$AmountDisplayUnitEnumMap, json['sendUnit'])
  ..environment = $enumDecode(_$EnvironmentEnumMap, json['environment'])
  ..selectedElectrumAddress = json['selectedElectrumAddress'] as String
  ..usingDefaultElectrumServer =
      json['usingDefaultElectrumServer'] as bool? ?? true
  ..subSatFeeEnabled = json['subSatFeeEnabled'] as bool? ?? false
  ..skipCertValidationServers =
      (json['skipCertValidationServers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['ssl://electrum.bitaroo.net:50002']
  ..personalElectrumAddress = json['personalElectrumAddress'] as String? ?? ''
  ..usingTor = json['usingTor'] as bool
  ..syncToCloudSetting = json['syncToCloudSetting'] as bool? ?? true
  ..allowScreenshotsSetting = json['allowScreenshotsSetting'] as bool? ?? false
  ..showTestnetAccountsSetting =
      json['showTestnetAccountsSetting'] as bool? ?? false
  ..showSignetAccountsSetting =
      json['showSignetAccountsSetting'] as bool? ?? false
  ..enableTaprootSetting = json['enableTaprootSetting'] as bool? ?? false
  ..usingDefaultBlockExplorer =
      json['usingDefaultBlockExplorer'] as bool? ?? true
  ..personalBlockExplorerAddress =
      json['personalBlockExplorerAddress'] as String? ?? ''
  ..allowBuyInEnvoy = json['allowBuyInEnvoy'] as bool? ?? true;

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'displayUnit': _$DisplayUnitEnumMap[instance.displayUnit]!,
      'selectedFiat': instance.selectedFiat,
      if (_$AmountDisplayUnitEnumMap[instance.sendUnit] case final value?)
        'sendUnit': value,
      'environment': _$EnvironmentEnumMap[instance.environment]!,
      'selectedElectrumAddress': instance.selectedElectrumAddress,
      'usingDefaultElectrumServer': instance.usingDefaultElectrumServer,
      'subSatFeeEnabled': instance.subSatFeeEnabled,
      'skipCertValidationServers': instance.skipCertValidationServers,
      'personalElectrumAddress': instance.personalElectrumAddress,
      'usingTor': instance.usingTor,
      'syncToCloudSetting': instance.syncToCloudSetting,
      'allowScreenshotsSetting': instance.allowScreenshotsSetting,
      'showTestnetAccountsSetting': instance.showTestnetAccountsSetting,
      'showSignetAccountsSetting': instance.showSignetAccountsSetting,
      'enableTaprootSetting': instance.enableTaprootSetting,
      'usingDefaultBlockExplorer': instance.usingDefaultBlockExplorer,
      'personalBlockExplorerAddress': instance.personalBlockExplorerAddress,
      'allowBuyInEnvoy': instance.allowBuyInEnvoy,
    };

const _$DisplayUnitEnumMap = {
  DisplayUnit.btc: 'btc',
  DisplayUnit.sat: 'sat',
};

const _$AmountDisplayUnitEnumMap = {
  AmountDisplayUnit.btc: 'btc',
  AmountDisplayUnit.sat: 'sat',
  AmountDisplayUnit.fiat: 'fiat',
};

const _$EnvironmentEnumMap = {
  Environment.local: 'local',
  Environment.development: 'development',
  Environment.staging: 'staging',
  Environment.production: 'production',
};
