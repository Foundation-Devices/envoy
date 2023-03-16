// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';

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
            localizedReason: 'Authenticate to Access Envoy');
        if (didAuthenticate) {
          if (Platform.isIOS) {
            await Future.delayed(Duration(milliseconds: 800));
          }
          goSplashOrGoHome();
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
            content: Text("Please Enable Biometrics to Unlock Envoy"),
            actions: [
              EnvoyButton(
                "Open Settings",
                borderRadius: BorderRadius.all(Radius.circular(8)),
                onTap: () async {
                  openAppSettings();
                },
              ),
            ],
          ));
    }
  }

  void showAuthFailed() {
    showEnvoyDialog(
        dismissible: false,
        context: context,
        dialog: Container(
          height: 320,
          width: MediaQuery.of(context).size.width * .8,
          padding: EdgeInsets.all(28).add(EdgeInsets.only(top: -6)),
          constraints: BoxConstraints(
            minHeight: 270,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                Icons.error_outline,
                color: EnvoyColors.darkTeal,
                size: 84,
              ),
              ListTile(
                title: Text("Authentication Failed",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center),
                subtitle: Text("Please try again",
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: EnvoyButton(
                  "Try Again",
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  onTap: () async {
                    Navigator.pop(context);
                    initiateAuth();
                  },
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      bool? useAuth = LocalStorage().prefs.getBool("useLocalAuth");
      if (useAuth == true) {
        initiateAuth();
      } else {
        goSplashOrGoHome();
      }
    });
  }

  void goSplashOrGoHome() {
    if (LocalStorage().prefs.containsKey("onboarded")) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } else {
      Navigator.pushReplacementNamed(context, '/splash');
    }
  }
}
