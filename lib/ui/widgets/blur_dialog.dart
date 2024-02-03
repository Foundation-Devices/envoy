// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';

class BlurDialogRoute<T> extends OverlayRoute<T> {
  Animation<double>? _elevation;
  Animation<double>? _filterBlurAnimation;
  Animation<double>? _fade;
  Animation<Color?>? _filterColorAnimation;
  double blur = 6;
  Color blurColor;
  Color? cardColor;
  double borderRadius;
  final Alignment alignment;
  bool dismissible;

  Builder builder;
  late AnimationController _controller;
  Animation<Alignment>? _animation;

  BlurDialogRoute({
    required this.builder,
    RouteSettings? settings,
    this.blur = 6,
    this.blurColor = Colors.black,
    this.dismissible = true,
    this.alignment = Alignment.center,
    this.cardColor,
    this.borderRadius = 14,
  }) : super(settings: settings);

  @override
  Future<RoutePopDisposition> willPop() async {
    return dismissible ? RoutePopDisposition.pop : RoutePopDisposition.doNotPop;
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    final overlays = <OverlayEntry>[];

    //blur background overlay
    overlays.add(
      OverlayEntry(
          builder: (BuildContext context) {
            return createOverlayBlur();
          },
          maintainState: false,
          opaque: false),
    );

    overlays.add(
      OverlayEntry(
          builder: (BuildContext context) {
            final Widget annotatedChild = Semantics(
              focused: false,
              container: true,
              explicitChildNodes: true,
              child: AlignTransition(
                alignment: _animation!,
                child: Material(
                  color: Colors.transparent,
                  child: SafeArea(
                    minimum: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: FadeTransition(
                      opacity: _fade!,
                      child: Card(
                          color: cardColor,
                          elevation: _elevation?.value,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(borderRadius)),
                          child: Builder(
                            builder: this.builder.build,
                          )),
                    ),
                  ),
                ),
              ),
            );
            return annotatedChild;
          },
          maintainState: false,
          opaque: false),
    );

    return overlays;
  }

  Widget createOverlayBlur() {
    return GestureDetector(
      onTap: () {
        if (this.dismissible && !this._controller.isAnimating) {
          navigator?.pop();
        }
      },
      child: AnimatedBuilder(
        animation: _filterBlurAnimation!,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: _filterBlurAnimation!.value,
                sigmaY: _filterBlurAnimation!.value),
            child: Container(
              constraints: const BoxConstraints.expand(),
              color: _filterColorAnimation!.value,
            ),
          );
        },
      ),
    );
  }

  @override
  void install() {
    _controller = AnimationController(
      duration: Duration(milliseconds: 260),
      vsync: navigator!,
    );
    _filterBlurAnimation = createBlurFilterAnimation();
    _filterColorAnimation = createColorFilterAnimation();

    _animation =
        AlignmentTween(begin: const Alignment(0.0, 1.0), end: alignment)
            .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
        reverseCurve: Curves.easeOutExpo,
      ),
    );

    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.4,
          1.0,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );

    _elevation = Tween(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          1.0,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
    super.install();
  }

  Animation<double>? createBlurFilterAnimation() {
    return Tween(begin: 0.0, end: blur).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
  }

  @override
  TickerFuture didPush() {
    _animation!.addStatusListener(_handleStatusChanged);
    super.didPush();
    return _controller.forward();
  }

  @override
  bool didPop(T? result) {
    _controller.reverse();
    return super.didPop(result);
  }

  Animation<Color?>? createColorFilterAnimation() {
    return ColorTween(
            begin: Colors.transparent, end: blurColor.withOpacity(0.26))
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get finishedWhenPopped =>
      _controller.status == AnimationStatus.dismissed;

  void _handleStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        if (!isCurrent) {
          navigator!.finalizeRoute(this);
          if (overlayEntries.isNotEmpty) {
            overlayEntries.clear();
          }
          assert(overlayEntries.isEmpty);
        }
        break;
      case AnimationStatus.forward:
        break;
      case AnimationStatus.reverse:
        break;
      case AnimationStatus.completed:
        break;
    }
    changedInternalState();
  }
}

// Shows a dialog with a blur background
Future<T?> showEnvoyDialog<T>(
    {required BuildContext context,
    Color blurColor = Colors.black38,
    Color? cardColor,
    double blur = 6,
    routeSettings,
    Widget? dialog,
    bool useRootNavigator = false,
    Alignment alignment = Alignment.center,
    Builder? builder,
    bool dismissible = true,
    double borderRadius = EnvoySpacing.medium2}) async {
  var route = BlurDialogRoute<T>(
      blur: blur,
      builder: builder ?? Builder(builder: (context) => dialog ?? Container()),
      blurColor: blurColor,
      cardColor: cardColor,
      alignment: alignment,
      dismissible: dismissible,
      settings: routeSettings,
      borderRadius: borderRadius);
  return await Navigator.of(context, rootNavigator: useRootNavigator)
      .push(route);
}
