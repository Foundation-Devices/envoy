// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

import 'package:envoy/generated/l10n.dart';

class EnvoyBottomNavigation extends StatefulWidget {
  final Function? onChanged;

  const EnvoyBottomNavigation({super.key, this.onChanged});

  @override
  _EnvoyBottomNavigationState createState() => _EnvoyBottomNavigationState();
}

class _EnvoyBottomNavigationState extends State<EnvoyBottomNavigation> {
  int _selectedIndex = 0;
  var activeColor = EnvoyColors.accentPrimary;
  var inActiveColor = EnvoyColors.textTertiary;
  var labelStyle = EnvoyTypography.caption2Semibold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: activeColor,
        unselectedItemColor: inActiveColor,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: labelStyle,
        unselectedLabelStyle: labelStyle,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        onTap: (int index) {
          setState(
            () {
              _selectedIndex = index;
              if (widget.onChanged != null) {
                widget.onChanged!();
              }
            },
          );
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.devices,
                color: inActiveColor,
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.devices,
                color: activeColor,
              ),
            ),
            label: S().bottomNav_devices,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.shield,
                color: inActiveColor,
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.shield,
                color: activeColor,
              ),
            ),
            label: S().bottomNav_privacy,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.bitcoin_b,
                color: inActiveColor,
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.bitcoin_b,
                color: activeColor,
              ),
            ),
            label: S().bottomNav_accounts,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.history,
                color: inActiveColor,
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.history,
                color: activeColor,
              ),
            ),
            label: S().bottomNav_activity,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.learn,
                color: inActiveColor,
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.learn,
                color: activeColor,
              ),
            ),
            label: S().bottomNav_learn,
          ),
        ],
      ),
    );
  }
}
