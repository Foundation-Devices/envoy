// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/devices.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/devices/device_list_tile.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:envoy/ui/state/home_page_state.dart';

//ignore: must_be_immutable
class DeviceCard extends StatefulWidget with NavigationCard {
  final Device device;

  DeviceCard(this.device, {CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    modal = false;
    title = S().envoy_home_devices.toUpperCase();
    navigator = navigationCallback;
    optionsWidget = DeviceOptions(
      device,
      navigator: navigator,
    );
  }

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
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
    // ignore: unused_local_variable

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
        child: DeviceListTile(widget.device, onTap: () {
          widget.navigator!.pop();
        }),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 18.0, left: 35.0),
        child: Text(S().envoy_device_serial + ": " + widget.device.serial),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 35.0),
        child: Text(S().envoy_device_paired +
            " " +
            timeago.format(widget.device.datePaired)),
      ),
    ]);
  }
}

class DeviceOptions extends ConsumerWidget {
  final Device device;
  final CardNavigator? navigator;

  DeviceOptions(this.device, {this.navigator});

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
            "Edit device name".toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            ref.read(HomePageOptionsVisibilityProvider.notifier).state = false;
            bool isKeyboardShown = false;
            FocusNode focusNode = FocusNode();
            showEnvoyDialog(
                context: context,
                dialog: Builder(builder: (BuildContext context) {
                  var textEntry = TextEntry(
                    focusNode: focusNode,
                    maxLength: 20,
                    placeholder: device.name,
                  );
                  if (!isKeyboardShown) {
                    Future.delayed(Duration(milliseconds: 200)).then((value) {
                      FocusScope.of(context).requestFocus(focusNode);
                    });
                    isKeyboardShown = true;
                  }
                  return EnvoyDialog(
                    title: S().envoy_device_rename,
                    content: textEntry,
                    actions: [
                      EnvoyButton(
                        S().component_save.toUpperCase(),
                        onTap: () {
                          Devices().renameDevice(device, textEntry.enteredText);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                }));
          },
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(S().component_delete.toUpperCase(),
              style: TextStyle(color: EnvoyColors.lightCopper)),
          onTap: () {
            ref.read(HomePageOptionsVisibilityProvider.notifier).state = false;
            showEnvoyDialog(
                context: context,
                dialog: EnvoyDialog(
                  title: S().envoy_device_delete_are_you_sure(device.name),
                  content: Text(S().envoy_device_delete_explainer),
                  actions: [
                    EnvoyButton(
                      S().component_delete.toUpperCase(),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      onTap: () {
                        Devices().deleteDevice(device);
                        Navigator.pop(context);
                        navigator!.pop();
                      },
                    ),
                  ],
                ));
          },
        ),
      ],
    );
  }
}
