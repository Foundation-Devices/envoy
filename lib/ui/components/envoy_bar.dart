// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/util/haptics.dart';
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
  final bool enabled;

  const EnvoyBarItem({
    required this.icon,
    required this.text,
    this.onTap,
    this.enabled = true,
  });
}

/// A reusable horizontal bar with equally spaced icon+text buttons.
/// Each item is centered and tappable.
class EnvoyBar extends StatelessWidget {
  final List<EnvoyBarItem> items;
  final bool showDividers;
  final double bottomPadding;

  const EnvoyBar({
    super.key,
    required this.items,
    this.showDividers = false,
    this.bottomPadding = EnvoySpacing.large1,
  });

  @override
  Widget build(BuildContext context) {
    // Build the row's children with optional dividers
    final List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      children.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.small),
            child: _EnvoyBarItemWidget(item: items[i]),
          ),
        ),
      );

      // Add vertical dividers after first and before last item
      if (showDividers && (i == 0 || i == items.length - 2)) {
        children.add(_buildDivider());
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding,
        left: EnvoySpacing.medium1,
        right: EnvoySpacing.medium1,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.medium1,
        ),
        decoration: BoxDecoration(
          color: EnvoyColors.textPrimaryInverse,
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
        child: IntrinsicHeight(
          // makes dividers stretch to full height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      color: EnvoyColors.border2,
      margin: const EdgeInsets.symmetric(horizontal: EnvoySpacing.small),
    );
  }
}

class _EnvoyBarItemWidget extends StatefulWidget {
  final EnvoyBarItem item;

  const _EnvoyBarItemWidget({required this.item});

  @override
  State<_EnvoyBarItemWidget> createState() => _EnvoyBarItemWidgetState();
}

class _EnvoyBarItemWidgetState extends State<_EnvoyBarItemWidget> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (!widget.item.enabled) return;
    Haptics.buttonPress(); // your original haptic call on press down[web:70]
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.item.enabled) return;
    Haptics.selectionClick(); // your original haptic call on tap up[web:70]
    setState(() {
      _isPressed = false;
    });
    widget.item.onTap?.call();
  }

  void _onTapCancel() {
    if (!widget.item.enabled) return;
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.item.enabled;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            EnvoyIcon(
              widget.item.icon,
              color: isEnabled
                  ? EnvoyColors.accentPrimary
                  : EnvoyColors.textInactive,
            ),
            const SizedBox(height: EnvoySpacing.xs),
            Text(
              widget.item.text,
              textAlign: TextAlign.center,
              style: EnvoyTypography.info.copyWith(
                color: isEnabled
                    ? EnvoyColors.accentPrimary
                    : EnvoyColors.textInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
