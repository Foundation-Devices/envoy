// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class SingleImportPpScanPage extends OnboardingPage {
  const SingleImportPpScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: OnboardingPage(
        key: const Key("single_import_pp_scan"),
        clipArt: Image.asset("assets/pair_new_device_scan.png"),
        text: [
          Expanded(
            child: PageView(
              children: [
                SingleChildScrollView(
                  child: OnboardingText(
                      header: S().pair_new_device_scan_heading,
                      text: S().pair_new_device_scan_subheading),
                ),
              ],
            ),
          )
        ],
        navigationDots: 2,
        navigationDotsIndex: 1,
        buttons: [
          Padding(
            padding: EdgeInsets.only(
                bottom: context.isSmallScreen
                    ? EnvoySpacing.medium1
                    : EnvoySpacing.medium3),
            child: OnboardingButton(
                label: S().component_continue,
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ScannerPage(const [ScannerType.pair]);
                  }));
                }),
          ),
        ],
      ),
    );
  }
}
