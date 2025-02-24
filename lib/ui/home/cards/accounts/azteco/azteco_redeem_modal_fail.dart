// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/components/pop_up.dart';

class AztecoRedeemModalFail extends StatefulWidget {
  final PageController controller;

  const AztecoRedeemModalFail({super.key, required this.controller});

  @override
  State<AztecoRedeemModalFail> createState() => _AztecoRedeemModalFail();
}

class _AztecoRedeemModalFail extends State<AztecoRedeemModalFail> {
  @override
  Widget build(BuildContext context) {
    return EnvoyPopUp(
      title: S().azteco_redeem_modal_fail_heading,
      content: S().azteco_redeem_modal_fail_subheading,
      showCloseButton: true,
      primaryButtonLabel: S().component_continue,
      onPrimaryButtonTap: (context) {
        Navigator.of(context).pop();
      },
      icon: EnvoyIcons.alert,
      typeOfMessage: PopUpState.warning,
    );
  }
}
