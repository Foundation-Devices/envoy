// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class EnvoyLoader extends StatelessWidget {
  const EnvoyLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: EnvoySpacing.medium3,
      width: EnvoySpacing.medium3,
      child: CircularProgressIndicator(
        color: EnvoyColors.tealLight,
        backgroundColor: EnvoyColors.surface4,
        strokeWidth: 3,
      ),
    );
  }
}
