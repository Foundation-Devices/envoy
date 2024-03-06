// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/haptics.dart';

enum ButtonState {
  default_state,
  active,
  disabled,
}

class EnvoyIconButton extends StatefulWidget {
  final ButtonState state;
  final Function? onTap;
  final EnvoyIcons? icon;
  final Key? key;

  const EnvoyIconButton({
    required this.onTap,
    this.state = ButtonState.default_state,
    this.icon,
    this.key,
  }) : super(key: key);

  @override
  _EnvoyIconButtonState createState() => _EnvoyIconButtonState();
}

class _EnvoyIconButtonState extends State<EnvoyIconButton> {
  bool isPressed = false;
  final _animationsDuration = const Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _isButtonDisabled(),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            isPressed = true;
            Haptics.lightImpact();
          });
        },
        onTapUp: (_) {
          setState(() {
            isPressed = false;
            Haptics.lightImpact();
            if (widget.onTap != null) {
              widget.onTap!();
            }
          });
        },
        onTapCancel: () {
          setState(() {
            isPressed = false;
            Haptics.lightImpact();
            if (widget.onTap != null) {
              widget.onTap!();
            }
          });
        },
        child: Opacity(
          opacity: _getOpacity(),
          child: AnimatedContainer(
            duration: _animationsDuration,
            //padding: EdgeInsets.symmetric(horizontal: EnvoySpacing.medium3),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: EnvoySpacing.xs, vertical: EnvoySpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null)
                    EnvoyIcon(
                      widget.icon!,
                      size: EnvoyIconSize.small,
                      color: _getMainColor(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isPressed && widget.state == ButtonState.active) {
      return EnvoyColors.surface2;
    } else if (isPressed) {
      return EnvoyColors.accentPrimary;
    } else if (widget.state == ButtonState.active) {
      return EnvoyColors.accentPrimary;
    } else if (widget.state == ButtonState.default_state) {
      return EnvoyColors.surface2;
    }

    return EnvoyColors.surface2;
  }

  Color _getMainColor() {
    if (isPressed && widget.state == ButtonState.active) {
      return EnvoyColors.textTertiary;
    } else if (isPressed) {
      return EnvoyColors.textPrimaryInverse;
    } else if (widget.state == ButtonState.active) {
      return EnvoyColors.textPrimaryInverse;
    } else if (widget.state == ButtonState.default_state) {
      return EnvoyColors.textTertiary;
    }

    return EnvoyColors.textTertiary;
  }

  double _getOpacity() {
    return widget.state == ButtonState.disabled ? 0.5 : 1.0;
  }

  bool _isButtonDisabled() {
    return widget.state == ButtonState.disabled;
  }
}
