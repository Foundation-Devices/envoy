// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/support/support_chat_screen.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/generated/l10n.dart';

class SupportPage extends StatelessWidget {
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
                    label: S().envoy_support_documentation,
                    onTap: () {
                      launchUrl(
                          Uri.parse("https://docs.foundationdevices.com"));
                    },
                  ),
                  SizedBox(height: 50),
                  MenuOption(
                    label: "Chat",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SupportChatScreen()));
                    },
                  ),
                  SizedBox(height: 50),
                  MenuOption(
                    label: S().envoy_support_telegram,
                    onTap: () {
                      launchUrl(
                          Uri.parse("https://telegram.me/foundationdevices"),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                  SizedBox(height: 50),
                  MenuOption(
                    label: S().envoy_support_email,
                    onTap: () {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'hello@foundationdevices.com',
                      );
                      launchUrl(emailUri);
                    },
                  ),
                ]),
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
                .bodyText2!
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
              size: 12,
            ),
          ),
        ),
      )
    ]);
  }
}
