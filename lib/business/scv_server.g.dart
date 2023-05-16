// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scv_server.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Challenge _$ChallengeFromJson(Map<String, dynamic> json) => Challenge(
      json['challenge'] as String,
      json['signature'] as String,
      json['derSignature'] as String,
    );

Map<String, dynamic> _$ChallengeToJson(Challenge instance) => <String, dynamic>{
      'challenge': instance.id,
      'signature': instance.signature,
      'derSignature': instance.derSignature,
    };
