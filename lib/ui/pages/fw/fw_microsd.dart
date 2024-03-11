// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/pages/fw/fw_android_instructions.dart';
import 'package:envoy/ui/pages/fw/fw_ios_instructions.dart';
import 'package:envoy/ui/pages/fw/fw_android_progress.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/ui/pages/fw/fw_ios_success.dart';
import 'package:envoy/util/bug_report_helper.dart';

class FwMicrosdPage extends ConsumerWidget {
  final bool onboarding;
  final int deviceId;

  const FwMicrosdPage({super.key, this.onboarding = true, this.deviceId = 1});

  @override
  Widget build(context, ref) {
    final fwInfo = ref.watch(firmwareStreamProvider(deviceId));

    return OnboardingPage(
      rightFunction: (_) {
        onboarding
            ? OnboardingPage.popUntilHome(context)
            : OnboardingPage.popUntilGoRoute(context);
      },
      key: const Key("fw_microsd"),
      clipArt: Image.asset("assets/fw_microsd.png"),
      text: [
        OnboardingText(
          header: S().envoy_fw_microsd_heading,
          text: S().envoy_fw_microsd_subheading,
        )
      ],
      navigationDots: 6,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            enabled: fwInfo.hasValue,
            label: S().component_continue,
            onTap: () async {
              try {
                File firmwareFile =
                    await UpdatesManager().getStoredFw(deviceId);
                await FwUploader(firmwareFile).upload();

                Devices()
                    .markDeviceUpdated(deviceId, fwInfo.value!.storedVersion);

                if (Platform.isIOS && context.mounted) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return FwIosSuccessPage(
                      onboarding: onboarding,
                    );
                  }));
                }

                if (Platform.isAndroid) {
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (context.mounted) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return FwAndroidProgressPage(deviceId,
                          onboarding: onboarding);
                    }));
                  }
                }
              } catch (e) {
                kPrint("SD: error $e");
                EnvoyReport().log("uploading",
                    "Couldn't upload file to SD card: ${e.toString()}");
                if (Platform.isIOS &&
                    context.mounted) // TODO: this needs to be smarter
                  // ignore: curly_braces_in_flow_control_structures
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return FwIosInstructionsPage(
                      onboarding: onboarding,
                      deviceId: deviceId,
                    );
                  }));

                if (Platform.isAndroid && context.mounted) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return FwAndroidInstructionsPage(
                        onboarding: onboarding, deviceId: deviceId);
                  }));
                }
              }
            }),
      ],
    );
  }
}
