// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/util/easing.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool hidden = false;

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

    hidden = ref.read(balanceHideStateStatusProvider(widget.account.id));
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconController.dispose();
    super.dispose();
  }

  List<Color> disabledColors = [
    Colors.grey,
    Colors.transparent,
    Colors.transparent,
    Colors.grey
  ];
  List<Color> activeColors = [
    EnvoyColors.teal,
    Colors.transparent,
    Colors.transparent,
    EnvoyColors.teal
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                        child: !hidden
                            ? CustomPaint(
                                key: const Key('hiddenIcon'),
                                size: const Size(24, 24),
                                painter: _HiddenEyeIconPainter(
                                  _iconColorAnimation.value ?? Colors.grey,
                                ))
                            : CustomPaint(
                                size: const Size(24, 24),
                                key: const Key('visibleIcon'),
                                painter: _VisibleEyeIconPainter(
                                    _iconColorAnimation.value ?? Colors.grey),
                              ))
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
          onHorizontalDragStart: (details) {
            hidden =
                ref.read(balanceHideStateStatusProvider(widget.account.id));
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
            if (thresholdReached) {
              ref.read(balanceHideNotifierProvider).setHideState(
                  !ref.read(balanceHideStateStatusProvider(widget.account.id)),
                  widget.account);
            }
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

//due to rendering issues with SVGs.
//we are using custom painters to draw the icons,
class _HiddenEyeIconPainter extends CustomPainter {
  Color color;

  _HiddenEyeIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    final Paint paint = Paint();

    // Path 1 Fill
    paint.color = color;
    path.moveTo(size.width * 0.94, size.height);
    path.cubicTo(size.width * 0.93, size.height, size.width * 0.92, size.height,
        size.width * 0.91, size.height * 0.99);
    path.lineTo(size.width * 0.73, size.height * 0.8);
    path.cubicTo(size.width * 0.66, size.height * 0.85, size.width * 0.58,
        size.height * 0.88, size.width * 0.5, size.height * 0.88);
    path.cubicTo(size.width * 0.2, size.height * 0.88, size.width * 0.03,
        size.height * 0.53, size.width * 0.02, size.height * 0.52);
    path.cubicTo(size.width * 0.02, size.height * 0.5, size.width * 0.02,
        size.height * 0.49, size.width * 0.02, size.height * 0.48);
    path.cubicTo(size.width * 0.07, size.height * 0.39, size.width * 0.13,
        size.height * 0.31, size.width * 0.2, size.height * 0.25);
    path.lineTo(size.width * 0.03, size.height * 0.07);
    path.cubicTo(size.width * 0.02, size.height * 0.05, size.width * 0.02,
        size.height * 0.03, size.width * 0.03, size.height * 0.01);
    path.cubicTo(size.width * 0.05, 0, size.width * 0.07, 0, size.width * 0.09,
        size.height * 0.01);
    path.lineTo(size.width * 0.29, size.height * 0.22);
    path.lineTo(size.width * 0.44, size.height * 0.38);
    path.lineTo(size.width * 0.61, size.height * 0.55);
    path.lineTo(size.width * 0.76, size.height * 0.71);
    path.lineTo(size.width * 0.96, size.height * 0.92);
    path.cubicTo(size.width * 0.98, size.height * 0.94, size.width * 0.98,
        size.height * 0.96, size.width * 0.96, size.height * 0.98);
    path.cubicTo(size.width * 0.96, size.height, size.width * 0.95, size.height,
        size.width * 0.94, size.height);
    path.lineTo(size.width * 0.94, size.height);
    path.moveTo(size.width * 0.1, size.height * 0.5);
    path.cubicTo(size.width * 0.14, size.height * 0.57, size.width * 0.28,
        size.height * 0.79, size.width * 0.5, size.height * 0.79);
    path.cubicTo(size.width * 0.56, size.height * 0.79, size.width * 0.62,
        size.height * 0.78, size.width * 0.68, size.height * 0.74);
    path.lineTo(size.width * 0.58, size.height * 0.65);
    path.cubicTo(size.width * 0.56, size.height * 0.66, size.width * 0.53,
        size.height * 0.67, size.width * 0.5, size.height * 0.67);
    path.cubicTo(size.width * 0.46, size.height * 0.67, size.width * 0.42,
        size.height * 0.66, size.width * 0.39, size.height * 0.63);
    path.cubicTo(size.width * 0.36, size.height * 0.6, size.width * 0.34,
        size.height * 0.55, size.width * 0.34, size.height * 0.51);
    path.cubicTo(size.width * 0.34, size.height * 0.48, size.width * 0.34,
        size.height * 0.44, size.width * 0.36, size.height * 0.41);
    path.lineTo(size.width * 0.26, size.height * 0.31);
    path.cubicTo(size.width * 0.2, size.height * 0.36, size.width * 0.15,
        size.height * 0.43, size.width * 0.1, size.height * 0.5);
    path.lineTo(size.width * 0.1, size.height * 0.5);
    path.moveTo(size.width * 0.42, size.height * 0.48);
    path.cubicTo(size.width * 0.42, size.height * 0.48, size.width * 0.42,
        size.height * 0.5, size.width * 0.42, size.height * 0.5);
    path.cubicTo(size.width * 0.42, size.height * 0.53, size.width * 0.42,
        size.height * 0.55, size.width * 0.44, size.height * 0.56);
    path.cubicTo(size.width * 0.46, size.height * 0.58, size.width * 0.48,
        size.height * 0.59, size.width * 0.5, size.height * 0.58);
    path.cubicTo(size.width * 0.5, size.height * 0.58, size.width * 0.51,
        size.height * 0.58, size.width * 0.52, size.height * 0.58);
    path.lineTo(size.width * 0.42, size.height * 0.48);
    path.lineTo(size.width * 0.42, size.height * 0.48);
    path.moveTo(size.width * 0.85, size.height * 0.67);
    path.cubicTo(size.width * 0.84, size.height * 0.67, size.width * 0.83,
        size.height * 0.67, size.width * 0.83, size.height * 0.67);
    path.cubicTo(size.width * 0.81, size.height * 0.65, size.width * 0.81,
        size.height * 0.63, size.width * 0.82, size.height * 0.61);
    path.cubicTo(size.width * 0.85, size.height * 0.58, size.width * 0.88,
        size.height * 0.54, size.width * 0.9, size.height * 0.5);
    path.cubicTo(size.width * 0.86, size.height * 0.44, size.width * 0.72,
        size.height * 0.21, size.width * 0.5, size.height * 0.21);
    path.cubicTo(size.width * 0.48, size.height * 0.21, size.width * 0.45,
        size.height * 0.22, size.width * 0.42, size.height * 0.22);
    path.cubicTo(size.width * 0.4, size.height * 0.22, size.width * 0.38,
        size.height * 0.21, size.width * 0.38, size.height * 0.19);
    path.cubicTo(size.width * 0.37, size.height * 0.16, size.width * 0.38,
        size.height * 0.14, size.width * 0.41, size.height * 0.14);
    path.cubicTo(size.width * 0.44, size.height * 0.13, size.width * 0.47,
        size.height * 0.13, size.width * 0.5, size.height * 0.13);
    path.cubicTo(size.width * 0.8, size.height * 0.13, size.width * 0.97,
        size.height * 0.47, size.width * 0.98, size.height * 0.48);
    path.cubicTo(size.width * 0.98, size.height * 0.5, size.width * 0.98,
        size.height * 0.51, size.width * 0.98, size.height * 0.52);
    path.cubicTo(size.width * 0.95, size.height * 0.57, size.width * 0.92,
        size.height * 0.62, size.width * 0.88, size.height * 0.66);
    path.cubicTo(size.width * 0.88, size.height * 0.67, size.width * 0.86,
        size.height * 0.67, size.width * 0.85, size.height * 0.67);
    path.lineTo(size.width * 0.85, size.height * 0.67);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _VisibleEyeIconPainter extends CustomPainter {
  Color color;

  _VisibleEyeIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    final Paint paint = Paint();

    // Path 1 Fill
    paint.color = color;
    path.moveTo(size.width * 0.5, size.height * 0.88);
    path.cubicTo(size.width * 0.2, size.height * 0.88, size.width * 0.03,
        size.height * 0.53, size.width * 0.02, size.height * 0.52);
    path.cubicTo(size.width * 0.02, size.height * 0.5, size.width * 0.02,
        size.height * 0.49, size.width * 0.02, size.height * 0.48);
    path.cubicTo(size.width * 0.03, size.height * 0.47, size.width * 0.2,
        size.height * 0.13, size.width * 0.5, size.height * 0.13);
    path.cubicTo(size.width * 0.8, size.height * 0.13, size.width * 0.97,
        size.height * 0.47, size.width * 0.98, size.height * 0.48);
    path.cubicTo(size.width * 0.98, size.height * 0.5, size.width * 0.98,
        size.height * 0.51, size.width * 0.98, size.height * 0.52);
    path.cubicTo(size.width * 0.97, size.height * 0.53, size.width * 0.8,
        size.height * 0.88, size.width * 0.5, size.height * 0.88);
    path.lineTo(size.width * 0.5, size.height * 0.88);
    path.moveTo(size.width * 0.1, size.height * 0.5);
    path.cubicTo(size.width * 0.14, size.height * 0.57, size.width * 0.28,
        size.height * 0.79, size.width * 0.5, size.height * 0.79);
    path.cubicTo(size.width * 0.72, size.height * 0.79, size.width * 0.86,
        size.height * 0.57, size.width * 0.9, size.height * 0.5);
    path.cubicTo(size.width * 0.86, size.height * 0.43, size.width * 0.72,
        size.height * 0.21, size.width * 0.5, size.height * 0.21);
    path.cubicTo(size.width * 0.28, size.height * 0.21, size.width * 0.14,
        size.height * 0.43, size.width * 0.1, size.height * 0.5);
    path.lineTo(size.width * 0.1, size.height * 0.5);
    path.moveTo(size.width * 0.5, size.height * 0.67);
    path.cubicTo(size.width * 0.41, size.height * 0.67, size.width * 0.34,
        size.height * 0.59, size.width * 0.34, size.height * 0.5);
    path.cubicTo(size.width * 0.34, size.height * 0.41, size.width * 0.41,
        size.height * 0.33, size.width * 0.5, size.height * 0.33);
    path.cubicTo(size.width * 0.59, size.height * 0.33, size.width * 0.66,
        size.height * 0.41, size.width * 0.66, size.height * 0.5);
    path.cubicTo(size.width * 0.66, size.height * 0.59, size.width * 0.59,
        size.height * 0.67, size.width * 0.5, size.height * 0.67);
    path.lineTo(size.width * 0.5, size.height * 0.67);
    path.moveTo(size.width * 0.5, size.height * 0.42);
    path.cubicTo(size.width * 0.46, size.height * 0.42, size.width * 0.42,
        size.height * 0.45, size.width * 0.42, size.height * 0.5);
    path.cubicTo(size.width * 0.42, size.height * 0.55, size.width * 0.46,
        size.height * 0.58, size.width * 0.5, size.height * 0.58);
    path.cubicTo(size.width * 0.54, size.height * 0.58, size.width * 0.58,
        size.height * 0.55, size.width * 0.58, size.height * 0.5);
    path.cubicTo(size.width * 0.58, size.height * 0.45, size.width * 0.54,
        size.height * 0.42, size.width * 0.5, size.height * 0.42);
    path.lineTo(size.width * 0.5, size.height * 0.42);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
