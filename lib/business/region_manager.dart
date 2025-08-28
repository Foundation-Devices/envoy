// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
    if (_isAllowed != null) {
      return _isAllowed!;
    }

    try {
      // Cache the connection to prevent repeated instantiations
      final connection = InAppPurchase.instance;
      if (!(await connection.isAvailable())) {
        return false;
      }
      String? countryCode = await connection.countryCode();
      _isAllowed = buyDisabled.contains(countryCode);
    } catch (e) {
      _isAllowed = false;
    }
    return _isAllowed!;
  }
}
