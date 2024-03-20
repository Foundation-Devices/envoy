// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:envoy/business/venue.dart';
import 'package:envoy/business/map_data.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/generated/l10n.dart';

String mapApiKey = Platform.environment['MAP_API_KEY'] ?? "";
const String mapType = "positron";

const home = LatLng(Angle.degree(34.052235), Angle.degree(-118.243683));

class MarkersPage extends StatefulWidget {
  const MarkersPage({super.key});

  @override
  MarkersPageState createState() => MarkersPageState();
}

class MarkersPageState extends State<MarkersPage> {
  final controller = MapController(
    location: home,
  );

  final List<Venue> venueMarkers = [];
  MapTransformer? localTransformer;

  @override
  void initState() {
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

  String _openStreetMap(int z, int x, int y) {
    final url =
        "https://maps.geoapify.com/v1/tile/$mapType/$z/$x/$y.png?&apiKey=$mapApiKey";
    return url;
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
                    street: street,
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
    return Scaffold(
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
            onScaleUpdate: (details) => _onScaleUpdate(details, transformer),
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
                        imageUrl: _openStreetMap(z, x, y),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  ...markerVenueWidgets,
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
    );
  }
}

class AtmDialogInfo extends StatelessWidget {
  const AtmDialogInfo({
    super.key,
    this.name,
    this.street,
    this.website,
    this.description,
    this.openingHours,
  });

  final String? name;
  final String? street;
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
          if (street != null)
            Padding(
              padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
              child: Text(street!, textAlign: TextAlign.center),
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
          if (street == null && description == null && website == null)
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
      ..shader = const RadialGradient(
        center: Alignment.topCenter,
        focalRadius: 0.5,
        radius: 0.8,
        stops: [0.0, 0.9],
        colors: [Colors.grey, Colors.transparent], // Adjust colors as needed
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

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
