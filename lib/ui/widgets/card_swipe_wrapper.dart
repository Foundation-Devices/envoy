// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/util/easing.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardSwipeWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final double height;
  final Account account;
  final bool draggable;

  const CardSwipeWrapper(
      {super.key,
      required this.child,
      required this.height,
      required this.account,
      required this.draggable});

  @override
  ConsumerState<CardSwipeWrapper> createState() => _CardSwipeWrapperState();
}

class _CardSwipeWrapperState extends ConsumerState<CardSwipeWrapper>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _iconController;

  double _offsetX = 0.0;

  late Animation<double> _animation;

  late Animation<Color?> _iconColorAnimation;

  //Swipe threshold for triggering the action
  final threshold = 0.2;
  bool thresholdReached = false;

  void _runSpringSimulation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      Tween(
        begin: _offsetX,
        end: 0.0,
      ),
    );
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 12,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _iconColorAnimation = ColorTween(
      begin: EnvoyColors.grey,
      end: EnvoyColors.teal,
    ).animate(CurvedAnimation(parent: _iconController, curve: Curves.ease));

    _controller.addListener(() {
      setState(() {
        _offsetX = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconController.dispose();
    super.dispose();
  }

  List<Color> disabledColors = [
    Colors.grey,
    Colors.white,
    Colors.white,
    Colors.grey
  ];
  List<Color> activeColors = [
    EnvoyColors.teal,
    Colors.white,
    Colors.white,
    EnvoyColors.teal
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hidden = ref.watch(balanceHideStateStatusProvider(widget.account.id));
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: widget.height,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              border: GradientBoxBorder(
                gradient: LinearGradient(
                    colors: thresholdReached ? activeColors : disabledColors),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(26)),
          child: Consumer(
            builder: (context, ref, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 120),
                      switchInCurve: EnvoyEasing.defaultEasing,
                      switchOutCurve: EnvoyEasing.defaultEasing,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: hidden
                          ? SvgPicture.asset(
                              width: EnvoySpacing.medium2,
                              height: EnvoySpacing.medium2,
                              'assets/icons/ic_eye_hidden.svg',
                              color: _iconColorAnimation.value,
                              key: const ValueKey('ic_eye_hidden'),
                            )
                          : SvgPicture.asset(
                              width: EnvoySpacing.medium2,
                              height: EnvoySpacing.medium2,
                              'assets/icons/ic_eye_visible.svg',
                              color: _iconColorAnimation.value,
                              key: const ValueKey('ic_eye_visible'),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        GestureDetector(
          onHorizontalDragDown: (details) {
            if (!widget.draggable) {
              return;
            }
            thresholdReached = false;
            _controller.stop();
            _iconController.reverse();
          },
          onHorizontalDragUpdate: (details) {
            if (!widget.draggable) {
              return;
            }
            if (details.delta.dx > 0) {
              return;
            }
            double dragRate = (_offsetX * size.width * .5) / size.width;

            //Limit the drag
            if (dragRate.abs() >= 0.4) {
              return;
            }
            setState(() {
              //set the the current offset for translation
              _offsetX += details.delta.dx / (size.width / 2);
              if ((dragRate.abs()) >= threshold && thresholdReached == false) {
                thresholdReached = true;
                Haptics.lightImpact();
                _iconController.forward();
                //toggle the hide state
                ref.read(balanceHideNotifierProvider).setHideState(
                    !ref.read(
                        balanceHideStateStatusProvider(widget.account.id)),
                    widget.account);
              }
            });
            if (dragRate == 0) {
              setState(() {
                thresholdReached = false;
              });
            }
          },
          onHorizontalDragEnd: (details) {
            if (!widget.draggable) {
              return;
            }
            //return to the original position with spring animation
            _runSpringSimulation(details.velocity.pixelsPerSecond, size);
          },
          child: Transform.translate(
            offset: Offset(_offsetX * size.width * .5, 0.0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBoxBorder({required this.gradient, this.width = 1.0});

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    switch (shape) {
      case BoxShape.circle:
        assert(borderRadius == null,
            'A borderRadius can only be given for rectangular boxes.');
        _paintCircle(canvas, rect);
        break;
      case BoxShape.rectangle:
        if (borderRadius != null) {
          _paintRRect(canvas, rect, borderRadius);
          return;
        }
        _paintRect(canvas, rect);
        break;
    }
  }

  void _paintRect(Canvas canvas, Rect rect) {
    canvas.drawRect(rect.deflate(width / 2), _getPaint(rect));
  }

  void _paintRRect(Canvas canvas, Rect rect, BorderRadius borderRadius) {
    final RRect rrect = borderRadius.toRRect(rect).deflate(width / 2);
    canvas.drawRRect(rrect, _getPaint(rect));
  }

  void _paintCircle(Canvas canvas, Rect rect) {
    final Paint paint = _getPaint(rect);
    final double radius = (rect.shortestSide - width) / 2.0;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return this;
  }

  Paint _getPaint(Rect rect) {
    return Paint()
      ..strokeWidth = width
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke;
  }
}
