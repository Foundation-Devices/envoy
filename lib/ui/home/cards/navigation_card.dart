// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class CardNavigator {
  final Function(NavigationCard) push;
  final Function({int depth}) pop;
  final Function() hideOptions;

  CardNavigator(this.push, this.pop, this.hideOptions);
}

mixin NavigationCard on Widget {
  bool modal = false;
  Widget? optionsWidget;
  String? title;
  Function()? rightFunction;
  CardNavigator? navigator;
}
