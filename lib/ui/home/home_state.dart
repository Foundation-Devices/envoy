// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/settings/settings_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeShellOptionsProvider =
    StateProvider<HomeShellOptions?>((ref) => null);

final homePageTitleProvider = StateProvider<String>((ref) => "");
final hideBottomNavProvider = StateProvider<bool>((ref) => false);
final buyBTCPageProvider = StateProvider<bool>((ref) => false);
final navigatingToEditRegionProvider = StateProvider<bool>((ref) => false);

final fullscreenHomePageProvider = StateProvider<bool>((ref) => false);
final homePageBackdropModeProvider = StateProvider<bool>((ref) => false);

// final homepageOptionsWidgetProvider = StateProvider<Widget>((ref) => Container());
final backdropWidgetProvider =
    StateProvider<Widget>((ref) => const SettingsMenu());

class HomeShellOptions {
  final Widget? optionsWidget;
  final Widget? rightAction;

  HomeShellOptions({this.optionsWidget, this.rightAction});
}
