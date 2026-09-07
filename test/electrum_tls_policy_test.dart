// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/electrum_tls_policy.dart';
import 'package:test/test.dart';

void main() {
  const onion = 'ssl://exampleaddress.onion:50002';
  const clearnet = 'ssl://electrum.example.com:50002';
  const bareClearnet = 'electrum.example.com:50002';

  group('shouldValidateElectrumCertificate', () {
    for (final (name, server, viaTor, exception, expected) in [
      ('onion through Tor', onion, true, false, false),
      (
        'mixed-case bare onion',
        'exampleaddress.ONION:50002',
        true,
        false,
        false
      ),
      ('bare onion without port', 'exampleaddress.onion', true, false, false),
      (
        'onion with trailing dot',
        'ssl://exampleaddress.onion.:50002',
        true,
        false,
        false
      ),
      ('onion without Tor', onion, false, false, true),
      ('clearnet through Tor', clearnet, true, false, true),
      (
        'onion-looking clearnet',
        'ssl://node.onion.example.com:50002',
        true,
        false,
        true
      ),
      ('exception without Tor', clearnet, false, true, false),
      ('exception through Tor', clearnet, true, true, false),
    ]) {
      test(name, () {
        expect(
          shouldValidateElectrumCertificate(
            server: server,
            viaTor: viaTor,
            hasCertificateException: exception,
          ),
          expected,
        );
      });
    }
  });

  group('hasElectrumCertificateException', () {
    for (final (name, server, exception, expected) in [
      ('bare exception', clearnet, bareClearnet, true),
      ('bare server', bareClearnet, clearnet, true),
      ('different server', clearnet, 'ssl://other.example.com:50002', false),
      (
        'mixed-case hostname',
        'ssl://Node.Example.com:50002',
        'ssl://node.example.com:50002',
        true
      ),
    ]) {
      test(name, () {
        expect(
          hasElectrumCertificateException(
            server: server,
            exceptions: [exception],
          ),
          expected,
        );
      });
    }
  });
}
