// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class SettingText extends StatelessWidget {
  final String label;
  final Function? onTap;
  final Color color;

  const SettingText(
    this.label, {
    Key? key,
    this.onTap,
    this.color: Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 2),
        child: Text(label,
            style: TextStyle(
              color: color,
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
            )),
      ),
    );
  }
}
