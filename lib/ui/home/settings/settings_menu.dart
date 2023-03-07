// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/settings/backup/backup_page.dart';
import 'package:envoy/ui/home/settings/settings_page.dart';
import 'package:envoy/ui/home/settings/support_page.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/home/settings/about_page.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';

class SettingsMenu extends StatefulWidget {
  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  Widget? _menuPage;
  Widget? _currentPage;

  void _goBackToMenu() {
    setState(() {
      _currentPage = _menuPage;
    });

    Settings().store();
    HomePageNotification(leftFunction: null, title: "Envoy".toUpperCase())
      ..dispatch(context);
  }

  void initState() {
    super.initState();
    _menuPage = SettingsMenuWidget((widget) {
      setState(() {
        _currentPage = widget;
      });

      HomePageNotification(leftFunction: _goBackToMenu)..dispatch(context);
    });

    _currentPage = _menuPage;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 250),
      child: _currentPage!,
    );
  }
}

class SettingsMenuWidget extends StatelessWidget {
  final Function(Widget) callback;

  SettingsMenuWidget(this.callback);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100, bottom: 50),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 50),
                  MenuOption(
                    label: S().envoy_settings_menu_settings,
                    onTap: () {
                      callback(SettingsPage());
                    },
                  ),
                  SizedBox(height: 50),
                  MenuOption(
                    label: S().envoy_settings_menu_support,
                    onTap: () {
                      callback(SupportPage());
                    },
                  ),
                  SizedBox(height: 50),
                  MenuOption(
                    label: S().envoy_settings_menu_about,
                    onTap: () {
                      callback(AboutPage());
                    },
                  ),
                  SizedBox(height: 50),
                  MenuOption(
                    label: "Backup",
                    onTap: () {
                      callback(BackupPage());
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
    return Row(children: [
      Expanded(flex: 3, child: SizedBox.shrink()),
      Expanded(
        flex: 4,
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: Colors.white),
          ),
        ),
      ),
      Expanded(
        flex: 3,
        child: Container(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: onTap,
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ),
        ),
      )
    ]);
  }
}
