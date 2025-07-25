// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/ui/pages/wallet/single_wallet_address_verify_confirm.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:ngwallet/ngwallet.dart';

class SingleWalletAddressVerifyPage extends StatelessWidget {
  final EnvoyAccount pairedWallet;

  const SingleWalletAddressVerifyPage(this.pairedWallet, {super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: const Key("single_wallet_address_verify"),
      qrCode: Future.value(pairedWallet.getPreferredAddress()),
      text: [
        Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: OnboardingText(
                header: S().pair_new_device_QR_code_heading,
                text: S().pair_new_device_QR_code_subheading),
          ),
        ),
      ],
      buttons: [
        OnboardingButton(
            label: S().component_continue,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const SingleWalletAddressVerifyConfirmPage();
              }));
            }),
      ],
    );
  }
}
