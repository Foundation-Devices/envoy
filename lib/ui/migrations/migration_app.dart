// ignore_for_file: missing_provider_scope
// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/main.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/home/settings/logs_report.dart';
import 'package:envoy/ui/lock/authenticate_page.dart';
import 'package:envoy/ui/migrations/migration_manager.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final _migrationStreamProvider = StreamProvider<MigrationProgress>((ref) {
  return MigrationManager().migrationProgress;
});

final migrationStateProvider = Provider<MigrationProgress?>((ref) {
  return ref.watch(_migrationStreamProvider).value;
});

class MigrationApp extends StatefulWidget {
  const MigrationApp({super.key});

  @override
  State<MigrationApp> createState() => _MigrationAppState();
}

class _MigrationAppState extends State<MigrationApp> {
  @override
  void initState() {
    WakelockPlus.enable();
    super.initState();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final envoyTextTheme =
        GoogleFonts.montserratTextTheme(Theme.of(context).textTheme);

    return ProviderScope(
      child: MaterialApp(
          themeMode: ThemeMode.dark,
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
          home: Builder(builder: (c) => const MigrationAppPage())),
    );
  }
}

class MigrationAppPage extends ConsumerStatefulWidget {
  const MigrationAppPage({super.key});

  @override
  ConsumerState createState() => _MigrationAppPageState();
}

class _MigrationAppPageState extends ConsumerState<MigrationAppPage> {
  @override
  void initState() {
    super.initState();
    MigrationManager().onMigrationFinished(() async {
      await EnvoyStorage().setBool(migrationPrefs, true);
      if (LocalStorage().prefs.getBool("useLocalAuth") == true) {
        runApp(const AuthenticateApp());
      } else {
        runApp(const EnvoyApp());
      }
    });
    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      MigrationManager().migrate();
    });
  }

  @override
  Widget build(BuildContext context) {
    MigrationProgress? progress = ref.watch(migrationStateProvider);
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
                child: AppBackground(
              showRadialGradient: false,
            )),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.18,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onLongPress: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const EnvoyLogsScreen()));
                    },
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        image: DecorationImage(
                            image: ExactAssetImage('assets/logo_envoy.png'),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (progress != null)
              Positioned.fill(
                  child: Align(
                alignment: Alignment(0.0, -.1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                      width: 300,
                      child: LinearProgressIndicator(
                        value: progress.progress,
                        backgroundColor: Colors.grey.shade800,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      S().onboarding_migrating_xOfYSynced(
                          progress.completed, progress.total),
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.body.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ))
          ],
        ));
  }
}
