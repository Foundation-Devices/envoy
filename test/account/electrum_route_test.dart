// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/electrum_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const route = ElectrumRoute(requiresTor: true, port: 19050, generation: 4);

  test('recognizes an unchanged Tor route', () {
    const unchanged = ElectrumRoute(
      requiresTor: true,
      port: 19050,
      generation: 4,
    );

    expect(route.isSameRoute(unchanged), isTrue);
    expect(route.canRetryOn(unchanged), isFalse);
  });

  test('retries when either Tor route identity field changes', () {
    const reusedPort = ElectrumRoute(
      requiresTor: true,
      port: 19050,
      generation: 5,
    );
    const replacementPort = ElectrumRoute(
      requiresTor: true,
      port: 29050,
      generation: 4,
    );

    expect(route.canRetryOn(reusedPort), isTrue);
    expect(route.canRetryOn(replacementPort), isTrue);
  });

  test('never changes route policy or retries an unavailable route', () {
    const unavailable = ElectrumRoute(
      requiresTor: true,
      port: null,
      generation: 5,
    );
    const direct = ElectrumRoute(requiresTor: false, port: null, generation: 5);

    expect(route.canRetryOn(unavailable), isFalse);
    expect(route.canRetryOn(direct), isFalse);
  });
}
