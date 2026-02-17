// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:envoy/util/envoy_storage.dart';

class AllowedRegions {
  static Future<Map<String, Map<String, dynamic>>> allowedRegions() async {
    String jsonString = await rootBundle.loadString(
      'assets/allowed_regions.json',
    );
    Map<String, dynamic> decodedJson = json.decode(jsonString);

    return Map<String, Map<String, dynamic>>.from(decodedJson);
  }

  static Future<bool> isRegionAllowed(String countryCode, String region) async {
    Map<String, Map<String, dynamic>> allowedCountriesWithRegions =
        await allowedRegions();

    if (allowedCountriesWithRegions.containsKey(countryCode)) {
      Map<String, dynamic>? countryInfo =
          allowedCountriesWithRegions[countryCode];

      if (countryInfo != null) {
        Map<String, String> divisions = Map<String, String>.from(
          countryInfo['divisions'],
        );

        if (divisions.isEmpty) {
          return true;
        }

        return divisions.containsValue(region);
      }
    }
    return false;
  }

  static const buyDisabled = ["IN", "GB", "IND", "GBR"];

  static bool? _buyDisabled;

  static Future<bool> checkBuyDisabled() async {
    try {
      final country = await EnvoyStorage().getCountry();
      if (country == null) {
        _buyDisabled = false;
        return _buyDisabled!;
      }

      final countryCode = country.code.toUpperCase();
      final canBuy = await AllowedRegions.isRegionAllowed(
        country.code,
        country.division,
      );

      // Disable if either region is not allowed or country code is in buyDisabled
      final isDisabled = !canBuy || buyDisabled.contains(countryCode);

      _buyDisabled = isDisabled;
      return _buyDisabled!;
    } catch (e) {
      // If something goes wrong, assume not disabled (safe fallback)
      _buyDisabled = false;
      return _buyDisabled!;
    }
  }
}
