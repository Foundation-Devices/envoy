// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

class CardNavigator {
  final Function(NavigationCard) push;
  final Function({int depth}) pop;
  final Function() hideOptions;

  CardNavigator(this.push, this.pop, this.hideOptions);
}

mixin NavigationCard on Widget {
  abstract bool modal;
  abstract Widget? optionsWidget;
  abstract String? title;
  abstract Function()? onPop;
  abstract Function()? rightFunction;
  abstract IconData? rightFunctionIcon;
  abstract CardNavigator? navigator;
}
