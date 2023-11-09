// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/pages/wallet/single_wallet_address_verify.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:wallet/wallet.dart';

class SingleWalletPairSuccessPage extends StatelessWidget {
  final Wallet pairedWallet;

  SingleWalletPairSuccessPage(this.pairedWallet);

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("single_wallet_pair_success"),
      clipArt: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Image.asset(
          "assets/circle_ok.png",
          height: 150,
        ),
      ),
      text: [
        OnboardingText(
            header: S().pair_new_device_success_heading,
            text: S().pair_new_device_success_subheading),
      ],
      buttons: [
        OnboardingButton(
            type: EnvoyButtonTypes.secondary,
            label: S().pair_new_device_success_cta2,
            onTap: () {
              OnboardingPage.goHome(context);
            }),
        OnboardingButton(
            label: S().pair_new_device_success_cta1,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleWalletAddressVerifyPage(pairedWallet);
              }));
            }),
      ],
    );
  }
}
