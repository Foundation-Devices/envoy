// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:http_tor/http_tor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:foundation_api/foundation_api.dart';

// Generated
part 'scv_server.g.dart';

class ScvServer {
  static HttpTor http = HttpTor(Tor.instance, EnvoyScheduler().parallel);
  static String serverAddress = "https://validate.foundation.xyz";
  static String primeSecurityCheckUrl = "https://security-check.foundation.xyz";

  final LocalStorage _ls = LocalStorage();
  static const String SCV_CHALLENGE_PREFS = "scv_challenge";
  Challenge? storedChallenge;

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
      getChallenge().then((challenge) {
        _storeChallenge(challenge);
      });
    }
  }

  void _storeChallenge(Challenge challenge) {
    storedChallenge = challenge;
    String json = jsonEncode(challenge.toJson());
    _ls.prefs.setString(SCV_CHALLENGE_PREFS, json);
  }

  bool _restoreChallege() {
    if (_ls.prefs.containsKey(SCV_CHALLENGE_PREFS)) {
      var challenge = jsonDecode(_ls.prefs.getString(SCV_CHALLENGE_PREFS)!);
      storedChallenge = Challenge.fromJson(challenge);
      return true;
    }

    return false;
  }

  void _clearChallenge() {
    if (_ls.prefs.containsKey(SCV_CHALLENGE_PREFS)) {
      _ls.prefs.remove(SCV_CHALLENGE_PREFS);
    }
  }

  Future<Challenge> getChallenge() async {
    if (storedChallenge != null) {
      return storedChallenge!;
    }

    final response = await http.get('$serverAddress/challenge');

    if (response.statusCode == 200) {
      Challenge challenge = Challenge.fromJson(jsonDecode(response.body));
      _storeChallenge(challenge);
      return challenge;
    } else {
      EnvoyReport().log("scv",
          "Failed to get challenge,status: ${response.code},body: ${response.body}");
      throw Exception('Failed to get challenge');
    }
  }

  Future<bool> validate(Challenge challenge, List<String> responseWords) async {
    // Clear stored challenge and fetch it again
    _clearChallenge();
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
          "Failed to validate challenge,status: ${response.code},body: ${response.body}");
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

      return ChallengeRequest(data: Uint8List.fromList(response.bodyBytes));
    } catch (e) {
      return null;
    }
  }

  Future<bool> isProofVerified(Uint8List data) async {
    final uri = '$primeSecurityCheckUrl/verify';

    try {
      kPrint("isProofVerified ${data.toList().length}");
      final dio = Dio();
      final payload = Uint8List.fromList([
        34,
        46,
        255,
        159,
        62,
        135,
        22,
        218,
        60,
        18,
        36,
        167,
        228,
        64,
        92,
        83,
        254,
        239,
        116,
        66,
        128,
        0,
        60,
        36,
        38,
        109,
        86,
        221,
        55,
        12,
        42,
        73,
        193,
        115,
        172,
        104,
        0,
        0,
        0,
        0,
        3,
        158,
        20,
        33,
        225,
        189,
        154,
        206,
        158,
        172,
        44,
        192,
        120,
        185,
        187,
        95,
        249,
        38,
        22,
        154,
        37,
        120,
        101,
        91,
        211,
        152,
        244,
        47,
        214,
        218,
        29,
        195,
        78,
        21,
        73,
        199,
        199,
        113,
        85,
        34,
        232,
        92,
        238,
        51,
        233,
        56,
        108,
        95,
        26,
        121,
        185,
        204,
        28,
        86,
        205,
        230,
        157,
        0,
        38,
        116,
        201,
        204,
        38,
        196,
        34,
        48,
        46,
        49,
        46,
        49,
        32,
        32,
        32,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        48,
        23,
        25,
        127,
        1,
        77,
        246,
        89,
        8,
        64,
        130,
        41,
        163,
        145,
        255,
        24,
        66,
        56,
        22,
        128,
        86,
        65,
        145,
        109,
        118,
        84,
        11,
        48,
        155,
        174,
        234,
        96,
        160,
        136,
        93,
        19,
        130,
        23,
        150,
        33,
        46,
        74,
        116,
        189,
        254,
        97,
        114,
        251,
        58,
        54,
        192,
        203,
        210,
        183,
        107,
        151,
        17,
        251,
        37,
        98,
        146,
        201,
        152,
        229
      ]);

      final response = await dio.post(
        uri,
        data: payload,
        options: Options(
          headers: {'Content-Type': 'application/octet-stream'},
          responseType: ResponseType.bytes,
        ),
      );
      //
      // final response = await http.post(
      //   uri,
      //   body: data.toList().toString(),
      //   headers: {'Content-Type': 'application/octet-stream'},
      // );

      kPrint("response status code: ${response.statusCode}");
      kPrint("response status data: ${response.data}");
      if (response.statusCode == 200) {
        List<int> rawVerificationMessage = response.data as Uint8List;
        kPrint("response status data 32: ${rawVerificationMessage[32]}");
        print("rawVerificationMessage ${rawVerificationMessage}");
        // Error code is the 33rd byte in the response
        final errorCode = rawVerificationMessage.length > 32
            ? rawVerificationMessage[32]
            : -1;
        kPrint('Error code: $errorCode');

        return errorCode == 0; // 0 means `ErrorCode::Ok`
      } else {
        kPrint('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      kPrint("failed to verify proof {e}");
      return false;
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
