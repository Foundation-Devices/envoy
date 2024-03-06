// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/btcpay_voucher.dart';
import 'package:envoy/ui/home/cards/accounts/btcPay/btcpay_info.dart';
import 'package:envoy/ui/home/cards/accounts/btcPay/btcpay_fail.dart';
import 'package:envoy/ui/home/cards/accounts/btcPay/btcpay_loading_payout.dart';
import 'package:envoy/ui/home/cards/accounts/btcPay/btcpay_reedem_success.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/widgets/expandable_page_view.dart';
import 'package:envoy/ui/home/cards/accounts/btcPay/btcpay_loading.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';

class BtcPayDialog extends StatelessWidget {
  final BtcPayVoucher voucher;
  final Account account;

  BtcPayDialog(this.voucher, this.account);

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20.0), // change the value as per your need
      ),
      child: ExpandablePageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          BtcPayLoadingModal(voucher: voucher, controller: controller),
          BtcPayInfo(
            voucher: voucher,
            controller: controller,
            account: account,
          ),
          BtcPayLoadingPayout(
              voucher: voucher, controller: controller, account: account),
          BtcPayFail(
            voucher: voucher,
          ),
          const BtcPayRedeemModalSuccess(),
        ],
      ),
    );
  }
}

Container loadingSpinner(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.width * 0.85,
    child: const Center(
      child: SizedBox(
        height: EnvoySpacing.xl,
        width: EnvoySpacing.xl,
        child: CircularProgressIndicator(
          color: EnvoyColors.tealLight,
          backgroundColor: EnvoyColors.gray100,
          strokeWidth: 4.71,
        ),
      ),
    ),
  );
}
