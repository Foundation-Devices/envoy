// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/business/btcpay_voucher.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/home/cards/accounts/btcPay/btcpay_dialog.dart';

class BtcPayLoadingPayout extends StatefulWidget {
  final BtcPayVoucher voucher;
  final PageController controller;
  final Account account;

  BtcPayLoadingPayout(
      {Key? key,
      required this.voucher,
      required this.controller,
      required this.account})
      : super(key: key);

  @override
  _BtcPayLoadingPayoutState createState() => _BtcPayLoadingPayoutState();
}

class _BtcPayLoadingPayoutState extends State<BtcPayLoadingPayout> {
  @override
  void initState() {
    super.initState();
    _createPayout();
  }

  Future<void> _createPayout() async {
    String address = await widget.account.wallet.getAddress();
    BtcPayVoucherRedeemResult result =
        await widget.voucher.createPayout(address);

    if (result == BtcPayVoucherRedeemResult.success) {
      {
        addPendingTx(widget.voucher.id, address, widget.account);
        widget.controller.jumpToPage(4);
      }
    } else
      widget.controller.jumpToPage(3);
  }

  @override
  Widget build(BuildContext context) {
    return loadingSpinner(context);
  }
}
