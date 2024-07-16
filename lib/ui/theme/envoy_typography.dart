// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Setting fontWeight in a workaround way because of:
// https://github.com/material-foundation/flutter-packages/issues/35
extension WeightBugWorkaroung on TextStyle {
  TextStyle setWeight(FontWeight weight) {
    return copyWith(
      fontFamily: GoogleFonts.montserrat(fontWeight: weight).fontFamily,
    );
  }
}

class EnvoyTypography {
  static TextStyle baseFont = GoogleFonts.montserrat(
    fontFeatures: [
      const FontFeature.tabularFigures(),
    ],
  );

  static TextStyle explainer =
      EnvoyTypography.label.copyWith(color: EnvoyColors.textTertiary);

  static TextStyle digitsLarge = baseFont
      .copyWith(
        fontSize: 40,
      )
      .setWeight(FontWeight.w300);

  static TextStyle digitsMedium = baseFont
      .copyWith(
        fontSize: 14,
      )
      .setWeight(FontWeight.w500);

  static TextStyle digitsSmall = baseFont
      .copyWith(
        fontSize: 12,
      )
      .setWeight(FontWeight.w500);

  static TextStyle heading = baseFont
      .copyWith(fontSize: 20, color: EnvoyColors.textPrimary)
      .setWeight(FontWeight.w500);

  // NOTE: always in caps
  static TextStyle topBarTitle = baseFont
      .copyWith(
        fontSize: 18,
      )
      .setWeight(FontWeight.w500);

  static TextStyle subheading = baseFont
      .copyWith(
        fontSize: 16,
      )
      .setWeight(FontWeight.w600);

  static TextStyle button = baseFont
      .copyWith(
        fontSize: 14,
      )
      .setWeight(FontWeight.w600);

  static TextStyle body = baseFont
      .copyWith(
        fontSize: 14,
      )
      .setWeight(FontWeight.w500);

  static TextStyle info = baseFont
      .copyWith(
        fontSize: 12,
      )
      .setWeight(FontWeight.w500);

  static TextStyle label = baseFont
      .copyWith(
        fontSize: 10,
      )
      .setWeight(FontWeight.w500);
}
