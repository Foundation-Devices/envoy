// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:math';
import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http_tor/http_tor.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/feed_manager.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/business/venue.dart';

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

  void _gotoDefault() {
    controller.center = home;
    setState(() {});
  }

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
        FeedManager().getLocallyVenues(0.25, longitude, latitude);
    if (locallyVenues.isNotEmpty) {
      setState(() {
        venueMarkers.addAll(locallyVenues);
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

  Widget _buildVenueMarkerWidget(Venue venue, MapTransformer transformer,
      [IconData icon = Icons.location_pin]) {
    var pos = transformer.toOffset(LatLng.degree(venue.lat, venue.lon));

    return Positioned(
      left: pos.dx - 24,
      top: pos.dy - 24,
      width: 48,
      height: 48,
      child: GestureDetector(
        child: Icon(
          icon,
          color: Colors.redAccent,
          size: 48,
        ),
        onTap: () async {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(), // Loading spinner
                    SizedBox(height: 10),
                    Text('Loading...'),
                  ],
                ),
              ),
            );
          }

          try {
            final response =
                await HttpTor(Tor.instance, EnvoyScheduler().parallel).get(
              "https://coinmap.org/api/v1/venues/${venue.id}",
            );
            final data = json.decode(response.body);
            final venueInfo = data["venue"];
            String? name = venueInfo["name"];
            final String? email = venueInfo["email"];
            final String? description = venueInfo["description"];
            final String? phone = venueInfo["phone"];
            if (mounted) {
              Navigator.pop(context);

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name ?? "No name info",
                        textAlign: TextAlign.center,
                      ),
                      if (phone != null)
                        Text('Phone: $phone', textAlign: TextAlign.center),
                      if (email != null)
                        Text('Email: $email', textAlign: TextAlign.center),
                      if (description != null)
                        Text(
                          description,
                          textAlign: TextAlign.center,
                        ),
                      if (phone == null && description == null && email == null)
                        const Text("No extra details available for this atm."),
                    ],
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
    //_showLocallyVenues(); if want constantly refresh map
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitcoin Atm'),
        backgroundColor: Colors.teal,
      ),
      body: MapLayout(
        controller: controller,
        builder: (context, transformer) {
          final markerVenueWidgets = [];
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
                        imageUrl: openStreetMap(z, x, y),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "myLOCATION",
            onPressed: _gotoDefault,
            tooltip: 'My Location',
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "search",
            onPressed: _showLocallyVenues,
            tooltip: 'Search',
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}

String openStreetMap(int z, int x, int y) {
  final url = "https://tile.openstreetmap.org/$z/$x/$y.png";
  return url;
}
