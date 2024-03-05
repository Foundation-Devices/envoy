// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/cupertino.dart';

class EnvoyToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const EnvoyToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 31.0,
        width: 51.0,
        child: FittedBox(
            fit: BoxFit.contain,
            child: CupertinoSwitch(
              activeColor: EnvoyColors.accentPrimary,
              thumbColor: EnvoyColors.surface1,
              trackColor: EnvoyColors.surface2,
              value: value,
              onChanged: onChanged,
            )));
  }
}
