// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:envoy/business/settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

const _platformChannel = MethodChannel('envoy');
const _screenSecureMethod = "make_screen_secure";

// Nested seed views (the QR dialog and its words overlay) each hold one
// claim; the native flag clears only when the last claim is released, so
// closing a child cannot unprotect a still-visible parent.
int _secureScreenClaims = 0;

// Test seams: the platform has no handler under `flutter test`, and a
// widget test tearing down a secure screen must not leave the disable
// delay pending.
@visibleForTesting
Future<void> Function(bool secure) sendScreenSecure = _sendScreenSecure;

@visibleForTesting
Duration secureScreenDisableDelay = const Duration(milliseconds: 300);

@visibleForTesting
void resetSecureScreenClaims() {
  _secureScreenClaims = 0;
}

Future<void> _sendScreenSecure(bool secure) async {
  if (Platform.isLinux) return;
  await _platformChannel.invokeMethod(_screenSecureMethod, {"secure": secure});
}

Future enableSecureScreen() async {
  _secureScreenClaims++;
  if (!Settings().allowScreenshots()) {
    await sendScreenSecure(true);
  }
}

Future disableSecureScreen() async {
  if (_secureScreenClaims > 0) {
    _secureScreenClaims--;
  }
  if (_secureScreenClaims > 0 || Settings().allowScreenshots()) {
    return;
  }
  if (secureScreenDisableDelay > Duration.zero) {
    await Future.delayed(secureScreenDisableDelay);
  }
  // A claim taken during the delay keeps the flag on until it is released.
  if (_secureScreenClaims == 0) {
    await sendScreenSecure(false);
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
