// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:envoy/business/scv_server.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/ui/onboard/prime/state/prime_onboarding_controller.dart';
import 'package:envoy/ui/onboard/prime/state/qlv2/prime_onboarding_qlv2_security_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_api/foundation_api.dart' as foundation;
import 'package:mockito/mockito.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

void main() {
  test('QL v2 obeys the Prime security-check skip setting', () async {
    final previous = Settings().skipPrimeSecurityCheck;
    addTearDown(() => Settings().skipPrimeSecurityCheck = previous);
    Settings().skipPrimeSecurityCheck = true;

    final securityService = _FakeSecurityCheckService();
    final sent = <qlv2.RunSecurityCheckResponderEvent>[];
    var finished = false;
    final duplex = SecurityCheckDuplex(
      listen: () => Stream.fromIterable([
        const qlv2.RunSecurityCheckInitiatorEvent.start(),
        qlv2.RunSecurityCheckInitiatorEvent.challengeResponse(
          qlv2.ChallengeResponseResult.success(
            data: Uint8List.fromList([4, 5, 6]),
          ),
        ),
      ]),
      send: (event) async => sent.add(event),
      finish: () async => finished = true,
    );
    final handler = PrimeOnboardingQlv2SecurityCheckHandler(
      PrimeOnboardingController(),
      skipSecurityCheck: Settings().skipPrimeSecurityCheck,
      securityCheckService: securityService,
    );

    await handler.handleDuplex(duplex, _MockQLConnection());
    await duplex.dispose();

    expect(securityService.challengeRequests, 1);
    expect(securityService.proofVerifications, 0);
    expect(sent, hasLength(2));
    expect(
      sent.first,
      isA<qlv2.RunSecurityCheckResponderEvent_ChallengeRequest>(),
    );
    final verification =
        sent.last as qlv2.RunSecurityCheckResponderEvent_VerificationResult;
    expect(verification.field0, isA<qlv2.VerificationResult_Success>());
    expect(finished, isTrue);
  });
}

class _MockQLConnection extends Mock implements QLConnection {}

class _FakeSecurityCheckService implements PrimeSecurityCheckService {
  var challengeRequests = 0;
  var proofVerifications = 0;

  @override
  Future<foundation.ChallengeRequest?> getPrimeChallenge() async {
    challengeRequests++;
    return foundation.ChallengeRequest(data: Uint8List.fromList([1, 2, 3]));
  }

  @override
  Future<ScvVerificationResult> verifyProof(Uint8List data) async {
    proofVerifications++;
    return ScvVerificationResult.success;
  }
}
