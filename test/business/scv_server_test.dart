// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:flutter_test/flutter_test.dart';

// The sc-server repository's example proof, and the answer the production
// security-check server gave to it (error code 3, invalid signature).
final _proof = _bytes(
  '985960f66dfe4f4f4ff5abd98899345a7303f919f7ca43b2aad55dedde02dc8e819b1469'
  '0000000002d7a83006f783cc9e08dbed2e345ecaa2fac82a4d3d01e456028d2009d1143a'
  '1273353be395f7b879f188cf696c41b80ef720f5023a3c103230b70ab4a193694e302e31'
  '2e31000000000000000000000000000000cad42e2512298e24ce5482d325d06a53bdb9e8'
  'f976a23ac91d460f156b0fff3c4da4b1465cb122bf5cfe06b4f17f8b6510fe2c7448c3cc'
  '6ddae10aecb53641b1',
);
final _productionAnswer = _bytes(
  '006274b2e3fcda7f126bcec44093acce9d05bb52ba04f8be52532268f1d29d2f03'
  '0073e3f00cb7386a9f264ec99808a8fa06d8a0892777d868e9471b8ce049678a'
  '447de6c0db391fc82d96daae9dab79a37519dede1c9515213e8826c0a01ab42f',
);

// The proof's challenge deadline (bytes 32..40).
final _deadline = DateTime.utc(2025, 11, 12, 14, 36, 49);

// Answers to the same proof signed with a test key: a pass, and the
// challenge-timing codes 4 (deadline expired) and 6 (unknown challenge).
const _testPubkey =
    '03baa29125140c04570cc6e589a50d55a1aa7034f7ff686e78c79880a1461dc230';
final _testKeyPass = _bytes(
  '006274b2e3fcda7f126bcec44093acce9d05bb52ba04f8be52532268f1d29d2f00'
  '8003792fe9f375aff826b58f61f54728e4ed76569ae2de0c0f5371948e090561'
  'ad8d69da006e1052e953782ee356cb130d0fe930291d80671d4dbfe1fdc0fcb7',
);
final _testKeyDeadlineExpired = _bytes(
  '006274b2e3fcda7f126bcec44093acce9d05bb52ba04f8be52532268f1d29d2f04'
  '636ffbeba09593cfdaf6982a800eb4221d7b5ea8443ff62f15c601af57d13540'
  'fac7a54539fb2acf60a40c7e31280a73257295bd565cc7c5dc94023d34a274b9',
);
final _testKeyUnknownChallenge = _bytes(
  '006274b2e3fcda7f126bcec44093acce9d05bb52ba04f8be52532268f1d29d2f06'
  '6118e9b2ea2dc9e42c9d186366a0f22a8283e8fbf64243c31b6cc869fae8c8cc'
  'd314450d9bb0d94cda85fcccc8938059fa0a6111dc0a3b6dbb466233d3c3211d',
);

Uint8List _bytes(String hexString) => Uint8List.fromList(hex.decode(hexString));

final _logs = <String>[];

ScvVerificationResult _result(
  List<int> answer, {
  Uint8List? proof,
  String serverPubkey = ScvServer.primeSecurityCheckPubkey,
  DateTime? now,
}) =>
    ScvServer.resultFromVerifyResponse(
      proof ?? _proof,
      answer,
      serverPubkey: serverPubkey,
      now: now ?? _deadline,
      logger: _logs.add,
    );

void main() {
  setUp(_logs.clear);

  group('security-check /verify answer', () {
    test('a production answer verifies against the pinned server key', () {
      expect(
        _result(_productionAnswer),
        ScvVerificationResult.verificationFailed,
      );
      expect(_logs, ['Signed /verify error code 3']);
    });

    test('a signed pass is accepted', () {
      expect(
        _result(_testKeyPass, serverPubkey: _testPubkey),
        ScvVerificationResult.success,
      );
    });

    test('a forged pass is a network error', () {
      final forged = Uint8List.fromList(_productionAnswer)..[32] = 0;
      expect(_result(forged), ScvVerificationResult.networkError);
      expect(_logs, ['Rejected /verify answer: signature']);
    });

    test('a pass signed by another key is a network error', () {
      expect(_result(_testKeyPass), ScvVerificationResult.networkError);
      expect(_logs, ['Rejected /verify answer: signature']);
    });

    test('an answer for another proof is a network error', () {
      final otherProof = Uint8List.fromList(_proof)..[0] ^= 1;
      expect(
        _result(_testKeyPass, proof: otherProof, serverPubkey: _testPubkey),
        ScvVerificationResult.networkError,
      );
      expect(_logs, ['Rejected /verify answer: proof hash']);
    });

    test('an unsigned answer is a network error', () {
      expect(
        _result(_productionAnswer.sublist(0, 33)..[32] = 0),
        ScvVerificationResult.networkError,
      );
      expect(_result(const []), ScvVerificationResult.networkError);
      expect(_logs, [
        'Rejected /verify answer: length 33',
        'Rejected /verify answer: length 0',
      ]);
    });

    test('a replayed pass for a proof past its deadline is a network error',
        () {
      expect(
        _result(
          _testKeyPass,
          serverPubkey: _testPubkey,
          now: _deadline.add(const Duration(minutes: 9)),
        ),
        ScvVerificationResult.success,
      );
      expect(
        _result(
          _testKeyPass,
          serverPubkey: _testPubkey,
          now: _deadline.add(const Duration(minutes: 11)),
        ),
        ScvVerificationResult.networkError,
      );
      expect(_logs, hasLength(1));
      expect(
          _logs.single, startsWith('Rejected /verify answer: proof deadline'));
    });

    test('a signed failure stands even past the proof deadline', () {
      expect(
        _result(
          _productionAnswer,
          now: _deadline.add(const Duration(minutes: 11)),
        ),
        ScvVerificationResult.verificationFailed,
      );
    });

    test('challenge-timing codes are network errors, not tampering', () {
      expect(
        _result(_testKeyDeadlineExpired, serverPubkey: _testPubkey),
        ScvVerificationResult.networkError,
      );
      expect(
        _result(_testKeyUnknownChallenge, serverPubkey: _testPubkey),
        ScvVerificationResult.networkError,
      );
      expect(_logs, [
        'Signed /verify error code 4',
        'Signed /verify error code 6',
      ]);
    });
  });
}
