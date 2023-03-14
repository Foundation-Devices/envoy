// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class SettingToggle extends StatefulWidget {
  final Function(bool) setter;
  final bool Function() getter;
  final Color inactiveColor;
  final int delay;

  SettingToggle(this.getter, this.setter,
      {this.delay: 0, this.inactiveColor = EnvoyColors.grey15});

  @override
  State<SettingToggle> createState() => _SettingToggleState();
}

class _SettingToggleState extends State<SettingToggle> {
  Timer? _timer;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicSwitch(
        height: 35,
        value: widget.getter(),
        style: NeumorphicSwitchStyle(
            inactiveThumbColor: EnvoyColors.whitePrint,
            inactiveTrackColor: widget.inactiveColor,
            activeThumbColor: EnvoyColors.whitePrint,
            activeTrackColor: EnvoyColors.darkTeal,
            disableDepth: true),
        onChanged: (enabled) {
          if (widget.delay > 0) {
            _timer?.cancel();
            _timer = Timer(Duration(seconds: widget.delay), () {
              setState(() {
                widget.setter(enabled);
              });
            });
          } else {
            setState(() {
              widget.setter(enabled);
            });
          }
        });
  }
}
