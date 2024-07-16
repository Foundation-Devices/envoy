// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_scan.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';

class SingleImportPpIntroPage extends StatelessWidget {
  final bool isExistingDevice;

  const SingleImportPpIntroPage({super.key, this.isExistingDevice = true});

  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
      gradientHeight: 1.8,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: kToolbarHeight,
          backgroundColor: Colors.transparent,
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: EnvoyButton(
                S().component_skip,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
                type: EnvoyButtonTypes.tertiary,
                onTap: () {
                  OnboardingPage.popUntilHome(context);
                },
              ),
            )
          ],
        ),
        //using floating action button + offset for clamping the passport image to bottom nav
        //this is better than using a stack
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 110),
          child: Image.asset(
            "assets/pp_setup_intro.png",
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width / 1.2,
            height: MediaQuery.of(context).size.height / 1.2,
          ),
        ),
        bottomNavigationBar: envoyScaffoldShieldScrollView(
          context,
          Padding(
              padding: const EdgeInsets.only(
                  right: EnvoySpacing.medium1,
                  left: EnvoySpacing.medium1,
                  top: EnvoySpacing.medium1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: EnvoySpacing.large2),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: EnvoySpacing.medium1),
                            child: OnboardingText(
                              header: S().pair_existing_device_intro_heading,
                              text: isExistingDevice
                                  ? S().pair_existing_device_intro_subheading
                                  : S()
                                      .pair_new_device_intro_connect_envoy_subheading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: EnvoySpacing.medium1,
                        right: EnvoySpacing.medium1,
                        bottom: EnvoySpacing.large3),
                    child: EnvoyButton(
                      S().accounts_empty_text_learn_more,
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const SingleImportPpScanPage();
                        }));
                      },
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
