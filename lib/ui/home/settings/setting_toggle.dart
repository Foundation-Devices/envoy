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
  late bool _toggleValue;
  Timer? _timer;

  @override
  initState() {
    super.initState();
    _toggleValue = widget.getter();
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
          setState(() {
            _toggleValue = enabled;
          });
          if (_timer != null) _timer!.cancel();
          _timer = Timer(Duration(seconds: widget.delay), () {
            widget.setter(_toggleValue);
            _toggleValue = widget.getter();
          });
        });
  }
}
