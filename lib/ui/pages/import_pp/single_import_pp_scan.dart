// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class SingleImportPpScanPage extends OnboardingPage {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: OnboardingPage(
        key: Key("single_import_pp_scan"),
        clipArt: Image.asset("assets/pair_new_device_scan.png"),
        text: [
          OnboardingText(
              header: S().pair_new_device_scan_heading,
              text: S().pair_new_device_scan_subheading)
        ],
        navigationDots: 2,
        navigationDotsIndex: 1,
        buttons: [
          OnboardingButton(
              label: S().envoy_scv_scan_qr_cta,
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ScannerPage([ScannerType.pair]);
                }));
              }),
        ],
      ),
    );
  }
}
