// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:envoy/business/keys_manager.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:envoy/business/venue.dart';
import 'package:envoy/business/map_data.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/util/envoy_storage.dart';

import '../../business/coordinates.dart';

const String mapType = "positron";

class MarkersPage extends StatefulWidget {
  const MarkersPage({super.key});

  @override
  MarkersPageState createState() => MarkersPageState();
}

class MarkersPageState extends State<MarkersPage> {
  // Default location set to Montgomery, Alabama if the selected country cannot be found
  MapController controller = MapController(
      location:
          const LatLng(Angle.degree(32.361668), Angle.degree(-86.279167)));

  final List<Venue> venueMarkers = [];
  MapTransformer? localTransformer;
  bool areMapTilesLoaded = true;
  bool errorModalShown = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    goToHome();
    _showLocallyVenues();
    super.initState();
  }

  void _onDoubleTap(MapTransformer transformer, Offset position) {
    const delta = 0.5;
    final zoom = (controller.zoom + delta).clamp(2, 18).toDouble();

    transformer.setZoomInPlace(zoom, position);
    setState(() {});
  }

  void _zoomIn(MapTransformer transformer) {
    const delta = 0.5;
    final zoom = (controller.zoom + delta).clamp(2, 18).toDouble();
    final offset = transformer.toOffset(
        LatLng(controller.center.latitude, controller.center.longitude));
    transformer.setZoomInPlace(zoom, offset);
    setState(() {});
  }

  void _zoomOut(MapTransformer transformer) {
    const delta = 0.5;
    final zoom = (controller.zoom - delta).clamp(2, 18).toDouble();
    final offset = transformer.toOffset(
        LatLng(controller.center.latitude, controller.center.longitude));
    transformer.setZoomInPlace(zoom, offset);
    setState(() {});
  }

  Offset? _dragStart;
  double _scaleStart = 1.0;

  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  Future<Coordinates?> getCoordinatesFromJson(
      String countryCode, String divisionName) async {
    try {
      final String response =
          await rootBundle.loadString('assets/divisions-with-coordinates.json');
      final Map<String, dynamic> countries = jsonDecode(response);

      if (countries.containsKey(countryCode)) {
        var country = countries[countryCode];
        var divisions = country['divisions'];

        for (var division in divisions) {
          if (division['division'] == divisionName) {
            double lat = division['coordinates']['lat'];
            double lon = division['coordinates']['lon'];
            return Coordinates(lat, lon);
          }
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
      if (country?.division != null && country?.code != null) {
        var coordinates =
            await getCoordinatesFromJson(country!.code, country.division);
        if (coordinates != null &&
            coordinates.lat != null &&
            coordinates.lon != null) {
          goTo(coordinates.lat!, coordinates.lon!);
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

  void goTo(double latitude, double longitude) {
    setState(() {
      controller = MapController(
        location: LatLng(Angle.degree(latitude), Angle.degree(longitude)),
      );
      _dataLoaded = true;
    });
  }

  void _showLocallyVenues() {
    var center = controller.center;
    double longitude = center.longitude.degrees;
    double latitude = center.latitude.degrees;
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

  void _onScaleUpdate(ScaleUpdateDetails details, MapTransformer transformer) {
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      controller.zoom += 0.02;
      setState(() {});
    } else if (scaleDiff < 0) {
      controller.zoom -= 0.02;
      setState(() {});
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _dragStart = now;
      transformer.drag(diff.dx, diff.dy);
      setState(() {});
    }
  }

  String _getTileUrl(int z, int x, int y) {
    final mapApiKey = KeysManager().keys?.mapsKey;
    if (mapApiKey == null) {
      return "";
    }

    return "https://maps.geoapify.com/v1/tile/$mapType/$z/$x/$y.png?&apiKey=$mapApiKey";
  }

  Widget _buildVenueMarkerWidget(
    Venue venue,
    MapTransformer transformer,
  ) {
    var pos = transformer.toOffset(LatLng.degree(venue.lat, venue.lon));
    return Positioned(
      left: pos.dx - 24,
      top: pos.dy - 24,
      width: 48,
      height: 48,
      child: GestureDetector(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EnvoyIcon(
              EnvoyIcons.location,
              color: EnvoyColors.copper500,
            ),
            CustomPaint(
              size: const Size(EnvoySpacing.medium2, EnvoySpacing.small),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _showLocallyVenues();
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
            body: MapLayout(
              controller: controller,
              builder: (context, transformer) {
                final markerVenueWidgets = [];
                localTransformer = transformer;
                for (var venue in venueMarkers) {
                  var venueMarker = _buildVenueMarkerWidget(venue, transformer);
                  markerVenueWidgets.add(venueMarker);
                }
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTapDown: (details) => _onDoubleTap(
                    transformer,
                    details.localPosition,
                  ),
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: (details) =>
                      _onScaleUpdate(details, transformer),
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerSignal: (event) {
                      if (event is PointerScrollEvent) {
                        final delta = event.scrollDelta.dy / -1000.0;
                        final zoom =
                            (controller.zoom + delta).clamp(2, 18).toDouble();

                        transformer.setZoomInPlace(zoom, event.localPosition);
                        setState(() {});
                      }
                    },
                    child: Stack(
                      children: [
                        TileLayer(
                          builder: (context, x, y, z) {
                            final tilesInZoom = pow(2.0, z).floor();
                            while (x < 0) {
                              x += tilesInZoom;
                            }
                            while (y < 0) {
                              y += tilesInZoom;
                            }
                            x %= tilesInZoom;
                            y %= tilesInZoom;
                            return CachedNetworkImage(
                              imageUrl: _getTileUrl(z, x, y),
                              fit: BoxFit.cover,
                              errorListener: (e) {
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
                                      title: S()
                                          .buy_bitcoin_mapLoadingError_header,
                                      secondaryButtonLabel: S().component_retry,
                                      onSecondaryButtonTap:
                                          (BuildContext context) {
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
                              errorWidget: (context, url, error) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const EnvoyIcon(
                                      EnvoyIcons.alert,
                                      color: Colors.red,
                                    ),
                                    Text(
                                      S().buy_bitcoin_mapLoadingError_header,
                                      style: EnvoyTypography.explainer
                                          .copyWith(color: Colors.red),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        if (areMapTilesLoaded) ...markerVenueWidgets,
                      ],
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.medium2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MapButton(
                      icon: EnvoyIcons.plus,
                      onTap: () {
                        _zoomIn(localTransformer!);
                      }),
                  const SizedBox(height: EnvoySpacing.small),
                  MapButton(
                      icon: EnvoyIcons.minus,
                      onTap: () {
                        _zoomOut(localTransformer!);
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

    Path path = Path();
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
