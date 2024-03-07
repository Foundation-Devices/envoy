// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names
library envoy.scv_server;

import 'dart:convert';
import 'package:envoy/util/console.dart';
import 'package:http_tor/http_tor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/scheduler.dart';

// Generated
part 'scv_server.g.dart';

class ScvServer {
  static HttpTor http = HttpTor(Tor.instance, EnvoyScheduler().parallel);
  static String serverAddress = "https://validate.foundationdevices.com";

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

  _storeChallenge(Challenge challenge) {
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

  _clearChallenge() {
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
