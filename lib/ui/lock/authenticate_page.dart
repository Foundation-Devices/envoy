// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/main.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';

import '../../generated/l10n.dart';

class AuthenticateApp extends StatelessWidget {
  const AuthenticateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemStatusBarContrastEnforced: true,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark));

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);

    final envoyAccentColor = EnvoyColors.darkTeal;
    final envoyVariantColor = EnvoyColors.darkCopper;
    final envoyBaseColor = Colors.transparent;
    final envoyTextTheme =
        GoogleFonts.montserratTextTheme(Theme.of(context).textTheme);

    return NeumorphicApp(
        materialTheme: ThemeData(
          primaryColor: envoyAccentColor,
          brightness: Brightness.light,
          textTheme: envoyTextTheme,
          scaffoldBackgroundColor: envoyBaseColor,
        ),
        theme: NeumorphicThemeData(
          textTheme: envoyTextTheme,
          baseColor: envoyBaseColor,
          accentColor: envoyAccentColor,
          variantColor: envoyVariantColor,
          depth: 0, // Flat for now
        ),
        home: Builder(builder: (c) => AuthenticatePage()));
  }
}

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
              biometricOnly: true,
              stickyAuth: true,
            ),
            localizedReason: 'Authenticate to Access Envoy');
        if (didAuthenticate) {
          if (Platform.isIOS) {
            await Future.delayed(Duration(milliseconds: 800));
          }
          runApp(EnvoyApp());
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
      final bool didAuthenticate = await auth.authenticate(
          options: AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
          localizedReason: 'Authenticate to Access Envoy');
      if (didAuthenticate) {
        runApp(EnvoyApp());
        return;
      } else {
        showAuthFailed();
      }
      return;
    }
  }

  void showAuthFailed() {
    showEnvoyDialog(
        dismissible: false,
        context: context,
        cardColor: EnvoyColors.white100,
        dialog: Builder(
          builder: (context) {
            return Theme(
              data: ThemeData.light(),
              child: Container(
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
                      title: Text(S().launch_screen_faceID_fail_heading,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.black87),
                          textAlign: TextAlign.center),
                      subtitle: Text(S().launch_screen_faceID_fail_subheading,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Colors.black87),
                          textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: EnvoyButton(
                        S().launch_screen_faceID_fail_CTA,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        onTap: () async {
                          Navigator.pop(context);
                          initiateAuth();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
        runApp(EnvoyApp());
      }
    });
  }
}
