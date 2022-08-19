// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';

//ignore: must_be_immutable
class RenameDeviceCard extends StatefulWidget with NavigationCard {
  final Device device;

  RenameDeviceCard(this.device, {CardNavigator? navigationCallback}) {
    optionsWidget = null;
    modal = true;
    title = S().envoy_home_devices.toUpperCase();
    navigator = navigationCallback;
  }

  @override
  State<RenameDeviceCard> createState() => _RenameDeviceCardState();
}

class _RenameDeviceCardState extends State<RenameDeviceCard> {
  String _actionButtonText = "Confirm";

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    var textEntry = TextEntry(
      placeholder: widget.device.name,
    );

    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10),
            child: Text(
              "Edit device name".toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: textEntry,
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.all(50.0),
        child: EnvoyTextButton(
            onTap: () {
              widget.device.name = textEntry.enteredText;
              Devices().storeDevices();
              widget.navigator!.pop();
            },
            label: _actionButtonText),
      )
    ]);
  }
}
