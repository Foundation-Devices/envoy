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
  final Function()? onEnabled;
  final Function()? onDisabled;
  final String? semanticsLabel;

  const SettingToggle(this.getter, this.setter,
      {super.key,
      this.delay = 0,
      this.enabled = true,
      this.onEnabled,
      this.onDisabled,
      this.semanticsLabel});

  @override
  State<SettingToggle> createState() => _SettingToggleState();
}

class _SettingToggleState extends State<SettingToggle> {
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    final id = widget.semanticsLabel != null
        ? '${widget.semanticsLabel}-${widget.getter()}'
        : null;
    return Semantics(
      identifier: id,
      container: true,
      excludeSemantics: true,
      child: IgnorePointer(
        ignoring: !widget.enabled,
        child: EnvoySwitch(
            value: widget.getter(),
            semanticsLabel: widget.semanticsLabel,
            onChanged: (enabled) {
              if (enabled) {
                widget.onEnabled?.call();
              } else {
                widget.onDisabled?.call();
              }

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
      ),
    );
  }
}

class EnvoySwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticsLabel;

  const EnvoySwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final id = semanticsLabel != null ? '$semanticsLabel-$value' : null;
    return Semantics(
      identifier: id,
      container: true,
      toggled: value,
      excludeSemantics: true,
      child: CupertinoSwitch(
        activeTrackColor: EnvoyColors.darkTeal,
        thumbColor: EnvoyColors.whitePrint,
        inactiveTrackColor: EnvoyColors.grey15,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
