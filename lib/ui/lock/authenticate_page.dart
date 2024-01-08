// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/main.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

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
    final envoyBaseColor = Colors.transparent;
    final envoyTextTheme =
        GoogleFonts.montserratTextTheme(Theme.of(context).textTheme);

    return MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        theme: ThemeData(
          textTheme: envoyTextTheme,
          primaryColor: envoyAccentColor,
          brightness: Brightness.light,
          scaffoldBackgroundColor: envoyBaseColor,
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

            ///TODO: localize this
            localizedReason: 'Authenticate to Access Envoy');
        if (didAuthenticate) {
          if (Platform.isIOS) {
            await Future.delayed(Duration(milliseconds: 800));
          }
          runApp(EnvoyApp());
          return;
        } else {
          showAuthLockedOutDialog(
            ctaButtonTitle: S().launch_screen_faceID_fail_CTA,
            ctaTapCallback: () {
              Navigator.pop(context);
              initiateAuth();
            },
            title: S().launch_screen_faceID_fail_heading,
            subtitle: S().launch_screen_faceID_fail_subheading,
            icon: Icons.error_outline,
          );
          return;
        }
      } on PlatformException catch (e) {
        ///if the user is locked out due to too many attempts, show exit dialog
        if (e.code == auth_error.lockedOut ||
            e.code == auth_error.permanentlyLockedOut) {
          showAuthLockedOutDialog(
            ctaButtonTitle: "",
            ctaTapCallback: null,

            ///TODO: localize this
            title: "Locked Out",
            subtitle: Platform.isIOS

                ///TODO: localize this
                ? "Biometric authentication is disabled. Please lock and unlock your screen to enable it."
                : "Biometric authentication is disabled. Please wait 30 seconds before trying again.",
            icon: Icons.timer,
          );
        } else if (e.code == auth_error.notAvailable) {
          /// use dismissed the biometric prompt
          showAuthLockedOutDialog(
            ctaButtonTitle: S().launch_screen_faceID_fail_CTA,
            ctaTapCallback: () {
              Navigator.pop(context);
              initiateAuth();
            },
            title: S().launch_screen_faceID_fail_heading,
            subtitle: S().launch_screen_faceID_fail_subheading,
            icon: Icons.error_outline,
          );
        } else {
          showAuthLockedOutDialog(
            ctaButtonTitle: S().launch_screen_faceID_fail_CTA,
            ctaTapCallback: null,
            title: S().launch_screen_faceID_fail_heading,
            subtitle: S().launch_screen_faceID_fail_subheading,
            icon: Icons.error_outline,
          );
        }
      } on Exception {
        /// display the dialogue without a 'Try Again' button, as the authentication failed due to an exception."
        showAuthLockedOutDialog(
          ctaButtonTitle: S().launch_screen_faceID_fail_CTA,
          ctaTapCallback: null,
          title: S().launch_screen_faceID_fail_heading,
          subtitle: S().launch_screen_faceID_fail_subheading,
          icon: Icons.error_outline,
        );
      }
    } else {
      ///Authenticate without biometrics
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
        showAuthLockedOutDialog(
          ctaButtonTitle: S().launch_screen_faceID_fail_CTA,
          ctaTapCallback: () {
            Navigator.pop(context);
            initiateAuth();
          },
          title: S().launch_screen_faceID_fail_heading,
          subtitle: S().launch_screen_faceID_fail_subheading,
          icon: Icons.error_outline,
        );
      }
      return;
    }
  }

  void showAuthLockedOutDialog(
      {required String title,
      required String subtitle,
      required String ctaButtonTitle,
      GestureTapCallback? ctaTapCallback = null,
      required IconData icon}) {
    showEnvoyDialog(
        dismissible: false,
        context: context,
        cardColor: EnvoyColors.white100,
        dialog: Builder(
          builder: (context) {
            return Theme(
              data: ThemeData.light(),
              child: Container(
                height: 310,
                width: MediaQuery.of(context).size.width * .8,
                padding: EdgeInsets.all(28).add(EdgeInsets.only(top: -6)),
                constraints: BoxConstraints(
                  minHeight: 270,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          color: EnvoyColors.darkTeal,
                          size: 68,
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Text(title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.black87),
                              textAlign: TextAlign.center),
                          subtitle: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: Colors.black87),
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    )),
                    ctaTapCallback != null
                        ? EnvoyButton(
                            ctaButtonTitle,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            type: EnvoyButtonTypes.primaryModal,
                            onTap: ctaTapCallback,
                          )
                        : SizedBox.shrink(),
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
