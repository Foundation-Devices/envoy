// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/scv/scv_show_qr.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ScvResultFailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("scv_result_fail"),
      clipArt: Image.asset("assets/shield_bad.png"),
      text: [
        OnboardingText(
            header: loc.envoy_scv_result_fail_heading,
            text: loc.envoy_scv_result_fail_subheading)
      ],
      buttons: [
        OnboardingButton(
            label: loc.envoy_scv_result_fail_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScvShowQrPage();
              }));
            }),
        OnboardingButton(
            label: loc.envoy_scv_result_fail_cta1,
            onTap: () {
              launchUrl(Uri.parse("mailto:hello@foundationdevices.com"));
            }),
      ],
    );
  }
}
