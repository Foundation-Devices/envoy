// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/haptics.dart';

enum ButtonType {
  primary,
  secondary,
  tertiary,
  copper,
  danger,
}

enum ButtonState {
  default_state,
  hover,
  focus,
  pressed,
  disabled,
}

class EnvoyButton extends StatefulWidget {
  final String label;
  late final ButtonType type;
  final ButtonState state;
  final icon;
  final Function? onTap;

  EnvoyButton({
    required this.label,
    required this.type,
    required this.state,
    this.icon,
    this.onTap,
  });

  @override
  _EnvoyButtonState createState() => _EnvoyButtonState();
}

class _EnvoyButtonState extends State<EnvoyButton> {
  bool isPressed = false;
  final _animationsDuration = Duration(milliseconds: 200);

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
          });
        },
        child: Opacity(
          opacity: _getOpacity(),
          child: AnimatedContainer(
            duration: _animationsDuration,
            padding: EdgeInsets.symmetric(horizontal: EnvoySpacing.medium3),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(EnvoySpacing.small),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: EnvoySpacing.medium3,
                    vertical: EnvoySpacing.small),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null)
                      Padding(
                        padding:
                            const EdgeInsets.only(right: EnvoySpacing.small),
                        child: EnvoyIcon(
                          widget.icon,
                          size: EnvoyIconSize.small,
                          color: _getMainColor(),
                        ),
                      ),
                    Text(
                      widget.label,
                      style: EnvoyTypography.subtitle3Semibold.copyWith(
                        color: _getMainColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isPressed) {
      if (widget.type == ButtonType.secondary) return EnvoyColors.border2;
      return EnvoyColors.surface2;
    }

    if (widget.type == ButtonType.secondary) return EnvoyColors.surface2;
    if (widget.type == ButtonType.tertiary)
      return EnvoyColors.textPrimaryInverse;
    if (widget.type == ButtonType.copper) return EnvoyColors.accentSecondary;
    if (widget.type == ButtonType.danger) return EnvoyColors.danger;
    return EnvoyColors.accentPrimary;
  }

  Color _getMainColor() {
    if (isPressed) {
      return EnvoyColors.accentPrimary;
    }
    if (widget.type == ButtonType.secondary ||
        widget.type == ButtonType.tertiary) return EnvoyColors.accentPrimary;

    return EnvoyColors.textPrimaryInverse;
  }

  double _getOpacity() {
    return widget.state == ButtonState.disabled ? 0.5 : 1.0;
  }

  bool _isButtonDisabled() {
    return widget.state == ButtonState.disabled;
  }
}
