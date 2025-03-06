// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/scv_server.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/scv/scv_loading.dart';
import 'package:envoy/ui/pages/scv/scv_show_qr.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/scanner/decoders/scv_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:flutter/material.dart';

class ScvScanQrPage extends StatelessWidget {
  final Challenge challenge;

  const ScvScanQrPage(this.challenge, {super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: const Key("scv_scan_qr"),
      clipArt: Image.asset("assets/scv_scan_qr.png"),
      text: [
        Padding(
          padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
          child: SingleChildScrollView(
            child: OnboardingText(
                header: S().pair_new_device_scan_heading,
                text: S().pair_new_device_scan_subheading),
          ),
        )
      ],
      leftFunction: (context) {
        // ENV-216: remove ScvShowQrPage off navigation stack so it doesn't animate in background
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return ScvShowQrPage();
        }));
      },
      buttons: [
        OnboardingButton(
            label: S().component_continue,
            onTap: () {
              showScannerDialog(
                  context: context,
                  onBackPressed: (context) {
                    Navigator.pop(context);
                  },
                  decoder: ScvDecoder(
                    onScan: (CryptoResponse cryptoResponse) {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return ScvLoadingPage(
                          cryptoResponse,
                          challenge,
                        );
                      }));
                    },
                  ));
            }),
      ],
    );
  }
}
