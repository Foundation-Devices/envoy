// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/home/settings/backup/backup_page.dart';
import 'package:envoy/ui/home/settings/settings_page.dart';
import 'package:envoy/ui/home/settings/support_page.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/home/settings/about_page.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/ui/home/home_state.dart';

class SettingsMenu extends ConsumerStatefulWidget {
  const SettingsMenu({super.key});

  @override
  ConsumerState<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends ConsumerState<SettingsMenu> {
  Widget _currentPage = const SettingsMenuWidget();

  void _goBackToMenu() {
    ref.read(homePageBackgroundProvider.notifier).state =
        HomePageBackgroundState.menu;
    Settings().store();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<HomePageBackgroundState>(homePageBackgroundProvider, (_, next) {
      selectPage(next, context);
    });

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _currentPage,
    );
  }

  @override
  void initState() {
    selectPage(ref.read(homePageBackgroundProvider), context);
    super.initState();
  }

  void selectPage(HomePageBackgroundState state, BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (state) {
        case HomePageBackgroundState.menu:
          setState(() {
            _currentPage = const SettingsMenuWidget();
            HomePageNotification(
                    leftFunction: null, title: S().menu_heading.toUpperCase())
                .dispatch(context);
            ref.read(homePageTitleProvider.notifier).state =
                S().menu_heading.toUpperCase();
          });
          break;
        case HomePageBackgroundState.settings:
          setState(() {
            _currentPage = SettingsPage();
            HomePageNotification(leftFunction: _goBackToMenu).dispatch(context);
            ref.read(homePageTitleProvider.notifier).state = S().menu_settings;
          });
          break;
        case HomePageBackgroundState.backups:
          setState(() {
            _currentPage = BackupPage();
            HomePageNotification(leftFunction: _goBackToMenu).dispatch(context);
            ref.read(homePageTitleProvider.notifier).state = S().menu_backups;
          });
          break;
        case HomePageBackgroundState.support:
          setState(() {
            _currentPage = SupportPage();
            HomePageNotification(leftFunction: _goBackToMenu).dispatch(context);
            ref.read(homePageTitleProvider.notifier).state =
                S().menu_support.toUpperCase();
          });
          break;
        case HomePageBackgroundState.about:
          setState(() {
            _currentPage = AboutPage();
            HomePageNotification(leftFunction: _goBackToMenu).dispatch(context);
            ref.read(homePageTitleProvider.notifier).state = S().menu_about;
          });
          break;
        default:
          break;
      }
    });
  }
}

class SettingsMenuWidget extends ConsumerWidget {
  const SettingsMenuWidget({super.key});

  @override
  Widget build(context, ref) {
    var background = ref.read(homePageBackgroundProvider.notifier);
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 50),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 9),
                  MenuOption(
                    label: S().menu_settings.toUpperCase(),
                    onTap: () {
                      background.state = HomePageBackgroundState.settings;
                    },
                  ),
                  if (EnvoySeed().walletDerived())
                    MenuOption(
                      label: S().menu_backups.toUpperCase(),
                      onTap: () {
                        background.state = HomePageBackgroundState.backups;
                      },
                    ),
                  const SizedBox(height: 0),
                  MenuOption(
                    label: S().menu_support.toUpperCase(),
                    onTap: () {
                      background.state = HomePageBackgroundState.support;
                    },
                  ),
                  const SizedBox(height: 0),
                  MenuOption(
                    label: S().menu_about.toUpperCase(),
                    onTap: () {
                      background.state = HomePageBackgroundState.about;
                    },
                  ),
                ]),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        launchUrl(
                            Uri.parse("https://twitter.com/FOUNDATIONdvcs"));
                      },
                      child: SvgPicture.asset(
                        "assets/menu_x.svg",
                        width: 40,
                        color: EnvoyColors.textSecondary,
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                        onTap: () {
                          launchUrl(Uri.parse(
                              "https://github.com/Foundation-Devices"));
                        },
                        child: Image.asset(
                          "assets/github.png",
                          width: 40,
                          color: EnvoyColors.textTertiary,
                        )),
                  ),
                  GestureDetector(
                      onTap: () {
                        launchUrl(
                            Uri.parse("https://telegram.me/foundationdevices"),
                            mode: LaunchMode.externalApplication);
                      },
                      child: SvgPicture.asset(
                        "assets/telegram.svg",
                        width: 40,
                        color: EnvoyColors.textTertiary,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuOption extends StatelessWidget {
  final String label;
  final Function() onTap;

  const MenuOption({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 25, bottom: 25),
        margin: const EdgeInsets.only(left: 18),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 142),
                child: Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: EnvoyColors.textPrimaryInverse,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: EnvoyColors.textPrimaryInverse,
                  size: 16,
                ),
              )
            ]),
      ),
    );
  }
}
