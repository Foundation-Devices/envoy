// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prime_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrimeDevice _$PrimeDeviceFromJson(Map<String, dynamic> json) => PrimeDevice(
      json['bleId'] as String,
      const Uint8ListBase64Converter().fromJson(json['xidDocument'] as String),
    );

Map<String, dynamic> _$PrimeDeviceToJson(PrimeDevice instance) =>
    <String, dynamic>{
      'bleId': instance.bleId,
      'xidDocument':
          const Uint8ListBase64Converter().toJson(instance.xidDocument),
    };
