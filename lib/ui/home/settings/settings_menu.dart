// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/settings/backup/backup_page.dart';
import 'package:envoy/ui/home/settings/settings_page.dart';
import 'package:envoy/ui/home/settings/support_page.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/home/settings/about_page.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';

import 'package:envoy/business/envoy_seed.dart';

class SettingsMenu extends ConsumerStatefulWidget {
  @override
  ConsumerState<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends ConsumerState<SettingsMenu> {
  Widget _currentPage = SettingsMenuWidget();

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
      duration: Duration(milliseconds: 250),
      child: _currentPage,
    );
  }

  @override
  void initState() {
    selectPage(ref.read(homePageBackgroundProvider), context);
    super.initState();
  }

  void selectPage(HomePageBackgroundState state, BuildContext context) {
    switch (state) {
      case HomePageBackgroundState.menu:
        setState(() {
          _currentPage = SettingsMenuWidget();
          HomePageNotification(leftFunction: null, title: "Envoy".toUpperCase())
            ..dispatch(context);
        });
        break;
      case HomePageBackgroundState.settings:
        setState(() {
          _currentPage = SettingsPage();
          HomePageNotification(leftFunction: _goBackToMenu)..dispatch(context);
        });
        break;
      case HomePageBackgroundState.backups:
        setState(() {
          _currentPage = BackupPage();
          HomePageNotification(leftFunction: _goBackToMenu)..dispatch(context);
        });
        break;
      case HomePageBackgroundState.support:
        setState(() {
          _currentPage = SupportPage();
          HomePageNotification(leftFunction: _goBackToMenu)..dispatch(context);
        });
        break;
      case HomePageBackgroundState.about:
        setState(() {
          _currentPage = AboutPage();
          HomePageNotification(leftFunction: _goBackToMenu)..dispatch(context);
        });
        break;
      default:
        break;
    }
  }
}

class SettingsMenuWidget extends ConsumerWidget {
  SettingsMenuWidget();

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
                  SizedBox(height: 34),
                  MenuOption(
                    label: S().envoy_settings_menu_settings,
                    onTap: () {
                      background.state = HomePageBackgroundState.settings;
                    },
                  ),
                  if (EnvoySeed().walletDerived()) SizedBox(height: 50),
                  if (EnvoySeed().walletDerived())
                    MenuOption(
                      label: S().menu_backups,
                      onTap: () {
                        background.state = HomePageBackgroundState.backups;
                      },
                    ),
                  SizedBox(height: 50),
                  MenuOption(
                    label: S().envoy_settings_menu_support,
                    onTap: () {
                      background.state = HomePageBackgroundState.support;
                    },
                  ),
                  SizedBox(height: 50),
                  MenuOption(
                    label: S().envoy_settings_menu_about,
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
                        "assets/twitter.svg",
                        width: 40,
                        color: Colors.white54,
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
                          color: Colors.white54,
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
                        color: Colors.white54,
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
    return Container(
      margin: EdgeInsets.only(left: 18),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.white),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 8),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onTap,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ),
            )
          ]),
    );
  }
}
