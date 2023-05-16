// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:envoy/business/settings.dart';
import 'dart:io';

final _platformChannel = MethodChannel('envoy');
final _screenSecureMethod = "make_screen_secure";

Future enableSecureScreen() async {
  if (!Settings().allowScreenshots() && !Platform.isLinux)
    await _platformChannel.invokeMethod(_screenSecureMethod, {"secure": true});
}

Future disableSecureScreen() async {
  if (!Settings().allowScreenshots() && !Platform.isLinux)
    await _platformChannel.invokeMethod(_screenSecureMethod, {"secure": false});
}

//Opens android backup settings
Future openAndroidSettings() async {
  if (Platform.isAndroid) await _platformChannel.invokeMethod("open_settings");
}
