// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/btcpay_voucher.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:envoy/business/locale.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';

class BtcPayFail extends StatelessWidget {
  const BtcPayFail({super.key, required this.voucher});

  final BtcPayVoucher voucher;

  @override
  Widget build(BuildContext context) {
    return EnvoyPopUp(
      icon: EnvoyIcons.alert,
      title: getTitle(voucher.errorType),
      content: getErrorContent(voucher.errorType, voucher.expiresAt),
      linkUrl: voucher.errorType == BtcPayVoucherErrorType.onChain
          ? voucher.link
          : null,
      primaryButtonLabel: S().component_continue,
      onPrimaryButtonTap: (context) {
        Navigator.of(context).pop();
      },
      typeOfMessage: PopUpState.danger,
    );
  }
}

String getTitle(BtcPayVoucherErrorType errorType) {
  switch (errorType) {
    case BtcPayVoucherErrorType.invalid:
      return S().azteco_connection_modal_fail_heading;
    case BtcPayVoucherErrorType.expired:
      return S().btcpay_connection_modal_fail_heading;
    case BtcPayVoucherErrorType.onChain:
      return S().azteco_redeem_modal_fail_heading;
    case BtcPayVoucherErrorType.wrongNetwork:
      return S().btcpay_redeem_modal_wrongNetwork_heading;
  }
}

String getErrorContent(BtcPayVoucherErrorType errorType, DateTime? dateTime) {
  switch (errorType) {
    case BtcPayVoucherErrorType.invalid:
      return S().btcpay_connection_modal_fail_subheading;
    case BtcPayVoucherErrorType.expired:
      return S().btcpay_connection_modal_expired_subheading(
          DateFormat.yMd(currentLocale).format(dateTime ?? DateTime.now()));
    case BtcPayVoucherErrorType.onChain:
      return S().btcpay_connection_modal_onchainOnly_subheading;
    case BtcPayVoucherErrorType.wrongNetwork:
      return S().btcpay_redeem_modal_wrongNetwork_subheading;
  }
}
