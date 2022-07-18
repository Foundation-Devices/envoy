// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/business/devices.dart';

//ignore: must_be_immutable
class DeleteDeviceCard extends StatefulWidget with NavigationCard {
  final Device device;

  DeleteDeviceCard(this.device, {CardNavigator? navigationCallback}) {
    optionsWidget = null;
    modal = true;
    title = "Devices".toUpperCase();
    navigator = navigationCallback;
  }

  @override
  State<DeleteDeviceCard> createState() => _DeleteDeviceCardState();
}

class _DeleteDeviceCardState extends State<DeleteDeviceCard> {
  String _actionButtonText = "Confirm";

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final loc = AppLocalizations.of(context)!;

    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.all(50),
        child: Text(
          "Are you sure you wish to delete " +
              widget.device.name +
              "?\n\nThis will remove the device from Envoy but the related accounts will still be available.",
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(50.0),
        child: EnvoyTextButton(onTap: () {}, label: _actionButtonText),
      )
    ]);
  }
}
