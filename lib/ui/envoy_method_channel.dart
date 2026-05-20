// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:envoy/business/settings.dart';
import 'package:url_launcher/url_launcher.dart';
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

Future<String> getConnectedPeripheralID() async {
  if (Platform.isIOS) {
    return await _platformChannel.invokeMethod("get_connected_peripheral_id");
  } else {
    return "";
  }
}

// Launches [url] in the user's installed Tor Browser. Returns false if no
// Tor browser is available or the launch failed — callers should decide
// whether to fall back to the system browser.
//
// Android: targets Tor Browser (stable/alpha) via an explicit setPackage
// intent through the `envoy` method channel.
// iOS: rewrites the URL to Onion Browser's `onionhttp(s)://` scheme.
Future<bool> launchInTorBrowser(String url) async {
  if (Platform.isAndroid) {
    try {
      return await _platformChannel.invokeMethod<bool>(
            "launch_in_tor_browser",
            {"url": url},
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }
  if (Platform.isIOS) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final String rewrittenScheme;
    if (uri.scheme == 'https') {
      rewrittenScheme = 'onionhttps';
    } else if (uri.scheme == 'http') {
      rewrittenScheme = 'onionhttp';
    } else {
      return false;
    }
    final rewritten = uri.replace(scheme: rewrittenScheme);
    if (!await canLaunchUrl(rewritten)) return false;
    return await launchUrl(rewritten);
  }
  return false;
}
