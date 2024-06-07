import 'dart:convert';
import 'dart:io';
import 'package:envoy/business/coordinates.dart';
import 'package:envoy/util/console.dart';
import 'package:http/http.dart' as http;

const String mapApiKey =
    String.fromEnvironment("MAP_API_KEY", defaultValue: '');

Future<Coordinates> getCoordinatesByGeoapify(
    String divisionName, String countryName) async {
  final response = await http.get(Uri.parse(
      'https://api.geoapify.com/v1/geocode/search?text=$divisionName&format=json&apiKey=$mapApiKey'));

  if (response.statusCode == 200) {
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
  }
  return Coordinates(0, 0); // Return (0,0) if coordinates not found
}

// Function to get coordinates by division name using OpenStreetMap (Nominatim)
Future<Coordinates> getCoordinatesByDivisionOpenStreetMap(
    String divisionName) async {
  final response = await http.get(Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&q=$divisionName'));

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data != null && data.isNotEmpty) {
      var result = data[0];
      double latitude = double.parse(result['lat']);
      double longitude = double.parse(result['lon']);
      return Coordinates(latitude, longitude);
    }
  }
  return Coordinates(0, 0); // Return (0,0) if coordinates not found
}

// Function to get coordinates by country name using OpenStreetMap (Nominatim)
Future<Coordinates> getCoordinatesByCountryOpenStreetMap(
    String countryName) async {
  final response = await http.get(Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&q=$countryName'));

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    if (data != null && data.isNotEmpty) {
      var result = data[0];
      double latitude = double.parse(result['lat']);
      double longitude = double.parse(result['lon']);
      return Coordinates(latitude, longitude);
    }
  }
  return Coordinates(0, 0); // Return (0,0) if coordinates not found
}

void main() async {
  const String inputFile = 'assets/iso-3166-2.json';
  const String outputFile = 'assets/divisions-with-coordinates.json';

  // Read the JSON file
  final jsonString = await File(inputFile).readAsString();
  final Map<String, dynamic> countries = jsonDecode(jsonString);

  // Prepare the result list
  final List<Map<String, dynamic>> result = [];

  int notFoundCount = 0;
  Map<String, Coordinates> lastKnownCoordinates = {};

  for (var countryCode in countries.keys) {
    var country = countries[countryCode];
    var countryName = country['name'];
    var divisions = country['divisions'];
    bool firstDivision = true;

    kPrint('Processing country: $countryName');

    for (var divisionCode in divisions.keys) {
      var divisionName = divisions[divisionCode];

      // Try Geoapify first
      var coordinates =
          await getCoordinatesByGeoapify(divisionName, countryName);

      // If Geoapify doesn't find coordinates, try OpenStreetMap by division name
      if (coordinates.lat == 0 && coordinates.lon == 0) {
        kPrint('Geoapify failed for $divisionName, trying OpenStreetMap...');
        coordinates = await getCoordinatesByDivisionOpenStreetMap(divisionName);
      }

      // If OpenStreetMap also doesn't find coordinates and it's the first division, search by country name
      if (coordinates.lat == 0 && coordinates.lon == 0) {
        if (firstDivision) {
          kPrint(
              'Coordinates not found for first division $divisionName, searching by country: $countryName');
          coordinates = await getCoordinatesByCountryOpenStreetMap(countryName);
        }
        if (coordinates.lat == 0 && coordinates.lon == 0) {
          notFoundCount++;
          if (lastKnownCoordinates.containsKey(countryName)) {
            coordinates = lastKnownCoordinates[countryName]!;
          }
        }
      } else {
        lastKnownCoordinates[countryName] = coordinates;
      }

      result.add({
        'division': divisionName,
        'coordinates': coordinates.toJson(),
      });

      firstDivision =
          false; // After processing the first division, set this to false
    }
  }

  // Write the result to a new JSON file
  final resultJson = jsonEncode(result);
  await File(outputFile).writeAsString(resultJson);

  kPrint('Coordinates added and saved to $outputFile');
  kPrint('Number of divisions that could not find coordinates: $notFoundCount');
}
