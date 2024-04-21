// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/wallet/single_wallet_address_verify_confirm.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:flutter/material.dart';
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
            header: S().pair_new_device_QR_code_heading,
            text: S().pair_new_device_QR_code_subheading),
      ],
      buttons: [
        OnboardingButton(
            label: S().component_continue,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleWalletAddressVerifyConfirmPage();
              }));
            }),
        SizedBox(
          height: context.isSmallScreen
              ? EnvoySpacing.medium1
              : EnvoySpacing.medium3,
        )
      ],
    );
  }
}
