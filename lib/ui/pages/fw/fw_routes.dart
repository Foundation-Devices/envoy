// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/ui/pages/fw/fw_android_instructions.dart';
import 'package:envoy/ui/pages/fw/fw_android_progress.dart';
import 'package:envoy/ui/pages/fw/fw_intro.dart';
import 'package:envoy/ui/pages/fw/fw_ios_instructions.dart';
import 'package:envoy/ui/pages/fw/fw_ios_success.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:envoy/ui/pages/fw/fw_passport.dart';
import 'package:go_router/go_router.dart';

const PASSPORT_UPDATE = 'passport_update';
const PASSPORT_UPDATE_PASSPORT = 'passport_update_passport';
const PASSPORT_UPDATE_SD_CARD = 'passport_sd';
const PASSPORT_UPDATE_ANDROID = 'passport_android';
const PASSPORT_UPDATE_ANDROID_INSTRUCTION = 'passport_android_instructions';
const PASSPORT_UPDATE_IOS = 'passport_ios';
const PASSPORT_UPDATE_IOS_INSTRUCTION = 'passport_ios_instructions';
const PASSPORT_UPDATE_IOS_SUCCESS = 'passport_ios_success';

//common parameters across different fw pages
class FwPagePayload {
  int deviceId;
  bool onboarding;

  FwPagePayload({this.deviceId = 1, required this.onboarding});
}

final fwRoutes = GoRoute(
    path: "/passport_update",
    name: PASSPORT_UPDATE,
    builder: (context, state) => FwIntroPage(
          fwPagePayload: state.extra as FwPagePayload,
        ),
    routes: [
      GoRoute(
        path: 'passport',
        name: PASSPORT_UPDATE_PASSPORT,
        builder: (context, state) => FwPassportPage(
          fwPagePayload: state.extra as FwPagePayload,
        ),
      ),
      GoRoute(
        path: "sd_card",
        name: PASSPORT_UPDATE_SD_CARD,
        builder: (context, state) => FwMicrosdPage(
          fwPagePayload: state.extra as FwPagePayload,
        ),
        routes: [
          GoRoute(
            path: "android",
            name: PASSPORT_UPDATE_ANDROID,
            builder: (context, state) => FwAndroidProgressPage(
              payload: state.extra as FwPagePayload,
            ),
          ),
          GoRoute(
            path: "ios_instruction",
            name: PASSPORT_UPDATE_IOS_INSTRUCTION,
            builder: (context, state) => FwIosInstructionsPage(
              fwPagePayload: state.extra as FwPagePayload,
            ),
          ),
          GoRoute(
            path: "android_instruction",
            name: PASSPORT_UPDATE_ANDROID_INSTRUCTION,
            builder: (context, state) => FwAndroidInstructionsPage(
              fwPagePayload: state.extra as FwPagePayload,
            ),
          )
        ],
      ),
      GoRoute(
        path: "ios_success",
        name: PASSPORT_UPDATE_IOS_SUCCESS,
        builder: (context, state) => FwIosSuccessPage(
          fwPagePayload: state.extra as FwPagePayload,
        ),
      )
    ]);
