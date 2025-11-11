// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';

/// Single item in the EnvoyBar.
class EnvoyBarItem {
  final EnvoyIcons icon;
  final String text;
  final VoidCallback? onTap;

  const EnvoyBarItem({
    required this.icon,
    required this.text,
    this.onTap,
  });
}

/// A reusable horizontal bar with equally spaced icon+text buttons.
/// Each item is centered and tappable.
class EnvoyBar extends StatelessWidget {
  final List<EnvoyBarItem> items;

  const EnvoyBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: EnvoySpacing.large2,
          left: EnvoySpacing.medium1,
          right: EnvoySpacing.medium1),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: EnvoySpacing.small,
          horizontal: EnvoySpacing.medium1,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.15),
              offset: const Offset(0, 3),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items
              .map(
                (item) => Expanded(
                  child: GestureDetector(
                    onTap: item.onTap,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        EnvoyIcon(
                          item.icon,
                          color: EnvoyColors.accentPrimary,
                        ),
                        const SizedBox(height: EnvoySpacing.xs),
                        Text(
                          item.text,
                          textAlign: TextAlign.center,
                          style: EnvoyTypography.info.copyWith(
                            color: EnvoyColors.accentPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
