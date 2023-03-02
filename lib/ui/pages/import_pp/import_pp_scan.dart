// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class ImportPpScanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("import_pp_scan"),
      text: [
        OnboardingText(
            header: S().envoy_import_pp_scan_heading,
            text: S().envoy_import_pp_scan_subheading),
      ],
      navigationDots: 2,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: S().envoy_import_pp_scan_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScannerPage(ScannerType.pair);
              }));
            }),
      ],
    );
  }
}
