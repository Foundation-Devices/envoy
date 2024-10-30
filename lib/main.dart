// ignore_for_file: missing_provider_scope
// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/keys_manager.dart';
import 'package:envoy/business/map_data.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/notifications.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/lock/authenticate_page.dart';
import 'package:envoy/ui/routes/route_state.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tor/tor.dart';
import 'package:tor/util.dart';

import 'business/fees.dart';
import 'business/scv_server.dart';
import 'business/feed_manager.dart';
import 'generated/l10n.dart';

import 'package:timeago/timeago.dart' as timeago;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initSingletons();

  if (LocalStorage().prefs.getBool("useLocalAuth") == true) {
    runApp(const AuthenticateApp());
  } else {
    runApp(const EnvoyApp());
  }
  listenToRouteChanges();
}

Future<void> initSingletons() async {
  // This is notoriously low on iOS, causing 'too many open files errors'
  kPrint("Process nofile_limit: ${getNofileLimit()}");

  // Requesting a high number. The API will return the best we can get
  // ~10k on iPhone 11 which is much better than the default 256
  kPrint("Process nofile_limit bumped to: ${setNofileLimit(16384)}");

  await EnvoyStorage().init();
  await LocalStorage.init();
  EnvoyScheduler.init();
  await KeysManager.init();
  await ExchangeRate.init();
  EnvoyReport().init();
  Settings.restore();
  Tor.init(enabled: Settings().torEnabled());
  UpdatesManager.init();
  ScvServer.init();
  await EnvoySeed.init();
  await FMTCObjectBoxBackend().initialise();
  await const FMTCStore('mapStore').manage.create();

  // Start Tor regardless of whether we are using it or not
  try {
    Tor.instance.start();
  } on Exception catch (e) {
    EnvoyReport().log("tor", e.toString());
  }

  Fees.restore();
  AccountManager.init();
  Notifications.init();
  FeedManager.init();
  MapData.init();
  ConnectivityManager.init();
}

class EnvoyApp extends StatelessWidget {
  const EnvoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Portrait mode only outside of video player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark));

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    const envoyAccentColor = EnvoyColors.accentPrimary;
    const envoyBaseColor = Colors.transparent;
    final envoyTextTheme =
        GoogleFonts.montserratTextTheme(Theme.of(context).textTheme);

    // timeago requires this for any language that's not english or spanish
    timeago.setLocaleMessages('ca', timeago.CaMessages());

    return ProviderScope(
      child: MaterialApp.router(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        debugShowCheckedModeBanner: false,
        title: 'Envoy',
        themeMode: ThemeMode.light,
        theme: ThemeData(
            textTheme: envoyTextTheme,
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            }),
            primaryColor: envoyAccentColor,
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black, elevation: 0, centerTitle: true),
            scaffoldBackgroundColor: envoyBaseColor,
            useMaterial3: false),
        routerConfig: mainRouter,
        scrollBehavior: GlobalScrollBehavior(),
      ),
    );
  }
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return GlowingOverscrollIndicator(
      axisDirection: AxisDirection.right,
      color: EnvoyColors.textPrimaryInverse,
      showLeading: false,
      child: child, // Turn off overscroll indicator
    );
  }
}
