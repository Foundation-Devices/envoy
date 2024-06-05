// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';
import 'package:envoy/business/coordinates.dart';

part 'country.g.dart';

@JsonSerializable(explicitToJson: true)
class Country {
  final String code;
  final String name;
  final String division;
  Coordinates? coordinates;

  Country(this.code, this.name, this.division, {this.coordinates});

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);

  Map<String, dynamic> toJson() => _$CountryToJson(this);
}
