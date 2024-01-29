// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/btcPay_voucher.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';

class BtcPayInfo extends StatelessWidget {
  final BtcPayVoucher voucher;
  final PageController controller;

  BtcPayInfo({
    Key? key,
    required this.voucher,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.small, vertical: EnvoySpacing.medium1),
      child: Column(children: [
        EnvoyIcon(
          EnvoyIcons.info,
          size: EnvoyIconSize.big,
          color: EnvoyColors.accentPrimary,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.medium1),
          child: Text(
            "Do you want recieve this voucher?",
            style: EnvoyTypography.heading,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.medium1),
          child: Text("Name: " + voucher.name, style: EnvoyTypography.info),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
          child: Text("Amount: " + voucher.amount! + " " + voucher.currency!,
              style: EnvoyTypography.body),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.medium1),
          child: EnvoyButton(
            label: "Redeem voucher",
            type: ButtonType.primary,
            state: ButtonState.default_state,
            onTap: () {
              controller.jumpToPage(2);
            },
          ),
        ),
        EnvoyButton(
          label: "Cancel",
          type: ButtonType.secondary,
          state: ButtonState.default_state,
          onTap: () {
            Navigator.of(context).pop();
          },
        )
      ]),
    );
  }
}
