// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/notifications.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:envoy/ui/lock/authenticate_page.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tor/tor.dart';

import 'business/fees.dart';
import 'business/scv_server.dart';
import 'business/video_manager.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initSingletons();

  if (LocalStorage().prefs.getBool("useLocalAuth") == true) {
    runApp(AuthenticateApp());
  } else {
    runApp(EnvoyApp());
  }
}

Future<void> initSingletons() async {
  await LocalStorage.init();
  await EnvoyStorage();
  EnvoyReport().init();
  Settings.restore();
  Tor.init();
  UpdatesManager.init();
  ScvServer.init();

  if (Settings().usingTor) {
    Tor().start();
  } else {
    Tor().disable();
  }

  Fees.restore();
  AccountManager.init();
  Notifications.init();
  VideoManager.init();
  ConnectivityManager.init();
}

class EnvoyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Portrait mode only outside of video player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

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

    return ProviderScope(
      child: NeumorphicApp(
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          debugShowCheckedModeBanner: false,
          title: 'Envoy',
          themeMode: ThemeMode.light,
          materialTheme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            }),
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
          initialRoute: LocalStorage().prefs.getBool("onboarded") == true
              ? "/"
              : "/splash",
          routes: {
            '/': (context) => HomePage(),
            '/splash': (context) => WelcomeScreen(),
          }),
    );
  }
}
