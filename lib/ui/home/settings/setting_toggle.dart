// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';

class SettingToggle extends StatefulWidget {
  final Function(bool) setter;
  final bool Function() getter;
  final Color inactiveColor;
  final int delay;
  final bool enabled;

  SettingToggle(this.getter, this.setter,
      {this.delay = 0,
      this.inactiveColor = EnvoyColors.grey15,
      this.enabled = true});

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
    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Switch(
          value: widget.getter(),

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
          }),
    );
  }
}
