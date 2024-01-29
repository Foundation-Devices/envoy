// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';

class BtcPayRedeemModalSuccess extends StatefulWidget {
  const BtcPayRedeemModalSuccess({Key? key}) : super(key: key);

  @override
  State<BtcPayRedeemModalSuccess> createState() => _BtcPayRedeemModalSuccess();
}

class _BtcPayRedeemModalSuccess extends State<BtcPayRedeemModalSuccess> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 4 * 4, vertical: 4 * 4),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8 * 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                EnvoyIcon(
                  EnvoyIcons.info,
                  size: EnvoyIconSize.big,
                  color: EnvoyColors.accentPrimary,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5 * 4),
                  child: Text(
                    "Voucher Redeemed",
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.subheading,
                  ),
                ),
                Padding(padding: EdgeInsets.all(4)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7 * 4, vertical: 6 * 4),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2 * 4),
                  child: EnvoyButton(
                    S().component_continue,
                    type: EnvoyButtonTypes.primaryModal,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
