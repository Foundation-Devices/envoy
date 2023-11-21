// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/azteco_voucher.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/business/account.dart';
import 'package:wallet/wallet.dart';

class AztecoLoadingModal extends StatefulWidget {
  final AztecoVoucher voucher;
  final PageController controller;
  final Account account;

  AztecoLoadingModal(
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
      case AztecoVoucherRedeemResult.Success:
        {
          EnvoyStorage().addPendingTx("azteco", widget.account.id ?? "",
              DateTime.now(), TransactionType.azteco, 0, 0, "");
          EnvoyStorage().addTxNote("Azteco voucher", "azteco"); // TODO: FIGMA
          widget.controller.jumpToPage(3);
        }

      case AztecoVoucherRedeemResult.Timeout:
        widget.controller.jumpToPage(4);
      case AztecoVoucherRedeemResult.VoucherInvalid:
        widget.controller.jumpToPage(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width * 0.75,
      child: Center(
        child: SizedBox(
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
