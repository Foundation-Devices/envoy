library envoy.scv_server;

import 'dart:convert';
import 'package:http_tor/http_tor.dart';
import 'package:tor/tor.dart';

class ScvServer {
  static HttpTor http = HttpTor(Tor());
  static String serverAddress = "https://validate.foundationdevices.com";

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
    print("Instance of ScvServer created!");

    // Go get the challenge from Server and store it
    getChallenge().then((challenge) {
      storedChallenge = challenge;
    });
  }

  Future<Challenge> getChallenge() async {
    if (storedChallenge != null) {
      return storedChallenge!;
    }

    final response = await http.get(serverAddress + '/challenge');

    if (response.statusCode == 200) {
      Challenge challenge = Challenge.fromJson(jsonDecode(response.body));
      storedChallenge = challenge;
      return challenge;
    } else {
      throw Exception('Failed to get challenge');
    }
  }

  Future<bool> validate(Challenge challenge, List<String> responseWords) async {
    // Clear stored challenge and fetch it again
    storedChallenge = null;
    getChallenge().then((challenge) {
      storedChallenge = challenge;
    });

    final request = {
      'challenge': challenge.id,
      'response': responseWords,
      'derSignature': challenge.derSignature,
    };

    // TODO: parametrise the Passport batch?
    final response = await http.post(serverAddress + '/validate?batch=2',
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

class Challenge {
  final String id;
  final String signature;
  final String derSignature;

  Challenge(this.id, this.signature, this.derSignature);

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
        json['challenge'], json['signature'], json['derSignature']);
  }
}
