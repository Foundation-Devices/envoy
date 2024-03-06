// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:envoy/business/azteco_voucher.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/business/account.dart';

class AztecoLoadingModal extends StatefulWidget {
  final AztecoVoucher voucher;
  final PageController controller;
  final Account account;

  const AztecoLoadingModal(
      {Key? key,
      required this.voucher,
      required this.controller,
      required this.account})
      : super(key: key);

  @override
  _AztecoLoadingModalState createState() => _AztecoLoadingModalState();
}

class _AztecoLoadingModalState extends State<AztecoLoadingModal> {
  @override
  void initState() {
    super.initState();
    _checkVoucher();
  }

  Future<void> _checkVoucher() async {
    String address = await widget.account.wallet.getAddress();
    AztecoVoucherRedeemResult result = await widget.voucher.redeem(address);
    switch (result) {
      case AztecoVoucherRedeemResult.success:
        {
          addPendingTx(address, widget.account);
          widget.controller.jumpToPage(3);
        }

      case AztecoVoucherRedeemResult.timeout:
        widget.controller.jumpToPage(4);
      case AztecoVoucherRedeemResult.voucherInvalid:
        widget.controller.jumpToPage(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.75,
      child: const Center(
        child: const SizedBox(
          height: 60,
          width: 60,
          child: CircularProgressIndicator(
            color: EnvoyColors.teal,
            backgroundColor: EnvoyColors.greyLoadingSpinner,
            strokeWidth: 4.71,
          ),
        ),
      ),
    );
  }
}
