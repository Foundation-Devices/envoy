// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';

class DetailsWidget extends StatelessWidget {
  final Color backgroundColor;
  final Widget topWidget;
  final List<Widget> bottomWidgets;

  const DetailsWidget({
    required this.backgroundColor,
    required this.topWidget,
    required this.bottomWidgets,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey _detailWidgetKey = GlobalKey();

    const double cardRadius = EnvoySpacing.medium2;

    return GestureDetector(
      onTapDown: (details) {
        final RenderBox? box =
            _detailWidgetKey.currentContext?.findRenderObject() as RenderBox?;
        final Offset localOffset = box!.globalToLocal(details.globalPosition);

        if (!box.paintBounds.contains(localOffset)) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Container(
          key: _detailWidgetKey,
          padding: const EdgeInsets.symmetric(
            horizontal: EnvoySpacing.medium2,
            vertical: EnvoySpacing.medium2,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
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
                borderRadius: BorderRadius.all(Radius.circular(cardRadius - 3)),
                border: Border.all(
                  color: backgroundColor,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(cardRadius - 2)),
                child: StripesBackground(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                        decoration: BoxDecoration(
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
        ),
      ),
    );
  }
}
