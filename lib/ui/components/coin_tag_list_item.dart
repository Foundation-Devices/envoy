// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

enum FlexAlignment { flexLeft, flexRight, noFlex }

Widget CoinTagListItem(
    {required String title,
    required Widget icon,
    required Widget trailing,
    FlexAlignment flexAlignment = FlexAlignment.noFlex,
    Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
        horizontal: EnvoySpacing.xs, vertical: EnvoySpacing.small),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: flexAlignment == FlexAlignment.flexRight ? 8 : 5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 26,
                child: icon,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: EnvoySpacing.xs,
                  ),
                  child: Text(
                    "$title",
                    style: EnvoyTypography.body
                        .copyWith(color: color ?? EnvoyColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
            flex: flexAlignment == FlexAlignment.flexLeft ? 8 : 4,
            child: trailing),
      ],
    ),
  );
}
