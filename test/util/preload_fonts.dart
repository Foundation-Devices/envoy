// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> preloadFonts(WidgetTester tester) async {
  // WORKAROUND: pump fonts that we are using so they actually show up
  // Bug in google_fonts: https://github.com/material-foundation/flutter-packages/issues/175
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          Text("A", style: EnvoyTypography.body),
          Text("B", style: EnvoyTypography.largeAmount),
        ],
      ),
    ),
  );
}
