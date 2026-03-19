// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:flutter/material.dart';

class EnvoyMenuList extends StatelessWidget {
  final List<Widget> children;
  final double width;
  final EdgeInsetsGeometry padding;
  final Alignment alignment;
  final Color barrierColor;
  final Color backgroundColor;
  final BorderRadiusGeometry borderRadius;

  const EnvoyMenuList({
    super.key,
    required this.children,
    this.width = 250,
    this.padding = const EdgeInsets.only(top: 80, right: EnvoySpacing.xs),
    this.alignment = Alignment.topRight,
    this.barrierColor = const Color(0x66000000),
    this.backgroundColor = Colors.white,
    this.borderRadius =
        const BorderRadius.all(Radius.circular(EnvoySpacing.medium1)),
  });

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final routeAnimation =
        ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;
    final menuAnimation = CurvedAnimation(
      parent: routeAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final menuOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -0.04),
      end: Offset.zero,
    ).animate(menuAnimation);
    final menuScaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(menuAnimation);

    return Stack(
      children: [
        FadeTransition(
          opacity: menuAnimation,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => navigator.pop(),
            child: Container(
              color: barrierColor,
            ),
          ),
        ),
        Padding(
          padding: padding,
          child: Align(
            alignment: alignment,
            child: FadeTransition(
              opacity: menuAnimation,
              child: SlideTransition(
                position: menuOffsetAnimation,
                child: ScaleTransition(
                  alignment: alignment,
                  scale: menuScaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: borderRadius,
                    ),
                    width: width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MenuItem extends StatefulWidget {
  final String label;
  final EnvoyIcons icon;
  final Color color;
  final VoidCallback onTap;
  final bool useDivider;

  const MenuItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = EnvoyColors.textPrimary,
    this.useDivider = true,
  });

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  static const _animationDuration = Duration(milliseconds: 160);
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            child: AnimatedScale(
              duration: _animationDuration,
              curve: Curves.easeOut,
              scale: _isPressed ? 0.95 : 1.0,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  end: _isPressed
                      ? widget.color.applyOpacity(0.7)
                      : widget.color,
                ),
                duration: _animationDuration,
                curve: Curves.easeOut,
                builder: (context, animatedColor, child) {
                  final foregroundColor = animatedColor ?? widget.color;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.medium1,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.label,
                          style: EnvoyTypography.body
                              .copyWith(color: foregroundColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: EnvoySpacing.xs),
                        EnvoyIcon(widget.icon, color: foregroundColor),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          widget.useDivider ? const Divider(height: 0) : const SizedBox(),
        ],
      ),
    );
  }
}
