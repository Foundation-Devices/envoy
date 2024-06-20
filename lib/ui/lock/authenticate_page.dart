// ignore_for_file: missing_provider_scope
// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:ui';

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/main.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
        debugShowCheckedModeBanner: false,
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
  ///[sessionAuthenticate] will show a overlay to prevent user interaction
  ///if this is set to true, after successful authentication navigator
  ///will pop the blur overlay
  final bool sessionAuthenticate;

  const AuthenticatePage({super.key, this.sessionAuthenticate = false});

  @override
  State<AuthenticatePage> createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  @override
  Widget build(BuildContext context) {
    if (widget.sessionAuthenticate) {
      return PopScope(
        canPop: false,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 400),
          tween: Tween<double>(begin: 0, end: 14),
          builder: (context, value, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
              child: child,
            );
          },
          child: const DecoratedBox(
              decoration: BoxDecoration(
            color: Colors.black12,
          )),
        ),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
            image: ExactAssetImage('assets/splash_blank.png'),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high),
      ),
    );
  }

  void initiateAuth() async {
    final navigator = Navigator.of(context);
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
          if (widget.sessionAuthenticate && navigator.mounted) {
            navigator.pop();
          } else {
            runApp(const EnvoyApp());
          }
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
        if (widget.sessionAuthenticate && navigator.mounted) {
          navigator.pop();
        } else {
          runApp(const EnvoyApp());
        }
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      bool? useAuth = LocalStorage().prefs.getBool("useLocalAuth");
      if (useAuth == true) {
        initiateAuth();
      } else {
        runApp(const EnvoyApp());
      }
    });
  }
}
