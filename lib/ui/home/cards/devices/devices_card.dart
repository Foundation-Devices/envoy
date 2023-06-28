// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:envoy/ui/home/cards/tl_navigation_card.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/devices.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/ui/home/cards/indexed_transition_switcher.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/devices/device_card.dart';
import 'package:envoy/ui/home/cards/devices/device_list_tile.dart';
import 'package:envoy/ui/pages/legal/passport_tou.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:envoy/ui/embedded_video.dart';

//ignore: must_be_immutable
class DevicesCard extends StatefulWidget with TopLevelNavigationCard {
  DevicesCard({
    Key? key,
  }) : super(key: key);

  @override
  TopLevelNavigationCardState<TopLevelNavigationCard> createState() {
    var state = DevicesCardState();
    tlCardState = state;
    return state;
  }
}

// The mixin is necessary to maintain state when widgets is not visible
// Unfortunately it seems to only work with TabView
class DevicesCardState extends State<DevicesCard>
    with AutomaticKeepAliveClientMixin, TopLevelNavigationCardState {
  void _showAddDevicePage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return SingleImportPpIntroPage();
    }));
  }

  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Redraw when we there are changes in devices
    Devices().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();
    Devices().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // ignore: unused_local_variable

    final navigator = CardNavigator(push, pop, hideOptions);

    if (cardStack.isEmpty) {
      navigator
          .push(DevicesList(navigator, addDevicesFunction: _showAddDevicePage));
    }

    return IndexedTransitionSwitcher(
      children: cardStack,
      index: cardStack.length - 1,
      transitionBuilder: (
        Widget child,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
      ) {
        return FadeThroughTransition(
          animation: primaryAnimation,
          fillColor: Colors.transparent,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => false;
}

//ignore: must_be_immutable
class DevicesList extends StatefulWidget with NavigationCard {
  final Function() addDevicesFunction;

  DevicesList(CardNavigator? navigationCallback,
      {required this.addDevicesFunction})
      : super(key: UniqueKey()) {
    modal = false;
    title = S().devices_heading.toUpperCase();
    navigator = navigationCallback;
    optionsWidget = DevicesOptions(
      navigator: navigator,
    );
  }

  @override
  State<DevicesList> createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {
  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Redraw when we there are changes in devices
    Devices().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();
    Devices().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    return Devices().devices.isEmpty
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GhostDevice(),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: Devices().devices.length,
              itemBuilder: (BuildContext context, int index) {
                var device = Devices().devices[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: DeviceListTile(
                    device,
                    onTap: () {
                      widget.navigator!.push(DeviceCard(device,
                          navigationCallback: widget.navigator));
                    },
                  ),
                );
              },
            ),
          );
  }
}

class DevicesOptions extends ConsumerWidget {
  final CardNavigator? navigator;

  DevicesOptions({this.navigator});

  @override
  Widget build(context, ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Divider(),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(
            S().envoy_devices_options_existing_passport.toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return SingleImportPpIntroPage();
            }));
          },
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(S().envoy_devices_options_new_passport.toUpperCase(),
              style: TextStyle(color: EnvoyColors.lightCopper)),
          onTap: () {
            ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return TouPage();
            }));
          },
        ),
      ],
    );
  }
}

class GhostDevice extends StatelessWidget {
  GhostDevice({
    Key? key,
  }) : super(key: key);

  final device = Device("Primary", DeviceType.passportGen12, "serial",
      DateTime.now(), "2.1.1", Colors.grey);

  @override
  Widget build(BuildContext context) {
    TextStyle _explainerTextStyle = TextStyle(
        fontFamily: 'Montserrat',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        color: EnvoyColors.grey);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Color.fromRGBO(255, 255, 255, 0.75),
              BlendMode.hardLight,
            ),
            child: DeviceListTile(
              device,
              onTap: () {},
              ghostDevice: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S().devices_empty_text_explainer,
                style: _explainerTextStyle,
              ),
              SizedBox(width: 10),
              GestureDetector(
                child: Text(
                  S().devices_empty_learn_more,
                  style: _explainerTextStyle.copyWith(
                    color: EnvoyColors.teal,
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: DeviceEmptyVideo());
                    },
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}

class DeviceEmptyVideo extends StatelessWidget {
  DeviceEmptyVideo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle _ctaTextStyle = TextStyle(
        color: Colors.white,
        fontFamily: 'Montserrat',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        fontSize: 14);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.black,
        Color(0x00000000),
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Column(children: [
        Container(
          height: 100,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    S().devices_empty_modal_video_header,
                    style: _ctaTextStyle.copyWith(
                        fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.white,
                    blurRadius: 10,
                    offset: Offset(0, 0),
                    spreadRadius: 1),
              ],
            ),
            child: EmbeddedVideo(
              path: "assets/videos/passport_ad.m4v",
              aspectRatio: 16 / 9,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Text(S().devices_empty_modal_video_cta2,
                    style: _ctaTextStyle),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              GestureDetector(
                child: Text(
                  S().devices_empty_modal_video_cta1,
                  style: _ctaTextStyle.copyWith(color: EnvoyColors.teal),
                ),
                onTap: () {
                  launchUrlString("https://foundationdevices.com/passport/");
                },
              ),
            ],
          ),
        )
      ]),
    );
  }
}
