// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:envoy/business/keys_manager.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:envoy/business/venue.dart';
import 'package:envoy/business/map_data.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart' as material;
import 'package:envoy/business/coordinates.dart';

// import 'package:vector_map_tiles/vector_map_tiles.dart' as vector;
// import 'package:path/path.dart' as path;

const String mapType = "positron";

class MarkersPage extends StatefulWidget {
  const MarkersPage({super.key});

  @override
  MarkersPageState createState() => MarkersPageState();
}

class MarkersPageState extends State<MarkersPage> {
  double currentZoom = 13.0;
  MapController mapController = MapController();
  LatLng currentCenter = const LatLng(32.361668, -86.279167);

  final List<Venue> venueMarkers = [];

  bool areMapTilesLoaded = true;
  bool errorModalShown = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    goToHome();
    super.initState();
  }

  void _zoomIn() {
    currentZoom = currentZoom + 1;
    mapController.move(mapController.camera.center, currentZoom);
    setState(() {});
  }

  void _zoomOut() {
    currentZoom = currentZoom - 1;
    mapController.move(mapController.camera.center, currentZoom);
    setState(() {});
  }

  Future<Coordinates?> getCoordinatesFromJson(String divisionName) async {
    try {
      final String response =
          await rootBundle.loadString('assets/divisions-with-coordinates.json');
      final List<dynamic> divisions = jsonDecode(response);

      for (var division in divisions) {
        if (division['division'] == divisionName) {
          double lat = division['coordinates']['lat'];
          double lon = division['coordinates']['lon'];
          return Coordinates(lat, lon);
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> goToHome() async {
    try {
      var country = await EnvoyStorage().getCountry();
      if (country?.division != null) {
        var coordinates = await getCoordinatesFromJson(country!.division);
        if (coordinates != null &&
            coordinates.lat != null &&
            coordinates.lon != null) {
          currentCenter = LatLng(coordinates.lat!, coordinates.lon!);
          setState(() {
            _dataLoaded = true;
          });
          return;
        }
      }
    } on TimeoutException catch (_) {
      setState(() {
        _dataLoaded = true;
      });
    } catch (_) {
      setState(() {
        _dataLoaded = true;
      });
      return;
    }

    setState(() {
      _dataLoaded = true;
    });
  }

  void _showLocallyVenues() {
    var center = mapController.camera.center;
    double longitude = center.longitude;
    double latitude = center.latitude;
    List<Venue> locallyVenues =
        MapData().getLocallyVenues(0.25, longitude, latitude);
    if (locallyVenues.isNotEmpty) {
      setState(() {
        for (Venue venue in locallyVenues) {
          // Check if the venue ID already exists in venueMarkers
          bool alreadyExists =
              venueMarkers.any((marker) => marker.id == venue.id);
          if (!alreadyExists) {
            venueMarkers.add(venue);
          }
        }
      });
    }
  }

  String _getTileUrl() {
    final mapApiKey = KeysManager().keys?.mapsKey;
    if (mapApiKey == null) {
      return "";
    }

    return "https://maps.geoapify.com/v1/tile/$mapType/{z}/{x}/{y}.png?&apiKey=$mapApiKey";
  }

  Widget _buildVenueMarkerWidget(
    Venue venue,
  ) {
    return GestureDetector(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const EnvoyIcon(
            EnvoyIcons.location,
            color: EnvoyColors.copper500,
          ),
          CustomPaint(
            size: const Size(EnvoySpacing.medium2, 6),
            painter: TriangleShadow(),
          )
        ],
      ),
      onTap: () async {
        if (mounted) {
          showEnvoyDialog(
            context: context,
            blurColor: Colors.black,
            linearGradient: true,
            dialog: const Padding(
              padding: EdgeInsets.all(EnvoySpacing.medium3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(), // Loading spinner
                ],
              ),
            ),
          );
        }
        try {
          final response = await MapData().getVenueInfo(venue.id);
          final data = json.decode(response.body);
          final venueInfo = data["venue"];
          String? name = venueInfo["name"];
          final String? description = venueInfo["description"];
          final String? openingHours = venueInfo["opening_hours"];
          final String? website = venueInfo["website"];
          final String? street = venueInfo["street"];
          final String? houseNo = venueInfo["houseno"];
          final String? city = venueInfo["city"];
          String? address;

          if (street != null || houseNo != null || city != null) {
            final String houseNoAndStreet = [
              if (street != null && street.isNotEmpty) street,
              if (houseNo != null && houseNo.isNotEmpty) houseNo
            ].join(' ');

            address = [
              if (houseNoAndStreet.isNotEmpty) houseNoAndStreet,
              if (city != null && city.isNotEmpty) city
            ].join(', ');
          }
          if (mounted) {
            Navigator.pop(context);
            showEnvoyDialog(
              context: context,
              blurColor: Colors.black,
              linearGradient: true,
              dialog: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: AtmDialogInfo(
                  name: name,
                  address: address,
                  website: website,
                  description: description,
                  openingHours: openingHours,
                ),
              ),
            );
          }
        } catch (error) {
          if (mounted) Navigator.pop(context);
        }
      },
    );
  }

  List<Marker> showLocalMarkers() {
    List<Marker> localMarkers = [];

    for (Venue venue in venueMarkers) {
      localMarkers.add(
        Marker(
          point: LatLng(venue.lat, venue.lon),
          child: _buildVenueMarkerWidget(venue),
        ),
      );
    }

    return localMarkers;
  }

  @override
  Widget build(BuildContext context) {
    return _dataLoaded
        ? Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(
                      right: EnvoySpacing.medium2, top: EnvoySpacing.medium2),
                  child: MapButton(
                      icon: EnvoyIcons.close,
                      onTap: () {
                        Navigator.of(context).pop();
                      }),
                ),
              ],
            ),
            body: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                      initialCenter: currentCenter,
                      onMapReady: () {
                        _showLocallyVenues();
                      },
                      onMapEvent: (mapEvent) {
                        if (mapEvent is MapEventMove) {
                          _showLocallyVenues();
                        }
                      }),
                  children: [
                    TileLayer(
                      urlTemplate: _getTileUrl(),
                      userAgentPackageName: 'Foundation Envoy',
                      errorTileCallback: (tile, error, stackTrace) {
                        setState(() {
                          areMapTilesLoaded = false;
                        });
                        if (!errorModalShown) {
                          showEnvoyPopUp(
                              context,
                              S().buy_bitcoin_mapLoadingError_subheader,
                              S().component_ok,
                              (BuildContext context) {
                                Navigator.pop(context);
                              },
                              icon: EnvoyIcons.alert,
                              typeOfMessage: PopUpState.danger,
                              title: S().buy_bitcoin_mapLoadingError_header,
                              secondaryButtonLabel: S().component_retry,
                              onSecondaryButtonTap: (BuildContext context) {
                                Navigator.pop(context);
                                setState(() {
                                  // trigger build
                                });
                              },
                              onCheckBoxChanged: (_) {});

                          setState(() {
                            errorModalShown = true;
                          });
                        }
                      },
                    ),
                    MarkerLayer(markers: showLocalMarkers()),
                    // if(!areMapTilesLoaded)
                    //   path.VectorTileLayer(tileProviders: tileProviders, theme:style.theme)
                  ],
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.medium2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MapButton(
                      icon: EnvoyIcons.plus,
                      onTap: () {
                        _zoomIn();
                      }),
                  const SizedBox(height: EnvoySpacing.small),
                  MapButton(
                      icon: EnvoyIcons.minus,
                      onTap: () {
                        _zoomOut();
                      }),
                ],
              ),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

class AtmDialogInfo extends StatelessWidget {
  const AtmDialogInfo({
    super.key,
    this.name,
    this.address,
    this.website,
    this.description,
    this.openingHours,
  });

  final String? name;
  final String? address;
  final String? website;
  final String? description;
  final String? openingHours;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EnvoySpacing.medium2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              child: const EnvoyIcon(EnvoyIcons.close),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: EnvoySpacing.medium2),
            child: EnvoyIcon(
              EnvoyIcons.location,
              size: EnvoyIconSize.big,
            ),
          ),
          Text(
            name ?? "No name info",
            textAlign: TextAlign.center,
            style: EnvoyTypography.subheading,
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
              child: Text(
                description!,
                textAlign: TextAlign.center,
                style: EnvoyTypography.info,
              ),
            ),
          if (address != null)
            Padding(
              padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
              child: Text(address!, textAlign: TextAlign.center),
            ),
          if (openingHours != null)
            Padding(
              padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
              child: Text(
                  "${S().buy_bitcoin_buyOptions_atms_map_modal_openingHours}\n $openingHours",
                  textAlign: TextAlign.center),
            ),
          if (website != null)
            Padding(
              padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
              child: GestureDetector(
                child: Text(
                  website!,
                  textAlign: TextAlign.center,
                  style: EnvoyTypography.button
                      .copyWith(color: EnvoyColors.accentPrimary),
                ),
                onTap: () {
                  launchUrl(Uri.parse(website!));
                },
              ),
            ),
          if (address == null && description == null && website == null)
            const Text("No extra details available for this atm."),
        ],
      ),
    );
  }
}

class MapButton extends StatelessWidget {
  final EnvoyIcons icon;
  final Function onTap;

  const MapButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double diameter = 40.0;
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: diameter,
        height: diameter,
        decoration: const BoxDecoration(
          color: EnvoyColors.solidWhite,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: EnvoyIcon(
            icon,
            size: EnvoyIconSize.big,
            color: EnvoyColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class TriangleShadow extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        focalRadius: 0.5,
        radius: 0.8,
        stops: const [0.0, 0.9],
        // Ensure stops are correct for smooth transition
        colors: [
          EnvoyColors.border1.withOpacity(0.7), // Adjust colors as needed
          Colors.transparent
        ],
      ).createShader(Rect.fromLTWH(-0.3, -1.9, size.width, size.height));

    material.Path path = material.Path();
    path.moveTo(size.width / 2, size.height); // Bottom point
    path.lineTo(size.width, 0); // Top-right point
    path.lineTo(0, 0); // Top-left point
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
