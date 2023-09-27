// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlogPost _$BlogPostFromJson(Map<String, dynamic> json) => BlogPost(
      json['title'] as String,
      json['description'] as String?,
      DateTime.parse(json['publicationDate'] as String),
      json['url'] as String,
      json['id'] as String,
      json['read'] as bool?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );

Map<String, dynamic> _$BlogPostToJson(BlogPost instance) => <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'thumbnailUrl': instance.thumbnailUrl,
      'publicationDate': instance.publicationDate.toIso8601String(),
      'url': instance.url,
      'id': instance.id,
      'read': instance.read,
    };
