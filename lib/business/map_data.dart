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

  Future<void> getHomeLocation() async {
    var country = await EnvoyStorage().getCountry();
    if (country != null) {
      String name = country.name;
      var response = await HttpTor(Tor.instance, EnvoyScheduler().parallel).get(
        "https://api.geoapify.com/v1/geocode/search?country=$name&format=json&apiKey=$mapApiKey",
      );

      var data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        var firstResult = data['results'][0];

        // Extract latitude and longitude
        double latitude = firstResult['lat'];
        double longitude = firstResult['lon'];

        await EnvoyStorage().updateCountry(
            country.code, country.name, country.division,
            lat: latitude, lon: longitude);
      }
    }
  }
}
