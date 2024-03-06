// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/btcpay_voucher.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/generated/l10n.dart';

class BtcPayInfo extends StatelessWidget {
  final BtcPayVoucher voucher;
  final PageController controller;
  final Account account;

  const BtcPayInfo({
    super.key,
    required this.voucher,
    required this.controller,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EnvoySpacing.medium2),
      child: Column(children: [
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
          child: Image.asset(
            "assets/BTCPayLogo.png",
            height: EnvoySpacing.xl,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
          child: Text(
            S().azteco_redeem_modal_heading,
            style: EnvoyTypography.subheading,
            textAlign: TextAlign.center,
          ),
        ),
        if (voucher.amountSats != null)
          EnvoyAmount(
              amountSats: voucher.amountSats!,
              amountWidgetStyle: AmountWidgetStyle.normal,
              account: account),
        if (voucher.amountSats ==
            null) // TODO: what if amount is in strange currency
          Text("${voucher.amount!} ${voucher.currency!}",
              style: EnvoyTypography.body),
        if (voucher.name != "")
          Padding(
            padding: const EdgeInsets.only(
                top: EnvoySpacing.small, bottom: EnvoySpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S().btcpay_redeem_modal_name,
                  style: EnvoyTypography.info,
                ),
                Text(
                  voucher.name,
                  style: EnvoyTypography.label,
                ),
              ],
            ),
          ),
        if (voucher.description != "")
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S().btcpay_redeem_modal_description,
                style: EnvoyTypography.info,
              ),
              Text(
                voucher.description,
                style: EnvoyTypography.label,
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.only(top: EnvoySpacing.medium3),
          child: EnvoyButton(
            label: S().component_back,
            type: ButtonType.secondary,
            state: ButtonState.default_state,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
          child: EnvoyButton(
            label: S().component_redeem,
            type: ButtonType.primary,
            state: ButtonState.default_state,
            onTap: () {
              controller.jumpToPage(2);
            },
          ),
        ),
      ]),
    );
  }
}
