// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/azteco_voucher.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class AztecoRedeemModal extends StatefulWidget {
  final AztecoVoucher voucher;
  final PageController controller;

  const AztecoRedeemModal(
      {super.key, required this.voucher, required this.controller});

  @override
  State<AztecoRedeemModal> createState() => _AztecoRedeemModalState();
}

class _AztecoRedeemModalState extends State<AztecoRedeemModal> {
  @override
  Widget build(BuildContext context) {
    var headingTextStyle =
        EnvoyTypography.heading.copyWith(color: EnvoyColors.textPrimary);

    var voucherCodeTextStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w900, fontSize: 12);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4 * 4, vertical: 4 * 4),
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8 * 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(4 * 4),
                child: Image.asset("assets/azteco_logo.png", scale: 1),
              ),
              Padding(
                padding: const EdgeInsets.all(4 * 4),
                child: Text(
                  S().azteco_redeem_modal_heading,
                  textAlign: TextAlign.center,
                  style: headingTextStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2 * 4),
                child: Text(
                  S().azteco_redeem_modal__voucher_code,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1 * 4),
                child: Text(
                  "${widget.voucher.code[0]} ${widget.voucher.code[1]} ${widget.voucher.code[2]} ${widget.voucher.code[3]}",
                  textAlign: TextAlign.center,
                  style: voucherCodeTextStyle,
                ),
              ),
              const Padding(padding: EdgeInsets.all(4)),
            ],
          ),
        ),
        Flexible(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8 * 4, vertical: 6 * 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                EnvoyButton(
                  S().component_back,
                  type: EnvoyButtonTypes.tertiary,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4 * 4),
                  child: EnvoyButton(
                    S().component_redeem,
                    type: EnvoyButtonTypes.primaryModal,
                    onTap: () {
                      widget.controller.nextPage(
                          duration: const Duration(microseconds: 100),
                          curve: Curves.linear);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
