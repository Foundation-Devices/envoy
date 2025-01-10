// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'dart:io';

import 'package:go_router/go_router.dart';

class FwAndroidInstructionsPage extends StatelessWidget {
  final FwPagePayload fwPagePayload;

  const FwAndroidInstructionsPage({super.key, required this.fwPagePayload});

  @override
  Widget build(BuildContext context) {
    int deviceId = fwPagePayload.deviceId;
    return OnboardingPage(
      key: const Key("fw_android_instructions"),
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
        OnboardingButton(
            label: "Continue", // TODO: FIGMA
            onTap: () {
              final router = GoRouter.of(context);
              UpdatesManager().getStoredFw(deviceId).then((File file) {
                FwUploader(file).getDirectoryContentPermission();
              }).then((value) {
                router.goNamed(PASSPORT_UPDATE_SD_CARD, extra: fwPagePayload);
              }, onError: (ex) {
                if (context.mounted) {
                  EnvoyToast(
                    backgroundColor: EnvoyColors.danger,
                    replaceExisting: true,
                    duration: const Duration(seconds: 4),
                    message: "Error: $ex",
                    icon: const Icon(
                      Icons.info_outline,
                      color: EnvoyColors.solidWhite,
                    ),
                  ).show(context);
                }
                EnvoyReport().log("FwAndroid", ex.toString());
              });
            }),
      ],
    );
  }
}
