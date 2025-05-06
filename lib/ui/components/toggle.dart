// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/cupertino.dart';

class EnvoyToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const EnvoyToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 24,
        padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: value ? EnvoyColors.accentPrimary : Color(0xffC8C8C8)),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: EnvoyColors.surface1,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
