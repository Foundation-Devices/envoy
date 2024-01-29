// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/btcPay_voucher.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';

class BtcPayFail extends StatelessWidget {
  BtcPayFail({Key? key, required this.voucher}) : super(key: key);
  final BtcPayVoucher voucher;

  @override
  Widget build(BuildContext context) {
    print("err");
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
                EnvoyIcon(EnvoyIcons.alert,
                    size: EnvoyIconSize.big, color: EnvoyColors.danger),
                Padding(
                  padding: const EdgeInsets.only(top: 5 * 4),
                  child: Text(
                    "Can not reedem voucher",
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.subheading,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5 * 4),
                  child: Text(
                    voucher.errorMessage ?? "Pull payment not found",
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.info
                        .copyWith(color: EnvoyColors.danger),
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
                    "Close",
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
