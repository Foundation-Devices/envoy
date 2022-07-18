// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class SettingToggle extends StatefulWidget {
  final Function(bool) setter;
  final bool Function() getter;

  SettingToggle(this.getter, this.setter);

  @override
  State<SettingToggle> createState() => _SettingToggleState();
}

class _SettingToggleState extends State<SettingToggle> {
  @override
  Widget build(BuildContext context) {
    return NeumorphicSwitch(
        height: 35,
        value: widget.getter(),
        style: NeumorphicSwitchStyle(
            inactiveThumbColor: EnvoyColors.whitePrint,
            inactiveTrackColor: EnvoyColors.grey15,
            activeThumbColor: EnvoyColors.whitePrint,
            activeTrackColor: EnvoyColors.darkTeal,
            disableDepth: true),
        onChanged: (enabled) {
          setState(() {
            widget.setter(enabled);
          });
        });
  }
}
