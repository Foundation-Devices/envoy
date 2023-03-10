// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticatePage extends StatefulWidget {
  const AuthenticatePage({Key? key}) : super(key: key);

  @override
  State<AuthenticatePage> createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: new DecorationImage(
            image: new ExactAssetImage('assets/splash_blank.png'),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high),
      ),
    );
  }

  void initiateAuth() async {
    final LocalAuthentication auth = LocalAuthentication();
    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
    if (availableBiometrics.isNotEmpty) {
      try {
        final bool didAuthenticate = await auth.authenticate(
            options: AuthenticationOptions(
              biometricOnly: false,
              stickyAuth: true,
            ),
            localizedReason: 'Authenticate to access envoy');
        if (didAuthenticate) {
          if (Platform.isIOS) {
            await Future.delayed(Duration(milliseconds: 800));
          }
          Navigator.pushReplacementNamed(context, '/');
          return;
        } else {
          showAuthFailed();
        }
      } on PlatformException {
        showAuthFailed();
      } on Exception catch (e) {
        print("$e");
      }
    } else {
      showEnvoyDialog(
          context: context,
          dismissible: false,
          dialog: EnvoyDialog(
            title: "Biometrics Disabled",
            dismissible: false,
            content: Text("Please enable biometrics to unclock envoy"),
          ));
    }
  }

  void showAuthFailed() {
    showEnvoyDialog(
        context: context,
        dialog: EnvoyDialog(
          title: "Authentication Failed",
          content: Text("Please try Again"),
          actions: [
            EnvoyButton(
              "Try Again",
              light: false,
              borderRadius: BorderRadius.all(Radius.circular(8)),
              onTap: () async {
                Navigator.pop(context);
                initiateAuth();
              },
            ),
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      LocalStorage().readSecure("useLocalAuth").then((value) {
        if (value == "true") {
          initiateAuth();
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
      });
    });
  }
}
