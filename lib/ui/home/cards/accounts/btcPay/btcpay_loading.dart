// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/business/btcpay_voucher.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/home/cards/accounts/btcPay/btcpay_dialog.dart';

class BtcPayLoadingModal extends StatefulWidget {
  final BtcPayVoucher voucher;
  final PageController controller;

  const BtcPayLoadingModal({
    super.key,
    required this.voucher,
    required this.controller,
  });

  @override
  BtcPayLoadingModalState createState() => BtcPayLoadingModalState();
}

class BtcPayLoadingModalState extends State<BtcPayLoadingModal> {
  @override
  void initState() {
    super.initState();
    _checkVoucher();
  }

  Future<void> _checkVoucher() async {
    BtcPayVoucherRedeemResult result = await widget.voucher.getinfo();
    kPrint(result);

    if (result == BtcPayVoucherRedeemResult.success) {
      {
        widget.controller.jumpToPage(1);
      }
    } else
      widget.controller.jumpToPage(3);
  }

  @override
  Widget build(BuildContext context) {
    return loadingSpinner(context);
  }
}
