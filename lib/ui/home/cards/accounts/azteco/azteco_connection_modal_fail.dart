// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/components/pop_up.dart';

class AztecoConnectionModalFail extends StatefulWidget {
  final PageController controller;

  const AztecoConnectionModalFail({super.key, required this.controller});

  @override
  State<AztecoConnectionModalFail> createState() => _AztecoRedeemModalFail();
}

class _AztecoRedeemModalFail extends State<AztecoConnectionModalFail> {
  @override
  Widget build(BuildContext context) {
    return EnvoyPopUp(
      title: "Unable to Connect", // TODO: FIGMA
      content:
          "Envoy is unable to connect with Azteco. Please contact support@azte.co or try again later.", // TODO: FIGMA
      showCloseButton: true,
      primaryButtonLabel: "Continue", // TODO: FIGMA
      onPrimaryButtonTap: (context) {
        Navigator.of(context).pop();
      },
      icon: EnvoyIcons.alert,
      typeOfMessage: PopUpState.warning,
    );
  }
}
