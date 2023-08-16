// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class EnvoyListToggle extends StatefulWidget {
  @override
  _EnvoyListToggleState createState() => _EnvoyListToggleState();
}

class _EnvoyListToggleState extends State<EnvoyListToggle> {
  var isEnabled = false;

  @override
  Widget build(BuildContext context) {
    var listIcon = EnvoyIcon(
      EnvoyIcons.list,
      color:
          isEnabled ? EnvoyColors.textTertiary : EnvoyColors.textPrimaryInverse,
      size: EnvoyIconSize.small,
    );

    var cardViewIcon = EnvoyIcon(
      EnvoyIcons.card_view,
      color:
          isEnabled ? EnvoyColors.textPrimaryInverse : EnvoyColors.textTertiary,
      size: EnvoyIconSize.small,
    );

    final toggleWidth = 60.0;
    final widgetWidth = 2 +
        toggleWidth +
        EnvoySpacing.xs +
        cardViewIcon.getSize() +
        EnvoySpacing.small;
    return GestureDetector(
      onTap: () {
        setState(() {
          isEnabled = !isEnabled;
        });
      },
      child: Container(
        width: widgetWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(EnvoySpacing.medium2),
          color: EnvoyColors.surface2,
        ),
        child: Stack(fit: StackFit.loose, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(EnvoySpacing.small,
                EnvoySpacing.xs, EnvoySpacing.xs, EnvoySpacing.xs),
            child: Align(alignment: Alignment.centerLeft, child: listIcon),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(EnvoySpacing.xs, EnvoySpacing.xs,
                EnvoySpacing.small, EnvoySpacing.xs),
            child: Align(
              alignment: Alignment.centerRight,
              child: cardViewIcon,
            ),
          ),
          AnimatedAlign(
            duration: Duration(milliseconds: 150),
            alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Container(
                width: toggleWidth,
                decoration: BoxDecoration(
                    color: EnvoyColors.accentPrimary,
                    borderRadius: BorderRadius.circular(EnvoySpacing.medium1)),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isEnabled ? cardViewIcon : listIcon,
                        Padding(
                          padding: const EdgeInsets.only(left: EnvoySpacing.xs),
                          child: Text(
                            isEnabled ? "Card" : "List",
                            style: EnvoyTypography.caption1Semibold.copyWith(
                                color: EnvoyColors.textPrimaryInverse),
                          ),
                        )
                      ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
