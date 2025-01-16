// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';
import 'package:envoy/business/venue.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tor/tor.dart';
import 'package:http_tor/http_tor.dart';
import 'package:envoy/business/scheduler.dart';
import 'dart:core';

class MapData {
  List<Venue> venues = [];

  static final MapData _instance = MapData._internal();

  factory MapData() {
    return _instance;
  }

  static Future<MapData> init() async {
    var singleton = MapData._instance;
    return singleton;
  }

  MapData._internal() {
    kPrint("Instance of MapData created!");

    _restoreVenuesFromJson();
    fetchAndSaveATMData();
  }

  _dropVenues() {
    venues.clear();
  }

  Future<void> _restoreVenuesFromJson() async {
    _dropVenues(); // Clear the existing venues list

    try {
      final parsedData = await _getJsonData();
      if (parsedData != null) {
        _restoreVenuesFromParsedData(parsedData);
        kPrint('Venues successfully restored from JSON.');
      } else {
        throw Exception('No data found in the JSON file.');
      }
    } catch (e) {
      throw Exception('Error restoring venues: $e');
    }
  }

  Future<Map<String, dynamic>?> _getJsonData() async {
    try {
      final String filePath = await getFilePath();
      File file = File(filePath);

      if (await file.exists()) {
        String jsonString = await file.readAsString();
        return json.decode(jsonString);
      } else {
        // Fix JSON file loading on first app run for iOS
        String jsonString = await rootBundle.loadString("assets/atm_data.json");
        return json.decode(jsonString);
      }
    } catch (e) {
      throw Exception('Error retrieving JSON data: $e');
    }
  }

  void _restoreVenuesFromParsedData(Map<String, dynamic> parsedData) {
    if (parsedData.containsKey('elements')) {
      final elements = parsedData['elements'] as List<dynamic>;

      for (var element in elements) {
        if (element['type'] == 'node' && element['tags'] != null) {
          final tags = element['tags'] as Map<String, dynamic>;

          // Extract venue details
          final id = element['id'] as int;
          final lat = element['lat'] as double;
          final lon = element['lon'] as double;
          final category = tags['amenity'] ?? 'Unknown';
          final name = tags['name'] ?? 'Unknown';
          final description = tags['description'];
          final openingHours = tags['opening_hours'];
          final website = tags['website'];
          final address = _buildAddress(tags);

          final venue = Venue(id, lat, lon, category, name, description,
              openingHours, website, address);
          venues.add(venue); // Add to the venue list
        }
      }
    } else {
      throw Exception('No elements found in the JSON data.');
    }
  }

  Future<Map<String, dynamic>> fetchATMData() async {
    const String overpassUrl = 'https://overpass-api.de/api/interpreter';
    const String query = '''
[out:json][timeout:25];
nwr["amenity"="atm"]["currency:XBT"="yes"];
out geom;
''';

    try {
      final response =
          await HttpTor(Tor.instance, EnvoyScheduler().parallel).get(
        overpassUrl,
        body: 'data=$query',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception(
            'Failed to fetch data. HTTP status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<void> saveATMData(Map<String, dynamic> data) async {
    final String filePath = await getFilePath();

    try {
      if (data.isNotEmpty) {
        // Save data to the file
        final file = File(filePath);
        await file.writeAsString(json.encode(data), flush: true);

        // Restore venues from the saved data
        _restoreVenuesFromJson();

        kPrint('Data successfully saved to $filePath');
      } else {
        throw Exception('No data to save.');
      }
    } catch (e) {
      throw Exception('Error saving data: $e');
    }
  }

  Future<void> fetchAndSaveATMData() async {
    final String filePath = await getFilePath();

    try {
      // Read the previously saved JSON data
      final file = File(filePath);
      Map<String, dynamic>? savedJsonData;
      DateTime? savedTimestamp;

      if (await file.exists()) {
        final initialData = await file.readAsString();
        savedJsonData = json.decode(initialData);

        String? timestampString =
            savedJsonData?['osm3s']?['timestamp_osm_base'];
        savedTimestamp =
            timestampString == null ? null : DateTime.parse(timestampString);
      }

      // If there is no saved data or it's older than 7 days
      if (savedJsonData == null ||
          (savedTimestamp != null &&
              DateTime.now()
                  .isAfter(savedTimestamp.add(const Duration(days: 7))))) {
        final newData = await fetchATMData();
        await saveATMData(newData);
      } else {
        kPrint('Data is up to date. Skipping fetch and save.');
      }
    } catch (e) {
      throw Exception('Error in fetchAndSaveATMData: $e');
    }
  }

  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/atm_data.json';
  }

  List<Venue> getLocallyVenues(
      double radius, double longitude, double latitude) {
    List<Venue> locallyVenues = [];

    for (var venue in venues) {
      final double lonDifference = (venue.lon - longitude).abs();
      final double latDifference = (venue.lat - latitude).abs();

      if (lonDifference <= radius && latDifference <= radius) {
        locallyVenues.add(venue);
      }
    }

    return locallyVenues;
  }

// Helper function to build an address string
  String? _buildAddress(Map<String, dynamic> tags) {
    final String? street = tags["addr:street"];
    final String? houseNo = tags["addr:housenumber"];
    final String? city = tags["addr:city"];

    if (street == null && houseNo == null && city == null) {
      return null;
    }

    final String houseNoAndStreet = [
      if (street != null && street.isNotEmpty) street,
      if (houseNo != null && houseNo.isNotEmpty) houseNo,
    ].join(' ');

    return [
      if (houseNoAndStreet.isNotEmpty) houseNoAndStreet,
      if (city != null && city.isNotEmpty) city,
    ].join(', ');
  }
}
