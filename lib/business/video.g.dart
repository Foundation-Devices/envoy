// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
      $enumDecode(_$VideoTypeEnumMap, json['type']),
      json['title'] as String,
      json['description'] as String?,
      json['duration'] as int,
      DateTime.parse(json['publicationDate'] as String),
      (json['resolutionLinkMap'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as String),
      ),
      json['url'] as String,
      json['id'] as String,
      json['watched'] as bool?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'thumbnailUrl': instance.thumbnailUrl,
      'publicationDate': instance.publicationDate.toIso8601String(),
      'url': instance.url,
      'id': instance.id,
      'type': _$VideoTypeEnumMap[instance.type]!,
      'duration': instance.duration,
      'resolutionLinkMap':
          instance.resolutionLinkMap.map((k, e) => MapEntry(k.toString(), e)),
      'watched': instance.watched,
    };

const _$VideoTypeEnumMap = {
  VideoType.youTube: 'youTube',
  VideoType.bitcoinTv: 'bitcoinTv',
};
