// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';

part 'venue.g.dart';

@JsonSerializable()
class Venue {
  final int id;
  final double lat;
  final double lon;
  final String category;
  final String name;
  final String? description;
  final String? openingHours;
  final String? website;
  final String? address;

  Venue(this.id, this.lat, this.lon, this.category, this.name, this.description,
      this.openingHours, this.website, this.address);

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);

  Map<String, dynamic> toJson() => _$VenueToJson(this);
}
