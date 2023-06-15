// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';

class SettingDropdown extends StatefulWidget {
  final Function(String?) setter;
  final String? Function() getter;
  final Map<String, String?> options;

  SettingDropdown(this.options, this.getter, this.setter);

  @override
  State<SettingDropdown> createState() => _SettingDropdownState();
}

class _SettingDropdownState extends State<SettingDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      dropdownColor: Colors.black,
      underline: SizedBox.shrink(),
      style: TextStyle(
        color: EnvoyColors.darkTeal,
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      ),
      value: widget.getter(),
      onChanged: (value) {
        setState(() {
          widget.setter(value as String?);
        });
      },
      items: widget.options.entries
          .map((e) => DropdownMenuItem(value: e.value, child: Text(e.key)))
          .toList(),
    );
  }
}
