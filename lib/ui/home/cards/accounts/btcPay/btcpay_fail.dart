// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/btcPay_voucher.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/business/locale.dart';
import 'package:envoy/generated/l10n.dart';

class BtcPayFail extends StatelessWidget {
  BtcPayFail({Key? key, required this.voucher}) : super(key: key);
  final BtcPayVoucher voucher;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: EnvoySpacing.medium3),
              child: EnvoyIcon(EnvoyIcons.alert,
                  size: EnvoyIconSize.big, color: EnvoyColors.danger),
            ),
            getMainErrorMessage(
                voucher.errorType, voucher.expiresAt, voucher.link),
            Padding(
              padding: const EdgeInsets.only(top: EnvoySpacing.medium3),
              child: EnvoyButton(
                S().component_continue,
                type: EnvoyButtonTypes.primaryModal,
                borderRadius: BorderRadius.circular(EnvoySpacing.small),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget getMainErrorMessage(
    BtcPayVoucherErrorType errorType, DateTime? dateTime, String link) {
  switch (errorType) {
    case BtcPayVoucherErrorType.invalid:
      return errorMesage(
        S().azteco_connection_modal_fail_heading,
        S().btcpay_connection_modal_fail_subheading,
      );

    case BtcPayVoucherErrorType.expired:
      return errorMesage(
          S().btcpay_connection_modal_fail_heading,
          S().btcpay_connection_modal_expired_subheading(
              DateFormat.yMd(currentLocale)
                  .format(dateTime ?? DateTime.now())));

    case BtcPayVoucherErrorType.onChain:
      return errorMesage(S().azteco_redeem_modal_fail_heading,
          S().btcpay_connection_modal_onchainOnly_subheading,
          link: link);
  }
}

Column errorMesage(String title, String subheading, {String? link}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: EnvoyTypography.subheading,
        textAlign: TextAlign.center,
      ),
      Padding(
        padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
        child: Text(
          subheading,
          style: EnvoyTypography.info,
          textAlign: TextAlign.center,
        ),
      ),
      if (link != null)
        Padding(
          padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
          child: GestureDetector(
              onTap: () {
                launchUrl(Uri.parse(link));
              },
              child: Text(
                S().component_learnMore,
                style: EnvoyTypography.button
                    .copyWith(color: EnvoyColors.accentPrimary),
              )),
        ),
    ],
  );
}
