// ignore_for_file: missing_provider_scope
// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/bluetooth_manager.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/keys_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/map_data.dart';
import 'package:envoy/business/notifications.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/lock/authenticate_page.dart';
import 'package:envoy/ui/migrations/migration_app.dart';
import 'package:envoy/ui/migrations/migration_manager.dart';
import 'package:envoy/ui/routes/route_state.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/widgets/envoy_page_transition.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/ntp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tor/tor.dart';

import 'business/feed_manager.dart';
import 'business/fees.dart';
import 'business/scv_server.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initSingletons();
  } catch (e, stack) {
    EnvoyReport().log("Envoy init", stack.toString());
  }
  if (await isMigrationRequired()) {
    runApp(MigrationApp());
  } else if (LocalStorage().prefs.getBool("useLocalAuth") == true) {
    runApp(const AuthenticateApp());
  } else {
    //fresh install,already passed migration check
    EnvoyStorage().setNoBackUpPreference(
        MigrationManager.migrationPrefs, MigrationManager.migrationVersion);
    runApp(const EnvoyApp());
  }

  listenToRouteChanges();
}

Future<void> initSingletons({bool integrationTestsRunning = false}) async {
  await EnvoyStorage().init();

  if (!integrationTestsRunning) {
    try {
      await BluetoothManager.init();
    } catch (e, stack) {
      kPrint("Error initializing BluetoothManager: $e", stackTrace: stack);
    }
  }
  // // This is notoriously low on iOS, causing 'too many open files errors'
  // kPrint("Process nofile_limit: ${getNofileLimit()}");
  //
  // // Requesting a high number. The API will return the best we can get
  // // ~10k on iPhone 11 which is much better than the default 256
  // kPrint("Process nofile_limit bumped to: ${setNofileLimit(16384)}");
  //
  await LocalStorage.init();

  NgAccountManager.init();

  if (!(await isMigrationRequired())) {
    await NgAccountManager().restore();
  }
  await NTPUtil.init();
  EnvoyScheduler.init();
  await KeysManager.init();
  await Settings.restore();
  await ExchangeRate.init();

  if (!integrationTestsRunning) {
    try {
      BluetoothManager().setupExchangeRateListener();
    } catch (e, stack) {
      kPrint("Error setting up exchange rate listener: $e", stackTrace: stack);
    }
  }

  EnvoyReport().init();
  Tor.init(enabled: Settings().torEnabled());
  UpdatesManager.init();
  ScvServer.init();
  await EnvoySeed.init();
  await FMTCObjectBoxBackend().initialise();
  await const FMTCStore('mapStore').manage.create();

  // Start Tor regardless of whether we are using it or not
  try {
    Tor.instance.start();
  } on Exception catch (e, stack) {
    kPrint("Error starting Tor: $e", stackTrace: stack);
  }

  Fees.restore();
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
              TargetPlatform.android: EnvoyOpenUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: EnvoyOpenUpwardsPageTransitionsBuilder(),
              TargetPlatform.linux: EnvoyOpenUpwardsPageTransitionsBuilder(),
              TargetPlatform.macOS: EnvoyOpenUpwardsPageTransitionsBuilder(),
              TargetPlatform.windows: EnvoyOpenUpwardsPageTransitionsBuilder(),
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

Future<bool> isMigrationRequired() async {
  //check if the user already has accounts
  final hasAccounts =
      LocalStorage().prefs.containsKey(NgAccountManager.v1AccountsPrefKey);
  //check if the user has already migrated

  final hasMigrated = (await EnvoyStorage()
          .getNoBackUpPreference(MigrationManager.migrationPrefs)) ==
      MigrationManager.migrationVersion;

  return hasAccounts && !hasMigrated;
}
