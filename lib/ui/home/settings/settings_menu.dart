// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/home/settings/backup/backup_page.dart';
import 'package:envoy/ui/home/settings/settings_page.dart';
import 'package:envoy/ui/home/settings/support_page.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/util/easing.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/home/settings/about_page.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/routes/accounts_router.dart';

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

  onNativeBackPressed(bool didPop) {
    if (!didPop) {
      if (_currentPage is! SettingsMenuWidget) {
        _goBackToMenu();
      } else if (ref.read(homePageBackgroundProvider) ==
          HomePageBackgroundState.menu) {
        ref.read(homePageBackgroundProvider.notifier).state =
            HomePageBackgroundState.hidden;
        ref.read(homePageTitleProvider.notifier).state = "";
        GoRouter.of(context).go(ROUTE_ACCOUNTS_HOME);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<HomePageBackgroundState>(homePageBackgroundProvider, (_, next) {
      selectPage(next, context);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (!didPop) {
          onNativeBackPressed(didPop);
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _currentPage,
      ),
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
            _currentPage = const SettingsPage();
            HomePageNotification(leftFunction: _goBackToMenu).dispatch(context);
            ref.read(homePageTitleProvider.notifier).state = S().menu_settings;
          });
          break;
        case HomePageBackgroundState.backups:
          setState(() {
            _currentPage = const BackupPage();
            HomePageNotification(leftFunction: _goBackToMenu).dispatch(context);
            ref.read(homePageTitleProvider.notifier).state = S().menu_backups;
          });
          break;
        case HomePageBackgroundState.support:
          setState(() {
            _currentPage = const SupportPage();
            HomePageNotification(leftFunction: _goBackToMenu).dispatch(context);
            ref.read(homePageTitleProvider.notifier).state =
                S().menu_support.toUpperCase();
          });
          break;
        case HomePageBackgroundState.about:
          setState(() {
            _currentPage = const AboutPage();
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium3),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: EnvoySpacing.medium2),
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
            ),
            TweenAnimationBuilder(
              builder: (context, value, child) {
                return Opacity(
                  opacity: Tween<double>(begin: 0.3, end: 1).transform(value),
                  child: Transform.translate(
                    offset: Offset(
                        0, Tween<double>(begin: -400, end: 0).transform(value)),
                    child: child,
                  ),
                );
              },
              duration: const Duration(milliseconds: 380),
              curve: EnvoyEasing.defaultEasing,
              tween: Tween<double>(begin: 0, end: 1),
              child: Padding(
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
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse(
                                "https://github.com/Foundation-Devices"));
                          },
                          child: SvgPicture.asset(
                            "assets/github.svg",
                          )),
                    ),
                    GestureDetector(
                        onTap: () {
                          launchUrl(
                              Uri.parse(
                                  "https://telegram.me/foundationdevices"),
                              mode: LaunchMode.externalApplication);
                        },
                        child: SvgPicture.asset(
                          "assets/telegram.svg",
                        )),
                  ],
                ),
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
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: EnvoySpacing.large2, vertical: EnvoySpacing.medium1),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 142),
                child: Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.start,
                  style: EnvoyTypography.subheading
                      .copyWith(
                        color: EnvoyColors.textPrimaryInverse,
                      )
                      .setWeight(FontWeight.w500),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: const EnvoyIcon(
                  EnvoyIcons.chevron_right,
                  color: EnvoyColors.textPrimaryInverse,
                ),
              )
            ]),
      ),
    );
  }
}
