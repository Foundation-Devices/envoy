// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/components/stripe_painter.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';

class EnvoyInfoCard extends StatelessWidget {
  final Color backgroundColor;
  final Widget topWidget;
  final List<Widget> bottomWidgets;
  final Widget? iconTitleWidget;
  final Widget? titleWidget;

  const EnvoyInfoCard({
    required this.backgroundColor,
    required this.topWidget,
    required this.bottomWidgets,
    this.iconTitleWidget,
    this.titleWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const double cardRadius = EnvoySpacing.medium2;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EnvoySpacing.medium2,
        vertical: EnvoySpacing.medium2,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(cardRadius - 1)),
          border: Border.all(
            color: EnvoyColors.textPrimary,
            width: 2,
            style: BorderStyle.solid,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              EnvoyColors.textPrimary,
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.all(Radius.circular(cardRadius - 3)),
            border: Border.all(
              color: backgroundColor,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.all(Radius.circular(cardRadius - 4)),
            child: CustomPaint(
              isComplex: true,
              willChange: false,
              painter: StripePainter(
                EnvoyColors.gray1000.withOpacity(0.4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                      ),
                      child: Row(
                        children: [
                          if (iconTitleWidget != null)
                            iconTitleWidget!
                          else
                            const SizedBox.shrink(),
                          if (titleWidget != null)
                            titleWidget!
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 32,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.xs,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: EnvoySpacing.xs,
                      horizontal: EnvoySpacing.xs,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(EnvoySpacing.medium1),
                      ),
                      color: EnvoyColors.textPrimaryInverse,
                    ),
                    child: topWidget,
                  ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.all(EnvoySpacing.xs),
                      padding: const EdgeInsets.all(EnvoySpacing.xs),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(EnvoySpacing.medium1),
                        color: EnvoyColors.textPrimaryInverse,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(0),
                        children: bottomWidgets,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
