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
  defaultState,
  loading,
  hover,
  focus,
  pressed,
  disabled,
}

class EnvoyButton extends StatefulWidget {
  final String label;
  final ButtonType type;
  final ButtonState state;
  final EnvoyIcons? icon;
  final double height;
  final Function? onTap;

  const EnvoyButton({super.key,
    required this.label,
    required this.type,
    required this.state,
    this.icon,
    this.onTap,
    this.height = 48.0,
  });

  @override
  EnvoyButtonState createState() => EnvoyButtonState();
}

class EnvoyButtonState extends State<EnvoyButton> {
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
          });
        },
        child: Opacity(
          opacity: _getOpacity(),
          child: AnimatedContainer(
            duration: _animationsDuration,
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(EnvoySpacing.small),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 230),
                    opacity: widget.state == ButtonState.loading ? 1 : 0,
                    child: SizedBox.square(
                      dimension: widget.height,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 1,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: widget.state == ButtonState.loading ? 0 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.xs,
                          vertical: EnvoySpacing.small),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: EnvoySpacing.small),
                              child: EnvoyIcon(
                                widget.icon!,
                                size: EnvoyIconSize.small,
                                color: _getMainColor(),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: EnvoySpacing.xs),
                            child: Text(
                              widget.label,
                              style: EnvoyTypography.button.copyWith(
                                color: _getMainColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
    if (isPressed) {
      if (widget.type == ButtonType.secondary) return EnvoyColors.border2;
      return EnvoyColors.surface2;
    }

    if (widget.type == ButtonType.secondary) return EnvoyColors.surface2;
    if (widget.type == ButtonType.tertiary) {
      return EnvoyColors.textPrimaryInverse;
    }
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
