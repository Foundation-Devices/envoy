// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/cupertino.dart';

class SettingToggle extends StatefulWidget {
  final Function(bool) setter;
  final bool Function() getter;
  final int delay;
  final bool enabled;

  SettingToggle(this.getter, this.setter,
      {this.delay = 0, this.enabled = true});

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
      child: EnvoySwitch(
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

class EnvoySwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const EnvoySwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      activeColor: EnvoyColors.darkTeal,
      thumbColor: EnvoyColors.whitePrint,
      trackColor: EnvoyColors.grey15,
      value: value,
      onChanged: onChanged,
    );
  }
}
