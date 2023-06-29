// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'dart:io';

//ignore: must_be_immutable
class FwAndroidInstructionsPage extends StatelessWidget {
  bool onboarding;
  int deviceId;

  FwAndroidInstructionsPage({this.onboarding = true, this.deviceId = 1});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("fw_android_instructions"),
      text: [
        OnboardingText(
          header: "Allow phone to access the microSD card",
          text:
              "Grant phone access to copy files to the microSD card with the name PASSPORT-SD.",
        )
      ],
      navigationDots: 6,
      navigationDotsIndex: 2,
      buttons: [
        OnboardingButton(
            label: "Continue",
            onTap: () {
              UpdatesManager().getStoredFw(deviceId).then((File file) {
                FwUploader(file).getDirectoryContentPermission();
              });
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwMicrosdPage(onboarding: onboarding);
              }));
            }),
      ],
    );
  }
}
