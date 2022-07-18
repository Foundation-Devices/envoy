// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:envoy/firebase_options.dart';

Future<void> _backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("Handling a background message: ${message.messageId}");
}

class Messaging {
  FirebaseMessaging _instance = FirebaseMessaging.instance;
  String currentToken = "";

  Messaging() {
    _instance.onTokenRefresh.listen((token) {
      currentToken = token;
    });

    getToken().then((token) {
      currentToken = token!;
    });

    // When app is launched from a notification
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      print("Handling an initial message!");
      if (message != null) {
        print(message.data["body"]);
      }
    });

    // When app is in background
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    // When app is in foreground
    FirebaseMessaging.onMessage.listen((event) {
      print("Handling a foreground message!");
      print(event.notification!.body);
    });
  }

  Future<bool> requestPermission() async {
    NotificationSettings settings = await _instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return false;
    }

    return true;
  }

  Future<String?> getToken() async {
    return _instance.getToken(
      vapidKey: "AIzaSyCX6kM7t26rojQssEcOA0d1u8FYm35Rtsc",
    );
  }
}
