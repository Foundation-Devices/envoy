// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
//import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class AboutPage extends StatefulWidget {
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.only(top: 100, left: 40, right: 40),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Image.asset("assets/logo.png"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AboutText(S().about_appVersion),
                FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return AboutText(
                          snapshot.data!.version,
                          dark: true,
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: AboutText(S().about_openSourceLicences)),
                AboutButton(
                  S().about_show,
                  onTap: () {
                    showLicensePage(
                        context: context,
                        applicationName: "Envoy", // TODO: FIGMA
                        useRootNavigator: true,
                        applicationLegalese:
                            "This program is free software: you can redistribute it and/or modify " // TODO: FIGMA
                            "it under the terms of the GNU General Public License as published by "
                            "the Free Software Foundation, either version 3 of the License, or "
                            "(at your option) any later version. "
                            "This program is distributed in the hope that it will be useful,"
                            "but WITHOUT ANY WARRANTY; without even the implied warranty of "
                            "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the "
                            "GNU General Public License for more details.");
                  },
                )
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AboutText(S().about_termsOfUse),
                AboutButton(
                  S().about_show,
                  onTap: () {
                    launchUrlString("https://foundationdevices.com/terms/");
                  },
                )
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AboutText(S().about_privacyPolicy),
                AboutButton(
                  S().about_show,
                  onTap: () {
                    launchUrlString("https://foundationdevices.com/privacy/");
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AboutText extends StatelessWidget {
  final String label;
  final bool dark;

  const AboutText(
    this.label, {
    this.dark = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: dark ? Colors.white38 : Colors.white,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
        ));
  }
}

class AboutButton extends StatelessWidget {
  final String label;
  final Function()? onTap;

  AboutButton(this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: 25.0,
          decoration: BoxDecoration(
              color: EnvoyColors.darkTeal,
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.small),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ))),
    );
  }
}
