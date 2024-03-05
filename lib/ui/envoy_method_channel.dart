// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:envoy/business/settings.dart';
import 'dart:io';

const _platformChannel = MethodChannel('envoy');
const _screenSecureMethod = "make_screen_secure";

Future enableSecureScreen() async {
  if (!Settings().allowScreenshots() && !Platform.isLinux) {
    await _platformChannel.invokeMethod(_screenSecureMethod, {"secure": true});
  }
}

Future disableSecureScreen() async {
  if (!Settings().allowScreenshots() && !Platform.isLinux) {
    await Future.delayed(const Duration(milliseconds: 300));
    await _platformChannel.invokeMethod(_screenSecureMethod, {"secure": false});
  }
}

//Opens android backup settings
Future openAndroidSettings() async {
  if (Platform.isAndroid) await _platformChannel.invokeMethod("open_settings");
}
