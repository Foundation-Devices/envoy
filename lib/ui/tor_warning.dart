// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TorWarning extends StatefulWidget {
  const TorWarning({Key? key}) : super(key: key);

  @override
  State<TorWarning> createState() => _TorWarningState();
}

class _TorWarningState extends State<TorWarning> {
  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyText2?.copyWith(
          fontWeight: FontWeight.w500,
        );

    var linkStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: EnvoyColors.darkTeal, fontWeight: FontWeight.w800);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(EnvoyIcons.exclamation_warning,
                    color: EnvoyColors.darkCopper, size: 84),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: textStyle,
                      children: [
                        TextSpan(
                          text:
                              "Envoy is unable to establish a connection due to ongoing Tor network ",
                        ),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                  Uri.parse("https://status.torproject.org"),
                                  mode: LaunchMode.externalApplication);
                            },
                          style: linkStyle,
                          text: "disruptions",
                        ),
                        TextSpan(
                          text:
                              ".\n\n Disabling Tor will establish a direct connection with the Envoy server, but comes with privacy ",
                        ),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                  Uri.parse(
                                      "https://docs.foundationdevices.com/envoy/tor"),
                                  mode: LaunchMode.externalApplication);
                            },
                          style: linkStyle,
                          text: "tradeoffs",
                        ),
                        TextSpan(
                          text: ".",
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(4)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 28),
            child: Column(
              //Temporarily Disable Tor
              children: [
                EnvoyButton(
                  "Temporarily Disable Tor",
                  type: EnvoyButtonTypes.secondary,
                  onTap: () {
                    ConnectivityManager().torTemporarilyDisabled = true;
                    Navigator.of(context).pop();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: EnvoyButton(
                    "Retry Tor Connection",
                    onTap: () {
                      // We are continually retrying anyway
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
