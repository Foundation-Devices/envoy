// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as design_system;
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:envoy/ui/components/stripe_painter.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:ngwallet/ngwallet.dart';

class QrTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final EnvoyAccount account;
  final Widget qr;

  const QrTab(
      {super.key,
      required this.account,
      required this.title,
      required this.subtitle,
      required this.qr});

  @override
  Widget build(BuildContext context) {
    final Color color = fromHex(account.color);
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
                color,
                Colors.black,
              ]),
        ),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(18)),
              border:
                  Border.all(color: color, width: 2, style: BorderStyle.solid)),
          child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Stack(children: [
                Positioned.fill(
                  child: CustomPaint(
                    isComplex: true,
                    willChange: false,
                    painter: StripePainter(
                      EnvoyColors.gray1000.applyOpacity(0.4),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: EnvoySpacing.medium1,
                          top: EnvoySpacing.medium1,
                          right: EnvoySpacing.small,
                          bottom: EnvoySpacing.medium1),
                      child: Row(children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.black.applyOpacity(0.6),
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                  color: color,
                                  width: 3,
                                  style: BorderStyle.solid)),
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: SvgPicture.asset(
                              "assets/i.svg",
                            ),
                          ),
                        ),
                        const SizedBox(width: EnvoySpacing.medium1),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxHeight: 100, maxWidth: 220),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      title,
                                      style: EnvoyTypography.body
                                          .copyWith(
                                              color: design_system
                                                  .EnvoyColors.solidWhite)
                                          .setWeight(FontWeight.w600),
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
                          ],
                        ),
                      ]),
                    ),
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
                              padding: const EdgeInsets.all(EnvoySpacing.xs),
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
