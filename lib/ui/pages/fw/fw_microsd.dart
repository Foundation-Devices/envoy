// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FwMicrosdPage extends ConsumerWidget {
  final FwPagePayload fwPagePayload;

  const FwMicrosdPage({super.key, required this.fwPagePayload});

  @override
  Widget build(context, ref) {
    int deviceId = fwPagePayload.deviceId;
    final fwInfo = ref.watch(firmwareStreamProvider(deviceId));

    return OnboardingPage(
      key: const Key("fw_microsd"),
      clipArt: Image.asset("assets/fw_microsd.png", height: 312, width: 129),
      text: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: OnboardingText(
                  header: S().envoy_fw_microsd_heading,
                  text: S().envoy_fw_microsd_subheading,
                ),
              ),
            ),
          ],
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

                if (Platform.isIOS && context.mounted) {
                  context.goNamed(PASSPORT_UPDATE_IOS_SUCCESS,
                      extra: fwPagePayload);
                }

                if (Platform.isAndroid) {
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (context.mounted) {
                    context.goNamed(PASSPORT_UPDATE_ANDROID,
                        extra: fwPagePayload);
                  }
                }
              } catch (e) {
                kPrint("SD: error $e");
                EnvoyReport().log("uploading",
                    "Couldn't upload file to SD card: ${e.toString()}");
                if (Platform.isIOS &&
                    context.mounted) // TODO: this needs to be smarter
                  // ignore: curly_braces_in_flow_control_structures
                  context.goNamed(PASSPORT_UPDATE_IOS_INSTRUCTION,
                      extra: fwPagePayload);
                if (Platform.isAndroid && context.mounted) {
                  context.goNamed(PASSPORT_UPDATE_ANDROID_INSTRUCTION,
                      extra: fwPagePayload);
                }
              }
            }),
      ],
    );
  }
}
