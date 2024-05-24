// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

class AllowedRegions {
  static final Map<String, Map<String, dynamic>> allowedCountriesWithRegions =
      loadAllowedRegions();

  static Map<String, Map<String, dynamic>> loadAllowedRegions() {
    String jsonString = File('assets/allowed_regions.json').readAsStringSync();
    Map<String, dynamic> decodedJson = json.decode(jsonString);

    return Map<String, Map<String, dynamic>>.from(decodedJson);
  }

  static bool isRegionAllowed(String countryCode, String region) {
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
}
