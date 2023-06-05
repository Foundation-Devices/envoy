// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/tl_navigation_card.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/empty_card.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/devices.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/ui/home/cards/indexed_transition_switcher.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/devices/device_card.dart';
import 'package:envoy/ui/home/cards/devices/device_list_tile.dart';
import 'package:envoy/ui/pages/legal/passport_tou.dart';

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
    title = S().envoy_home_devices.toUpperCase();
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
        ? EmptyCard(
            widget.addDevicesFunction,
            buttons: [
              EnvoyButton(S().envoy_devices_new_passport, onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return TouPage();
                }));
              }),
              EnvoyButton(
                S().envoy_devices_existing_passport,
                onTap: widget.addDevicesFunction,
                type: EnvoyButtonTypes.secondary,
              )
            ],
            helperText: EmptyCardHelperText(
                text: S().envoy_devices_no_devices,
                onTap: () {
                  launchUrl(
                      Uri.parse("https://foundationdevices.com/passport"));
                }),
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
