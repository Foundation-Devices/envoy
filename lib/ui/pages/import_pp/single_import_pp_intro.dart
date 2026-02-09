// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/routes/onboard_routes.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SingleImportPpIntroPage extends StatelessWidget {
  final bool isExistingDevice;

  const SingleImportPpIntroPage({super.key, this.isExistingDevice = true});

  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: kToolbarHeight,
        backgroundColor: Colors.transparent,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
      ),
      header: Transform.translate(
        offset: const Offset(0, 110),
        child: Image.asset(
          "assets/pp_setup_intro.png",
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width / 1.1,
          height: MediaQuery.of(context).size.height / 1.1,
        ),
      ),
      shield: Padding(
        padding: const EdgeInsets.only(
          right: EnvoySpacing.medium1,
          left: EnvoySpacing.medium1,
          top: EnvoySpacing.small,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: OnboardingText(
                  header: S().pair_existing_device_intro_heading,
                  text: isExistingDevice
                      ? S().pair_existing_device_intro_subheading
                      : S().pair_new_device_intro_connect_envoy_subheading,
                ),
              ),
            ),
            const SizedBox(height: EnvoySpacing.small),
            Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.small),
              child: EnvoyButton(
                S().accounts_empty_text_learn_more,
                onTap: () {
                  context.pushNamed(ONBOARD_PASSPORT_EXISTING_SCAN);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
