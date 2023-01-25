// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/wallet/single_wallet_address_verify_confirm.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:wallet/wallet.dart';

class SingleWalletAddressVerifyPage extends StatelessWidget {
  final Wallet pairedWallet;
  SingleWalletAddressVerifyPage(this.pairedWallet);

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("single_wallet_address_verify"),
      qrCode: pairedWallet.getAddress(),
      text: [
        OnboardingText(
            header: S().single_envoy_wallet_address_verify_heading,
            text: S().single_envoy_wallet_address_verify_subheading),
      ],
      buttons: [
        OnboardingButton(
            label: S().single_envoy_wallet_address_verify_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleWalletAddressVerifyConfirmPage();
              }));
            }),
      ],
    );
  }
}
