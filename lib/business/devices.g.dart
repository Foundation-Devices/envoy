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
      deviceColor:
          $enumDecodeNullable(_$DeviceColorEnumMap, json['deviceColor']) ??
              DeviceColor.light,
      bleId: json['bleId'] as String? ?? '',
      peripheralId: json['peripheralId'] as String? ?? '',
      xid: const Uint8ListConverter().fromJson(json['xid'] as List?),
      pairedAccountIds: (json['pairedAccountIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      primeBackupEnabled: json['primeBackupEnabled'] as bool?,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    );

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'name': instance.name,
      'type': _$DeviceTypeEnumMap[instance.type]!,
      'deviceColor': _$DeviceColorEnumMap[instance.deviceColor]!,
      'serial': instance.serial,
      'bleId': instance.bleId,
      'peripheralId': instance.peripheralId,
      'onboardingComplete': instance.onboardingComplete,
      'xid': const Uint8ListConverter().toJson(instance.xid),
      'datePaired': instance.datePaired.toIso8601String(),
      'firmwareVersion': instance.firmwareVersion,
      'pairedAccountIds': instance.pairedAccountIds,
      'primeBackupEnabled': instance.primeBackupEnabled,
      'color': colorToJson(instance.color),
    };

const _$DeviceTypeEnumMap = {
  DeviceType.passportGen1: 'passportGen1',
  DeviceType.passportGen12: 'passportGen12',
  DeviceType.passportPrime: 'passportPrime',
};

const _$DeviceColorEnumMap = {
  DeviceColor.light: 'light',
  DeviceColor.dark: 'dark',
};
