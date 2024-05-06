// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as design_system;

import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/account.dart';
import 'package:flutter_svg/svg.dart';

class QrTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final Account account;
  final Widget qr;

  const QrTab(
      {super.key,
      required this.account,
      required this.title,
      required this.subtitle,
      required this.qr});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(
              color: Colors.black, width: 2, style: BorderStyle.solid),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [
                0.0,
                0.4
              ],
              colors: [
                account.color,
                Colors.black,
              ]),
        ),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(18)),
              border: Border.all(
                  color: account.color, width: 2, style: BorderStyle.solid)),
          child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Stack(children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter:
                        LinesPainter(color: EnvoyColors.gray1000, opacity: 0.4),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                  color: account.color,
                                  width: 3,
                                  style: BorderStyle.solid)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SvgPicture.asset(
                              "assets/i.svg",
                            ),
                          ),
                        ),
                        title: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: EnvoyTypography.body.copyWith(
                                      color:
                                          design_system.EnvoyColors.solidWhite),
                                ),
                                Text(
                                  subtitle,
                                  style: EnvoyTypography.label
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(16))),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: qr,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ])),
        ));
  }
}
