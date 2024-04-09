// ignore_for_file: missing_provider_scope
// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/main.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';

class AuthenticateApp extends StatelessWidget {
  const AuthenticateApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemStatusBarContrastEnforced: true,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark));

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);

    final envoyTextTheme =
        GoogleFonts.montserratTextTheme(Theme.of(context).textTheme);

    return MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        theme: ThemeData(
          textTheme: envoyTextTheme,
          primaryColor: EnvoyColors.accentPrimary,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: Builder(builder: (c) => const AuthenticatePage()));
  }
}

class AuthenticatePage extends StatefulWidget {
  const AuthenticatePage({super.key});

  @override
  State<AuthenticatePage> createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage>
    with WidgetsBindingObserver {
  bool? useAuth = LocalStorage().prefs.getBool("useLocalAuth");

  Timer? _authTimer;
  bool _wasAuthMoreThan1minAgo = true;

  void _startAuthTimer() {
    _authTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      _wasAuthMoreThan1minAgo = true;
    });
  }

  void _stopAuthTimer() {
    _wasAuthMoreThan1minAgo = false;
    _authTimer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (useAuth == true) {
        initiateAuth();
      } else {
        runApp(const EnvoyApp());
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    useAuth = LocalStorage()
        .prefs
        .getBool("useLocalAuth"); // update useAuth on state change too

    switch (state) {
      case AppLifecycleState.paused:
        if (useAuth == true) {
          _wasAuthMoreThan1minAgo = false;
          _startAuthTimer();
        }
        break;
      case AppLifecycleState.resumed:
        if (_wasAuthMoreThan1minAgo && useAuth == true) {
          initiateAuth();
        } else {
          _stopAuthTimer();
        }
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: EnvoyColors.textPrimaryInverse,
        image: DecorationImage(
            image: ExactAssetImage('assets/splash_blank.png'),
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
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
            ),

            ///TODO: localize this
            localizedReason: 'Authenticate to Access Envoy');
        if (didAuthenticate) {
          if (Platform.isIOS) {
            await Future.delayed(const Duration(milliseconds: 800));
          }
          runApp(const EnvoyApp());
          _stopAuthTimer();
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
            icon: EnvoyIcons.info,
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
            icon: EnvoyIcons.stop_watch,
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
            icon: EnvoyIcons.info,
          );
        } else {
          showAuthLockedOutDialog(
            ctaButtonTitle: S().launch_screen_faceID_fail_CTA,
            ctaTapCallback: null,
            title: S().launch_screen_faceID_fail_heading,
            subtitle: S().launch_screen_faceID_fail_subheading,
            icon: EnvoyIcons.info,
          );
        }
      } on Exception {
        /// display the dialogue without a 'Try Again' button, as the authentication failed due to an exception."
        showAuthLockedOutDialog(
          ctaButtonTitle: S().launch_screen_faceID_fail_CTA,
          ctaTapCallback: null,
          title: S().launch_screen_faceID_fail_heading,
          subtitle: S().launch_screen_faceID_fail_subheading,
          icon: EnvoyIcons.info,
        );
      }
    } else {
      ///Authenticate without biometrics
      final bool didAuthenticate = await auth.authenticate(
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
          localizedReason: 'Authenticate to Access Envoy');
      if (didAuthenticate) {
        runApp(const EnvoyApp());
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
          icon: EnvoyIcons.info,
        );
      }
      return;
    }
  }

  void showAuthLockedOutDialog(
      {required String title,
      required String subtitle,
      required String ctaButtonTitle,
      GestureTapCallback? ctaTapCallback,
      required EnvoyIcons icon}) {
    showEnvoyDialog(
        dismissible: false,
        context: context,
        cardColor: EnvoyColors.textPrimaryInverse,
        dialog: Builder(
          builder: (context) {
            return Theme(
              data: ThemeData.light(),
              child: Container(
                height: 310,
                width: MediaQuery.of(context).size.width * .8,
                padding: const EdgeInsets.all(EnvoySpacing.medium2)
                    .add(const EdgeInsets.only(top: -6)),
                constraints: const BoxConstraints(
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
                        EnvoyIcon(
                          icon,
                          size: EnvoyIconSize.big,
                          color: EnvoyColors.accentPrimary,
                        ),
                        const SizedBox(height: EnvoySpacing.medium2),
                        ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          title: Text(title,
                              style: EnvoyTypography.subheading
                                  .copyWith(color: EnvoyColors.textPrimary),
                              textAlign: TextAlign.center),
                          subtitle: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(subtitle,
                                style: EnvoyTypography.info
                                    .copyWith(color: EnvoyColors.textPrimary),
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    )),
                    ctaTapCallback != null
                        ? EnvoyButton(
                            ctaButtonTitle,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            type: EnvoyButtonTypes.primaryModal,
                            onTap: ctaTapCallback,
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
