// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Passport _$PassportFromJson(Map<String, dynamic> json) => Passport(
      json['xfp'] as String,
      json['publicKey'] as String,
      json['xpub'] as String,
      json['datePaired'] == null
          ? null
          : DateTime.parse(json['datePaired'] as String),
      json['model'] as int,
      json['fwVersion'] as int,
    );

Map<String, dynamic> _$PassportToJson(Passport instance) => <String, dynamic>{
      'xfp': instance.xfp,
      'publicKey': instance.publicKey,
      'xpub': instance.xpub,
      'datePaired': instance.datePaired?.toIso8601String(),
      'model': instance.model,
      'fwVersion': instance.fwVersion,
    };
