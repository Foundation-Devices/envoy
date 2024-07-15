// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'dart:io';
import 'package:envoy/ui/theme/envoy_spacing.dart';

//ignore: must_be_immutable
class FwAndroidInstructionsPage extends StatelessWidget {
  bool onboarding;
  int deviceId;

  FwAndroidInstructionsPage(
      {super.key, this.onboarding = true, this.deviceId = 1});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: const Key("fw_android_instructions"),
      rightFunction: (_) {
        onboarding
            ? OnboardingPage.popUntilHome(context)
            : OnboardingPage.popUntilGoRoute(context);
      },
      text: const [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: OnboardingText(
                  header:
                      "Allow phone to access the microSD card", // TODO: FIGMA
                  text:
                      "Grant phone access to copy files to the microSD card with the name PASSPORT-SD.", // TODO: FIGMA
                ),
              ),
            ),
          ],
        )
      ],
      navigationDots: 6,
      navigationDotsIndex: 2,
      buttons: [
        Padding(
          padding: const EdgeInsets.only(
              bottom: EnvoySpacing.medium2,
              left: EnvoySpacing.xs,
              right: EnvoySpacing.xs),
          child: OnboardingButton(
              label: "Continue", // TODO: FIGMA
              onTap: () {
                UpdatesManager().getStoredFw(deviceId).then((File file) {
                  FwUploader(file).getDirectoryContentPermission();
                });
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return FwMicrosdPage(onboarding: onboarding);
                }));
              }),
        ),
      ],
    );
  }
}
