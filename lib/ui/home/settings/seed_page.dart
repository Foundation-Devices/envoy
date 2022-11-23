// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'dart:io' show Platform;

class SeedPage extends StatefulWidget {
  @override
  State<SeedPage> createState() => _SeedPageState();
}

class _SeedPageState extends State<SeedPage> {
  late EnvoySeed seed;

  @override
  void initState() {
    seed = EnvoySeed();
    super.initState();
  }

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
                Divider(),
                AboutButton(
                  "(Re)create Seed",
                  onTap: () {
                    seed.create().then((value) {
                      setState(() {});
                    });
                  },
                ),
                Divider(),
                AboutText("Local/Corpo Cloud"),
                FutureBuilder<String?>(
                    future: seed.getLocal(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return AboutText(
                            snapshot.data == null ? "NULL" : snapshot.data!);
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                Divider(),
                AboutText(Platform.isAndroid ? "Last Backup" : "Last Restore"),
                FutureBuilder<DateTime?>(
                    future: seed.getLocalSecretLastBackupTimestamp(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return AboutText(snapshot.data == null
                            ? "NULL"
                            : snapshot.data!.toIso8601String());
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                if (Platform.isAndroid) Divider(),
                if (Platform.isAndroid)
                  AboutButton(
                    "Backup Settings",
                    onTap: () {
                      seed.showSettingsMenu();
                    },
                  ),
                Divider(),
                AboutText("Secure Element"),
                FutureBuilder<String?>(
                    future: seed.restoreSecure(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return AboutText(
                            snapshot.data == null ? "NULL" : snapshot.data!);
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
              ],
            )));
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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

class AboutText extends StatelessWidget {
  final String label;
  final bool dark;

  const AboutText(
    this.label, {
    this.dark: false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
          color: dark ? Colors.white38 : Colors.white,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
        ));
  }
}
