// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/generated/l10n.dart';

class FwWarning extends StatefulWidget {
  const FwWarning({Key? key, required this.tryNow, required this.tryLater})
      : super(key: key);

  final Function tryNow;
  final Function tryLater;

  @override
  State<FwWarning> createState() => _FwWarningState();
}

class _FwWarningState extends State<FwWarning> {
  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                              "Sorry, we can’t get the firmware update right now.\n\n",
                        ),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                  Uri.parse(
                                      "https://github.com/Foundation-Devices/passport2/releases"),
                                  mode: LaunchMode.externalApplication);
                            },
                          style: linkStyle,
                          text: S().envoy_fw_error_modal_cta_3,
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
                  S().envoy_fw_error_modal_cta_2,
                  onTap: () {
                    widget.tryLater();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: EnvoyButton(
                    S().envoy_fw_error_modal_cta_1,
                    onTap: () {
                      widget.tryNow();
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
