// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/ui/pages/scv/scv_show_qr.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/scv_server.dart';

class ScvScanQrPage extends StatelessWidget {
  final Challenge challenge;

  ScvScanQrPage(this.challenge);

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("scv_scan_qr"),
      clipArt: Image.asset("assets/scv_scan_qr.png"),
      text: [
        OnboardingText(
            header: S().envoy_scv_scan_qr_heading,
            text: S().envoy_scv_scan_qr_subheading)
      ],
      navigationDots: 3,
      navigationDotsIndex: 2,
      leftFunction: (context) {
        // ENV-216: remove ScvShowQrPage off navigation stack so it doesn't animate in background
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return ScvShowQrPage();
        }));
      },
      buttons: [
        OnboardingButton(
            label: S().envoy_scv_scan_qr_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScannerPage.scv(challenge);
              }));
            }),
      ],
    );
  }
}
