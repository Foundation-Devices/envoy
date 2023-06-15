// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/scv/scv_show_qr.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class ScvResultFailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("scv_result_fail"),
      clipArt: Image.asset("assets/shield_bad.png"),
      text: [
        OnboardingText(
            header: S().envoy_scv_result_fail_heading,
            text: S().envoy_scv_result_fail_subheading)
      ],
      buttons: [
        OnboardingButton(
            label: S().envoy_scv_result_fail_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScvShowQrPage();
              }));
            }),
        OnboardingButton(
            label: S().envoy_scv_result_fail_cta1,
            onTap: () {
              launchUrl(Uri.parse("mailto:hello@foundationdevices.com"));
            }),
      ],
    );
  }
}
