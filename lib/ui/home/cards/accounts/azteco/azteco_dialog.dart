// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/home/cards/accounts/azteco/azteco_redeem_modal.dart';
import 'package:envoy/ui/home/cards/accounts/azteco/loading_modal.dart';
import 'package:envoy/business/azteco_voucher.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/widgets/expandable_page_view.dart';
import 'package:envoy/ui/home/cards/accounts/azteco/azteco_connection_modal_fail.dart';
import 'package:envoy/ui/home/cards/accounts/azteco/azteco_redeem_modal_fail.dart';
import 'package:envoy/ui/home/cards/accounts/azteco/azteco_redeem_modal_success.dart';
import 'package:ngwallet/ngwallet.dart';

class AztecoDialog extends StatelessWidget {
  final AztecoVoucher voucher;
  final EnvoyAccount account;

  const AztecoDialog(this.voucher, this.account, {super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20.0), // change the value as per your need
      ),
      child: ExpandablePageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          AztecoRedeemModal(voucher: voucher, controller: controller),
          AztecoLoadingModal(
            voucher: voucher,
            controller: controller,
            account: account,
          ),
          AztecoRedeemModalFail(controller: controller),
          const AztecoRedeemModalSuccess(),
          AztecoConnectionModalFail(controller: controller),
        ],
      ),
    );
  }
}
