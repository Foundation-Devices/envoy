// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
      json['title'] as String,
      json['description'] as String?,
      (json['duration'] as num).toInt(),
      DateTime.parse(json['publicationDate'] as String),
      (json['resolutionLinkMap'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as String),
      ),
      json['url'] as String,
      json['id'] as String,
      json['watched'] as bool?,
      (json['order'] as num?)?.toInt(),
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'thumbnailUrl': instance.thumbnailUrl,
      'publicationDate': instance.publicationDate.toIso8601String(),
      'url': instance.url,
      'id': instance.id,
      'duration': instance.duration,
      'resolutionLinkMap':
          instance.resolutionLinkMap.map((k, e) => MapEntry(k.toString(), e)),
      'watched': instance.watched,
      'order': instance.order,
      'tags': instance.tags,
    };
