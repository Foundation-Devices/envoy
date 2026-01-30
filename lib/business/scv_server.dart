// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:http_tor/http_tor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:foundation_api/foundation_api.dart';

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

class ScvServer {
  static HttpTor http = HttpTor();
  static String serverAddress = "https://validate.foundation.xyz";
  static String primeSecurityCheckUrl = "https://security-check.foundation.xyz";

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
      EnvoyReport().log("scv",
          "Failed to get challenge,status: ${response.statusCode},body: ${response.body}");
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
    final response = await http.post('$serverAddress/validate?batch=2',
        body: jsonEncode(request),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8'
        });

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return json['isValidated'] == true;
    } else {
      EnvoyReport().log("scv",
          "Failed to validate challenge,status: ${response.statusCode},body: ${response.body}");
      return false;
    }
  }

  Future<ChallengeRequest?> getPrimeChallenge() async {
    try {
      final response = await http.get('$primeSecurityCheckUrl/challenge');

      kPrint("response status code: ${response.statusCode}");
      if (response.statusCode != 200) {
        return null;
      }
      final data = Uint8List.fromList(response.bodyBytes);

      final dataStr = data.map((d) => d.toString()).join(",");
      kPrint("security challenge payload $dataStr");

      return ChallengeRequest(data: data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isProofVerified(Uint8List data) async {
    final result = await verifyProof(data);
    return result == ScvVerificationResult.success;
  }

  /// Verifies the proof and returns a detailed result
  Future<ScvVerificationResult> verifyProof(Uint8List data) async {
    if (Settings().skipPrimeSecurityCheck) {
      return ScvVerificationResult.success;
    }

    final uri = '$primeSecurityCheckUrl/verify';
    final dataStr = data.map((d) => d.toString()).join(",");

    try {
      kPrint("isProofVerified payload $dataStr");
      final response = await http.postBytes(
        uri,
        body: data.toList(),
        headers: {'Content-Type': 'application/octet-stream'},
      );

      kPrint("response status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        List<int> rawVerificationMessage = response.bodyBytes;
        kPrint("response status data 32: ${rawVerificationMessage[32]}");
        kPrint("rawVerificationMessage $rawVerificationMessage");
        // Error code is the 33rd byte in the response
        final errorCode = rawVerificationMessage.length > 32
            ? rawVerificationMessage[32]
            : -1;
        kPrint('Error code: $errorCode');
        if (errorCode == 0) {
          return ScvVerificationResult.success;
        } else {
          // Server responded but verification failed - device may be tampered
          return ScvVerificationResult.verificationFailed;
        }
      } else {
        kPrint('Error: ${response.statusCode}');
        // Server returned non-200 status - treat as network/server error
        return ScvVerificationResult.networkError;
      }
    } catch (e) {
      kPrint("failed to verify proof {$e}");
      // Exception occurred - likely network error
      return ScvVerificationResult.networkError;
    }
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
