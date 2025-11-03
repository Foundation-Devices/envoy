// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:envoy/util/envoy_storage.dart';

// Cache the inapp-country availability
bool? _isAllowed;

class AllowedRegions {
  static Future<Map<String, Map<String, dynamic>>> allowedRegions() async {
    String jsonString =
        await rootBundle.loadString('assets/allowed_regions.json');
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
        Map<String, String> divisions =
            Map<String, String>.from(countryInfo['divisions']);

        if (divisions.isEmpty) {
          return true;
        }

        return divisions.containsValue(region);
      }
    }
    return false;
  }

  static const buyDisabled = ["IN", "GB", "IND", "GBR"];

  //returns true if buy is disabled
  static Future<bool> checkBuyDisabled() async {
    try {
      // Return cached result if available
      if (_isAllowed != null) return _isAllowed!;

      final country = await EnvoyStorage().getCountry();
      if (country == null) {
        _isAllowed = false;
        return _isAllowed!;
      }

      final countryCode = country.code.toUpperCase();
      final canBuy =
          await AllowedRegions.isRegionAllowed(country.code, country.division);

      // Disable buying if either the region is not allowed
      // or the country code is in the buyDisabled list.
      _isAllowed = !(buyDisabled.contains(countryCode) || !canBuy);
      return !_isAllowed! ? true : false; // true if buy is disabled
    } catch (e) {
      // If something goes wrong, assume buying is not disabled.
      _isAllowed = false;
      return _isAllowed!;
    }
  }
}
