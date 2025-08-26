// ignore_for_file: missing_provider_scope
// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/bluetooth_manager.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/keys_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/map_data.dart';
import 'package:envoy/business/notifications.dart';
import 'package:envoy/business/prime_shard.dart';
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
import 'package:rive/rive.dart';
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
  if (await MigrationManager().isMigrationRequired()) {
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


  try {
    const String primeSecurityCheckUrl = "https://security-check.foundation.xyz";
    final uri = '$primeSecurityCheckUrl/verify';

    final dio = Dio();
    final payload = Uint8List.fromList([34, 46, 255, 159, 62, 135, 22, 218, 60, 18, 36, 167, 228, 64, 92, 83, 254, 239, 116, 66, 128, 0, 60, 36, 38, 109, 86, 221, 55, 12, 42, 73, 193, 115, 172, 104, 0, 0, 0, 0, 3, 158, 20, 33, 225, 189, 154, 206, 158, 172, 44, 192, 120, 185, 187, 95, 249, 38, 22, 154, 37, 120, 101, 91, 211, 152, 244, 47, 214, 218, 29, 195, 78, 21, 73, 199, 199, 113, 85, 34, 232, 92, 238, 51, 233, 56, 108, 95, 26, 121, 185, 204, 28, 86, 205, 230, 157, 0, 38, 116, 201, 204, 38, 196, 34, 48, 46, 49, 46, 49, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 48, 23, 25, 127, 1, 77, 246, 89, 8, 64, 130, 41, 163, 145, 255, 24, 66, 56, 22, 128, 86, 65, 145, 109, 118, 84, 11, 48, 155, 174, 234, 96, 160, 136, 93, 19, 130, 23, 150, 33, 46, 74, 116, 189, 254, 97, 114, 251, 58, 54, 192, 203, 210, 183, 107, 151, 17, 251, 37, 98, 146, 201, 152, 229]);

    print("SCV verify");
    final response = await dio.post(
        uri,
        data: payload,
        options: Options(
          headers: {'Content-Type': 'binary/octet-stream'},
          responseType: ResponseType.bytes,
        ),
      );
    print("SCV verify: response ${response.data}");
    print("SCV verify: response length ${response.data.length}");
    print("SCV verify: index 32 ${response.data[32]}");
  } catch (e) {
    print(e);
  }



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
  unawaited(RiveFile.initialize());
  NgAccountManager.init();

  if (!(await MigrationManager().isMigrationRequired())) {
    kPrint("Restoring accounts");
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
  await PrimeShard.init();
  await FMTCObjectBoxBackend().initialise();
  await const FMTCStore('mapStore').manage.create();

  //TODO:Remove,
  // Shards testing...
  // await PrimeShard().addShard(
  //     shard: [1, 234, 3, 4, 4], shardIdentifier: "xnc", deviceSerial: "test");
  // print("all ${await PrimeShard().getAllShards()}");
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
