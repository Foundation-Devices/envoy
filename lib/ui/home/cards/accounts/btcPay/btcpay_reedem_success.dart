// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';

class BtcPayRedeemModalSuccess extends StatefulWidget {
  const BtcPayRedeemModalSuccess({super.key});

  @override
  State<BtcPayRedeemModalSuccess> createState() => _BtcPayRedeemModalSuccess();
}

class _BtcPayRedeemModalSuccess extends State<BtcPayRedeemModalSuccess> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EnvoySpacing.medium2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.medium3),
            child: Image.asset("assets/trophy_icon.png",
                scale: 1.0, width: 128, height: 128, fit: BoxFit.contain),
          ),
          Text(
            S().azteco_redeem_modal_success_heading,
            textAlign: TextAlign.center,
            style: EnvoyTypography.subheading,
          ),
          Padding(
            padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
            child: Text(
              S().azteco_redeem_modal_success_subheading,
              textAlign: TextAlign.center,
              style: EnvoyTypography.info,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: EnvoySpacing.medium3),
                child: EnvoyButton(
                  S().component_continue,
                  borderRadius: BorderRadius.circular(EnvoySpacing.small),
                  type: EnvoyButtonTypes.primaryModal,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
