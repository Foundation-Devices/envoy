// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/envoy_colors.dart';

class EnvoyTextButton extends StatelessWidget {
  const EnvoyTextButton(
      {Key? key,
      required this.label,
      this.onTap,
      this.error = false,
      this.textStyle})
      : super(key: key);

  final String label;
  final Function()? onTap;
  final bool error;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(label,
          style: textStyle ??
              TextStyle(
                  color: error ? EnvoyColors.darkCopper : EnvoyColors.darkTeal,
                  fontWeight: FontWeight.w600)),
    );
  }
}
