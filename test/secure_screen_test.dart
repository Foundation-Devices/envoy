// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_method_channel.dart';
import 'package:test/test.dart';

void main() {
  final sent = <bool>[];

  setUp(() {
    sent.clear();
    resetSecureScreenClaims();
    Settings().allowScreenshotsSetting = false;
    sendScreenSecure = (secure) async => sent.add(secure);
  });

  test("Closing a nested seed view keeps the parent protected", () async {
    await enableSecureScreen(); // seed QR dialog
    await enableSecureScreen(); // words overlay on top
    await disableSecureScreen(); // words overlay closes

    expect(
      sent,
      [true, true],
      reason: "no disable may be sent while the QR still holds a claim",
    );

    await disableSecureScreen(); // QR dialog closes
    expect(sent, [true, true, false]);
  });

  test("A claim taken during the disable delay keeps protection on", () async {
    await enableSecureScreen();
    final closing = disableSecureScreen();
    await enableSecureScreen(); // the next sensitive route opens immediately
    await closing;

    expect(sent.where((secure) => !secure), isEmpty);
  });

  test("Extra disables do not release another owner's claim", () async {
    await disableSecureScreen(); // stray unmatched disable
    sent.clear();

    await enableSecureScreen();
    await enableSecureScreen();
    await disableSecureScreen();

    expect(sent.where((secure) => !secure), isEmpty);
  });
}
