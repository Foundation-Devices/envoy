// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';

const double appMaxTextScaleFactor = 1.3;

class AppScaleClamp extends StatelessWidget {
  final Widget child;

  const AppScaleClamp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: appMaxTextScaleFactor,
      child: child,
    );
  }
}
