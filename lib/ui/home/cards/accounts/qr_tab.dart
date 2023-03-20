// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/business/account.dart';
import 'package:flutter_svg/svg.dart';

class QrTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final Account account;
  final Widget qr;

  QrTab(
      {required this.account,
      required this.title,
      required this.subtitle,
      required this.qr});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(
              color: Colors.black, width: 2, style: BorderStyle.solid),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [
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
              borderRadius: BorderRadius.all(Radius.circular(18)),
              border: Border.all(
                  color: account.color, width: 2, style: BorderStyle.solid)),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              child: Stack(children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: LinesPainter(
                        color: EnvoyColors.tilesLineDarkColor, opacity: 1.0),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                        title: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.white),
                        ),
                        subtitle: Text(
                          subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: qr,
                      ),
                    ),
                  ],
                )
              ])),
        ));
  }
}
