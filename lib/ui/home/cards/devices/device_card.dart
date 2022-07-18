// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/devices.dart';
import 'package:envoy/ui/home/cards/devices/device_list_tile.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:timeago/timeago.dart' as timeago;

//ignore: must_be_immutable
class DeviceCard extends StatefulWidget with NavigationCard {
  final Device device;

  DeviceCard(this.device, {CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    modal = false;
    title = "Devices".toUpperCase();
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
    final loc = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
        child: DeviceListTile(widget.device, onTap: () {
          widget.navigator!.pop();
        }),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 18.0, left: 35.0),
        child: Text("Serial: " + widget.device.serial),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 35.0),
        child: Text("Paired " + timeago.format(widget.device.datePaired)),
      ),
    ]);
  }
}

class DeviceOptions extends StatelessWidget {
  final Device device;
  final CardNavigator? navigator;

  DeviceOptions(this.device, {this.navigator});

  @override
  Widget build(BuildContext context) {
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
            navigator!.hideOptions();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                var textEntry = TextEntry(
                  placeholder: device.name,
                );
                return EnvoyDialog(
                  title: Text('Rename Device'),
                  content: textEntry,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel'.toUpperCase(),
                        style: TextStyle(color: EnvoyColors.darkCopper),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Devices().renameDevice(device, textEntry.enteredText);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Save'.toUpperCase(),
                        style: TextStyle(color: EnvoyColors.darkTeal),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text("Delete".toUpperCase(),
              style: TextStyle(color: EnvoyColors.lightCopper)),
          onTap: () {
            navigator!.hideOptions();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return EnvoyDialog(
                  title: Text("Are you sure you want to disconnect " +
                      device.name +
                      "?"),
                  content: Text(
                      "This will remove the device from Envoy alongside any connected accounts."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel'.toUpperCase(),
                        style: TextStyle(color: EnvoyColors.darkCopper),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Devices().deleteDevice(device);
                        Navigator.pop(context);
                        navigator!.pop();
                      },
                      child: Text(
                        'Delete'.toUpperCase(),
                        style: TextStyle(color: EnvoyColors.darkTeal),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
