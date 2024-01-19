// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnvoyTypography {
  static TextStyle _baseFont = GoogleFonts.montserrat(
    fontFeatures: [
      FontFeature.tabularFigures(),
    ],
  );

  static TextStyle explainer =
      EnvoyTypography.label.copyWith(color: EnvoyColors.textTertiary);

  static TextStyle largeAmount = _baseFont.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w300,
  );

  static TextStyle heading = _baseFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle subheading = _baseFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle button = _baseFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle body = _baseFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle info = _baseFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle label = _baseFont.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
}
