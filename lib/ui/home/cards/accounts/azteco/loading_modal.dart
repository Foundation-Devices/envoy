// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/business/azteco_voucher.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:wallet/wallet.dart';

class AztecoLoadingModal extends StatefulWidget {
  final AztecoVoucher voucher;
  final PageController controller;
  final Wallet wallet;

  AztecoLoadingModal(
      {Key? key,
      required this.voucher,
      required this.controller,
      required this.wallet})
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
    String address = await widget.wallet.getAddress();
    bool success = await widget.voucher.redeem(address);

    if (success) {
      widget.controller.jumpToPage(3); // success
    } else {
      widget.controller.jumpToPage(2); // fail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 60,
        width: 60,
        child: CircularProgressIndicator(
          color: EnvoyColors.teal,
          backgroundColor: EnvoyColors.greyLoadingSpinner,
          strokeWidth: 4.71,
        ),
      ),
    );
  }
}
