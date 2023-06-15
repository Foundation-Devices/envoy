// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/shield_path.dart';
import 'package:flutter/widgets.dart';

class ShieldBorder extends ShapeBorder {
  @override
  // TODO: implement dimensions
  EdgeInsetsGeometry get dimensions => throw UnimplementedError();

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return ShieldClipper().getClip(Size(rect.width, rect.height + 30));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return ShieldClipper().getClip(Size(rect.width, rect.height + 30));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // TODO: implement paint
  }

  @override
  ShapeBorder scale(double t) {
    // TODO: implement scale
    throw UnimplementedError();
  }
}
