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
      json['description'] as String?,
      json['openingHours'] as String?,
      json['website'] as String?,
      json['address'] as String?,
    );

Map<String, dynamic> _$VenueToJson(Venue instance) => <String, dynamic>{
      'id': instance.id,
      'lat': instance.lat,
      'lon': instance.lon,
      'category': instance.category,
      'name': instance.name,
      'description': instance.description,
      'openingHours': instance.openingHours,
      'website': instance.website,
      'address': instance.address,
    };
