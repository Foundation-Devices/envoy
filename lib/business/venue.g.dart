// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Venue _$VenueFromJson(Map<String, dynamic> json) => Venue(
      (json['id'] as num).toInt(),
      (json['lat'] as num).toDouble(),
      (json['lon'] as num).toDouble(),
      json['category'] as String,
      json['name'] as String,
    );

Map<String, dynamic> _$VenueToJson(Venue instance) => <String, dynamic>{
      'id': instance.id,
      'lat': instance.lat,
      'lon': instance.lon,
      'category': instance.category,
      'name': instance.name,
    };
