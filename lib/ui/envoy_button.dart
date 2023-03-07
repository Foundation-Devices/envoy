// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';

class EnvoyButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final bool light;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  EnvoyButton(this.label,
      {this.onTap,
      this.light: false,
      this.textStyle,
      this.borderRadius,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: 40.0,
          decoration: BoxDecoration(
              color: this.backgroundColor,
              gradient: backgroundColor == null
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: light
                          ? [EnvoyColors.grey15, EnvoyColors.grey15]
                          : [EnvoyColors.teal, EnvoyColors.darkTeal])
                  : null,
              borderRadius:
                  this.borderRadius ?? BorderRadius.all(Radius.circular(13.0))),
          child: Center(
              child: Text(
            label,
            style: textStyle == null
                ? TextStyle(
                    color: light ? EnvoyColors.darkTeal : Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  )
                : this.textStyle,
            textAlign: TextAlign.center,
          ))),
    );
  }
}
