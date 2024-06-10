// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:envoy/business/venue.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:tor/tor.dart';
import 'package:http_tor/http_tor.dart';
import 'package:envoy/business/scheduler.dart';
import 'dart:core';
import 'package:envoy/business/coordinates.dart';

class MapData {
  static const String mapApiKey =
      String.fromEnvironment("MAP_API_KEY", defaultValue: '');
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

    _restoreVenues();
    addVenues();
  }

  _dropVenues() {
    venues.clear();
  }

  _restoreVenues() async {
    _dropVenues();

    var storedVenues = await EnvoyStorage().getAllLocations();
    for (var venue in storedVenues!) {
      venues.add(venue!);
    }
  }

  storeVenues() async {
    for (var venue in venues) {
      var storedVenue = await EnvoyStorage().getLocationById(venue.id);
      if (storedVenue != null) {
        if (storedVenue.name != venue.name ||
            storedVenue.lon != venue.lon ||
            storedVenue.lat != venue.lat) {
          EnvoyStorage().updateLocation(venue);
        }
      } else {
        EnvoyStorage().insertLocation(venue);
      }
    }
  }

  addVenues() async {
    final response = await HttpTor(Tor.instance, EnvoyScheduler().parallel).get(
      "https://coinmap.org/api/v1/venues/?category=atm",
    ); // fetch only atms

    final data = json.decode(response.body);
    List myVenues = data["venues"];

    List<Venue> updatedVenues = [];
    for (var venue in myVenues) {
      final id = venue["id"];
      final double lat = venue["lat"];
      final double lon = venue["lon"];
      final String category = venue["category"];
      final String name = venue["name"];
      final myVenue = Venue(id, lat, lon, category, name);
      updatedVenues.add(myVenue);
    }
    venues = updatedVenues;

    if (updatedVenues.isNotEmpty) storeVenues();
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

  Future<Response> getVenueInfo(int id) async {
    return await HttpTor(Tor.instance, EnvoyScheduler().parallel).get(
      "https://coinmap.org/api/v1/venues/$id",
    );
  }

  Future<Coordinates> getCoordinates(
      String divisionName, String countryName) async {
    var response = await HttpTor(Tor.instance, EnvoyScheduler().parallel).get(
      "https://api.geoapify.com/v1/geocode/search?text=$divisionName&format=json&apiKey=$mapApiKey",
    );

    var data = jsonDecode(response.body);
    if (data['results'] != null && data['results'].isNotEmpty) {
      for (var result in data['results']) {
        if (result['country'] == countryName) {
          // Extract latitude and longitude
          double latitude = (result['lat'] as num).toDouble();
          double longitude = (result['lon'] as num).toDouble();

          return Coordinates(latitude, longitude);
        }
      }
    }

    // If no matching result is found, search by country name
    var response2 = await HttpTor(Tor.instance, EnvoyScheduler().parallel).get(
      "https://api.geoapify.com/v1/geocode/search?country=$countryName&format=json&apiKey=$mapApiKey",
    );

    var data2 = jsonDecode(response2.body);
    if (data2['results'] != null && data2['results'].isNotEmpty) {
      var firstResult = data2['results'][0];

      // Extract latitude and longitude
      double latitude = (firstResult['lat'] as num).toDouble();
      double longitude = (firstResult['lon'] as num).toDouble();

      return Coordinates(latitude, longitude);
    }

    return Coordinates(null, null);
  }
}
