// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:http_tor/http_tor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:foundation_api/foundation_api.dart';
import 'package:pointycastle/export.dart'
    show
        ECCurve_secp256r1,
        ECDSASigner,
        ECPublicKey,
        ECSignature,
        PublicKeyParameter;

// Generated
part 'scv_server.g.dart';

/// Result of SCV verification that distinguishes between different error types
enum ScvVerificationResult {
  /// Verification succeeded - device is genuine
  success,

  /// Network error - couldn't reach Foundation servers
  networkError,

  /// Verification failed - device may be tampered with
  verificationFailed,
}

abstract interface class PrimeSecurityCheckService {
  Future<ChallengeRequest?> getPrimeChallenge();

  Future<ScvVerificationResult> verifyProof(Uint8List data);
}

class ScvServer implements PrimeSecurityCheckService {
  static HttpTor http = HttpTor();
  static String serverAddress = "https://validate.foundation.xyz";
  static String primeSecurityCheckUrl = "https://security-check.foundation.xyz";
  static String primeSecurityCheckOnion =
      "http://oqddiudwag2hnt7kmt4nvhrsdfmi4noar7c3fuusf4ld3yegh3teyaid.onion";

  /// Security-check server key (compressed P-256). It signs every /verify
  /// answer, and Passport Prime checks challenges against the same key.
  static const String primeSecurityCheckPubkey =
      "0356C31C74AD5CFA2481C12CB2BDD86EE2B1AF423FD1720D6F7FE1D55448B66183";

  final LocalStorage _ls = LocalStorage();
  static const String SCV_CHALLENGE_PREFS = "scv_challenge";
  Challenge? _storedChallenge;

  static final ScvServer _instance = ScvServer._internal();

  factory ScvServer() {
    return _instance;
  }

  static Future<ScvServer> init() async {
    var singleton = ScvServer._instance;
    return singleton;
  }

  ScvServer._internal() {
    kPrint("Instance of ScvServer created!");

    // Get the SCV challenge from storage
    // If not there, get it from Server and store it
    if (_restoreChallege() == false) {
      getChallenge().then((challenge) async {
        await _storeChallenge(challenge);
      });
    }
  }

  Future<void> _storeChallenge(Challenge challenge) async {
    _storedChallenge = challenge;
    String json = jsonEncode(challenge.toJson());
    await _ls.prefs.setString(SCV_CHALLENGE_PREFS, json);
  }

  bool _restoreChallege() {
    if (_ls.prefs.containsKey(SCV_CHALLENGE_PREFS)) {
      var challenge = jsonDecode(_ls.prefs.getString(SCV_CHALLENGE_PREFS)!);
      _storedChallenge = Challenge.fromJson(challenge);
      return true;
    }

    return false;
  }

  Future<void> _clearChallenge() async {
    if (_ls.prefs.containsKey(SCV_CHALLENGE_PREFS)) {
      await _ls.prefs.remove(SCV_CHALLENGE_PREFS);
    }

    _storedChallenge = null;
  }

  Future<Challenge> getChallenge() async {
    if (_storedChallenge != null) {
      return _storedChallenge!;
    }

    final response = await http.get('$serverAddress/challenge');

    if (response.statusCode == 200) {
      Challenge challenge = Challenge.fromJson(jsonDecode(response.body));
      _storeChallenge(challenge);
      return challenge;
    } else {
      EnvoyReport().log(
        "scv",
        "Failed to get challenge,status: ${response.statusCode}",
      );
      throw Exception('Failed to get challenge');
    }
  }

  Future<bool> validate(Challenge challenge, List<String> responseWords) async {
    // Clear stored challenge and fetch it again

    await _clearChallenge();
    getChallenge().then((challenge) {
      _storeChallenge(challenge);
    });

    final request = {
      'challenge': challenge.id,
      'response': responseWords,
      'derSignature': challenge.derSignature,
    };

    // TODO: parametrise the Passport batch?
    final response = await http.post(
      '$serverAddress/validate?batch=2',
      body: jsonEncode(request),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return json['isValidated'] == true;
    } else {
      EnvoyReport().log(
        "scv",
        "Failed to validate challenge,status: ${response.statusCode}",
      );
      return false;
    }
  }

  static const Duration _clearnetChallengeTimeout = Duration(seconds: 15);

  /// Checks if the Prime security check server is reachable.
  /// Returns true if we can connect to the server, false otherwise.
  Future<bool> canReachPrimeServer() async {
    final torEnabled = Settings().torEnabled();
    final baseUrl = torEnabled
        ? ScvServer.primeSecurityCheckOnion
        : ScvServer.primeSecurityCheckUrl;
    final uri = Uri.parse(baseUrl);
    final transport = torEnabled ? "tor" : "clearnet";
    _report("Prime server connectivity check started transport=$transport");

    try {
      if (torEnabled) {
        kPrint("Tor enabled, checking connectivity...");
        final response = await http
            .getForeground('$baseUrl/challenge')
            .timeout(HttpTor.foregroundTorRequestTimeout);
        final reachable = response.statusCode == 200;
        _report(
          "Prime server connectivity check completed transport=$transport "
          "status=${response.statusCode} reachable=$reachable",
        );
        return reachable;
      }

      await InternetAddress.lookup(uri.host)
          .timeout(const Duration(seconds: 15));
      final response = await http
          .get('$baseUrl/challenge')
          .timeout(_clearnetChallengeTimeout);
      final reachable = response.statusCode == 200;
      _report(
        "Prime server connectivity check completed transport=$transport "
        "status=${response.statusCode} reachable=$reachable",
      );
      return reachable;
    } catch (e, stackTrace) {
      _report(
        "Prime server connectivity check failed transport=$transport "
        "error=${e.runtimeType}",
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<ChallengeRequest?> getPrimeChallenge() async {
    final torEnabled = Settings().torEnabled();
    final baseUrl = torEnabled
        ? ScvServer.primeSecurityCheckOnion
        : ScvServer.primeSecurityCheckUrl;
    final transport = torEnabled ? "tor" : "clearnet";
    _report("Prime challenge request started transport=$transport");
    try {
      final response = torEnabled
          ? await http.getForeground('$baseUrl/challenge')
          : await http.get('$baseUrl/challenge');

      kPrint("response status code: ${response.statusCode}");
      _report(
        "Prime challenge response transport=$transport "
        "status=${response.statusCode}",
      );
      if (response.statusCode != 200) {
        return null;
      }
      final data = Uint8List.fromList(response.bodyBytes);

      kPrint("Received security challenge payload");
      _report("Prime challenge received sizeBytes=${data.length}");

      return ChallengeRequest(data: data);
    } catch (e, stackTrace) {
      _report(
        "Prime challenge request failed transport=$transport "
        "error=${e.runtimeType}",
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<bool> isProofVerified(Uint8List data) async {
    final result = await verifyProof(data);
    return result == ScvVerificationResult.success;
  }

  /// Verifies the proof and returns a detailed result
  @override
  Future<ScvVerificationResult> verifyProof(Uint8List data) async {
    if (Settings().skipPrimeSecurityCheck) {
      _report("Prime proof verification skipped by settings");
      return ScvVerificationResult.success;
    }

    final torEnabled = Settings().torEnabled();
    final baseUrl = torEnabled
        ? ScvServer.primeSecurityCheckOnion
        : ScvServer.primeSecurityCheckUrl;
    final uri = '$baseUrl/verify';
    final transport = torEnabled ? "tor" : "clearnet";
    _report(
      "Prime proof verification request started transport=$transport "
      "sizeBytes=${data.length}",
    );
    try {
      kPrint("Received proof verification payload");
      final response = await http.postBytes(
        uri,
        body: data.toList(),
        headers: {'Content-Type': 'application/octet-stream'},
        foreground: torEnabled,
      );

      kPrint("response status code: ${response.statusCode}");
      _report(
        "Prime proof verification response transport=$transport "
        "status=${response.statusCode}",
      );
      if (response.statusCode == 200) {
        kPrint("Received raw verification message");
        final result = resultFromVerifyResponse(data, response.bodyBytes);
        _report("Prime proof verification result=${result.name}");
        return result;
      } else {
        kPrint('Error: ${response.statusCode}');
        // Server returned non-200 status - treat as network/server error
        _report("Prime proof verification result=networkError");
        return ScvVerificationResult.networkError;
      }
    } catch (e, stackTrace) {
      kPrint("failed to verify proof {$e}");
      _report(
        "Prime proof verification request failed transport=$transport "
        "error=${e.runtimeType}",
        stackTrace: stackTrace,
      );
      // Exception occurred - likely network error
      return ScvVerificationResult.networkError;
    }
  }

  // Allowance for the phone clock when checking the proof's deadline.
  static const Duration _proofDeadlineGrace = Duration(minutes: 10);

  // sc-server error codes about the challenge's timing, not the device.
  static const int _deadlineExpired = 4;
  static const int _unknownChallenge = 6;

  /// Maps a /verify answer to a result. The answer is sha256(proof) | error
  /// code | P-256 signature over sha256 of the first two fields. An answer
  /// the server did not sign for [proof], or a pass for a proof past its
  /// deadline (a replay), is a network error: it must never pass a device,
  /// nor report it as tampered.
  static ScvVerificationResult resultFromVerifyResponse(
    Uint8List proof,
    List<int> response, {
    String serverPubkey = primeSecurityCheckPubkey,
    DateTime? now,
    void Function(String message)? logger,
  }) {
    final rejection =
        _answerRejection(proof, response, serverPubkey, now ?? DateTime.now());
    if (rejection != null) {
      (logger ?? _report)("Rejected /verify answer: $rejection");
      return ScvVerificationResult.networkError;
    }
    final errorCode = response[32];
    if (errorCode == 0) {
      return ScvVerificationResult.success;
    }
    (logger ?? _report)("Signed /verify error code $errorCode");
    switch (errorCode) {
      case _deadlineExpired:
      case _unknownChallenge:
        return ScvVerificationResult.networkError;
      default:
        // Signed rejection of the proof - device may be tampered
        return ScvVerificationResult.verificationFailed;
    }
  }

  static void _report(String message, {StackTrace? stackTrace}) {
    unawaited(
      EnvoyReport()
          .log("scv", message, stackTrace: stackTrace)
          .catchError((Object _, StackTrace __) {}),
    );
  }

  static String? _answerRejection(
    Uint8List proof,
    List<int> response,
    String serverPubkey,
    DateTime now,
  ) {
    if (response.length != 97) {
      return "length ${response.length}";
    }
    if (!const ListEquality<int>()
        .equals(response.sublist(0, 32), sha256.convert(proof).bytes)) {
      return "proof hash";
    }
    if (!_isSignedBy(
        serverPubkey, response.sublist(0, 33), response.sublist(33))) {
      return "signature";
    }
    // Bytes 32..40 of the proof are the server-issued challenge deadline
    // (u64 LE Unix seconds), which the signed proof hash covers. Only a pass
    // can be a replay; a signed failure stands whatever the deadline says.
    if (response[32] == 0 && proof.length >= 40) {
      final deadline = DateTime.fromMillisecondsSinceEpoch(
        ByteData.sublistView(proof, 32, 40).getUint64(0, Endian.little) * 1000,
        isUtc: true,
      );
      if (now.isAfter(deadline.add(_proofDeadlineGrace))) {
        return "proof deadline $deadline passed";
      }
    }
    return null;
  }

  static bool _isSignedBy(
    String pubkeyHex,
    List<int> message,
    List<int> signature,
  ) {
    final params = ECCurve_secp256r1();
    final pubkey = ECPublicKey(
      params.curve.decodePoint([
        for (var i = 0; i < pubkeyHex.length; i += 2)
          int.parse(pubkeyHex.substring(i, i + 2), radix: 16),
      ]),
      params,
    );
    BigInt toBigInt(List<int> bytes) => bytes.fold(
        BigInt.zero, (value, byte) => (value << 8) | BigInt.from(byte));
    // No digest in the signer: it verifies the sha256 prehash as given.
    final verifier = ECDSASigner()
      ..init(false, PublicKeyParameter<ECPublicKey>(pubkey));
    return verifier.verifySignature(
      Uint8List.fromList(sha256.convert(message).bytes),
      ECSignature(
        toBigInt(signature.sublist(0, 32)),
        toBigInt(signature.sublist(32)),
      ),
    );
  }
}

@JsonSerializable()
class Challenge {
  @JsonKey(name: "challenge")
  final String id;
  final String signature;
  final String derSignature;

  Challenge(this.id, this.signature, this.derSignature);

  // Generated
  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeToJson(this);
}
