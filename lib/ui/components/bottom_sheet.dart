// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/components/button.dart';

void showEnvoyBottomSheet(BuildContext context, String title, String content,
    String primaryButtonLabel, Function onPrimaryButtonTap,
    {icon, secondaryButtonLabel, onSecondaryButtonTap, enableDrag = false}) {
  showModalBottomSheet<void>(
    context: context,
    enableDrag: enableDrag,
    isDismissible: enableDrag,
    barrierColor: EnvoyColors.dimmer,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(EnvoySpacing.medium2),
      ),
    ),
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(EnvoySpacing.medium2),
          ),
          color: EnvoyColors.textPrimaryInverse,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical:
                  enableDrag ? EnvoySpacing.medium1 : EnvoySpacing.medium3,
              horizontal: EnvoySpacing.medium1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (enableDrag)
                Padding(
                  padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
                  child: HomeIndicator(),
                ),
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
                  child: EnvoyIcon(icon, size: EnvoyIconSize.big),
                ),
              Text(
                title,
                style: EnvoyTypography.subtitle1Semibold,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: EnvoySpacing.small, bottom: EnvoySpacing.medium3),
                child: Text(
                  content,
                  style: EnvoyTypography.body2Medium,
                ),
              ),
              EnvoyButton(
                  label: primaryButtonLabel,
                  type: ButtonType.primary,
                  state: ButtonState.default_state,
                  onTap: () {
                    onPrimaryButtonTap();
                    Navigator.pop(context);
                  }),
              if (secondaryButtonLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                  child: EnvoyButton(
                      label: secondaryButtonLabel,
                      type: ButtonType.secondary,
                      state: ButtonState.default_state,
                      onTap: () {
                        if (onSecondaryButtonTap != null) {
                          onSecondaryButtonTap();
                        }
                      }),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class HomeIndicator extends StatelessWidget {
  const HomeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: EnvoySpacing.medium3,
      height: EnvoySpacing.xs,
      decoration: BoxDecoration(
          color: EnvoyColors.gray500,
          borderRadius: BorderRadius.circular(EnvoySpacing.xs)),
    );
  }
}
