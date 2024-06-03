// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
      json['code'] as String,
      json['name'] as String,
      json['division'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      coordinatesAvailable: json['coordinatesAvailable'] as bool?,
    );

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'division': instance.division,
      'lat': instance.lat,
      'lon': instance.lon,
      'coordinatesAvailable': instance.coordinatesAvailable,
    };
