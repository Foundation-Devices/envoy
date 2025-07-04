// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Signature for `action` callback function provided to [BlurContainerTransform.openBuilder].
///
/// Parameter `returnValue` is the value which will be provided to [BlurContainerTransform.onClosed]
/// when `action` is called.
typedef CloseContainerActionCallback<S> = void Function({S? returnValue});

/// Signature for a function that creates a [Widget] in open state within an
/// [BlurContainerTransform].
///
/// The `action` callback provided to [BlurContainerTransform.openBuilder] can be used
/// to close the container.
typedef OpenContainerBuilder<S> = Widget Function(
  BuildContext context,
  CloseContainerActionCallback<S> action,
);

/// Signature for a function that creates a [Widget] in closed state within an
/// [BlurContainerTransform].
///
/// The `action` callback provided to [BlurContainerTransform.closedBuilder] can be used
/// to open the container.
typedef CloseContainerBuilder = Widget Function(
  BuildContext context,
  VoidCallback action,
);

/// The [BlurContainerTransform] widget's fade transition type.
///
/// This determines the type of fade transition that the incoming and outgoing
/// contents will use.
enum ContainerTransitionType {
  /// Fades the incoming element in over the outgoing element.
  fade,

  /// First fades the outgoing element out, and starts fading the incoming
  /// element in once the outgoing element has completely faded out.
  fadeThrough,
}

/// Callback function which is called when the [BlurContainerTransform]
/// is closed.
typedef ClosedCallback<S> = void Function(S data);

/// Specifically tweaked for TagDetails
/// A container that grows to fill the screen to reveal new content when tapped.
///
/// While the container is closed, it shows the [Widget] returned by
/// [closedBuilder]. When the container is tapped it grows to fill the entire
/// size of the surrounding [Navigator] while fading out the widget returned by
/// [closedBuilder] and fading in the widget returned by [openBuilder]. When the
/// container is closed again via the callback provided to [openBuilder] or via
/// Android's back button, the animation is reversed: The container shrinks back
/// to its original size while the widget returned by [openBuilder] is faded out
/// and the widget returned by [closedBuilder] is faded back in.
///
/// By default, the container is in the closed state. During the transition from
/// closed to open and vice versa the widgets returned by the [openBuilder] and
/// [closedBuilder] exist in the tree at the same time. Therefore, the widgets
/// returned by these builders cannot include the same global key.
///
/// `T` refers to the type of data returned by the route when the container
/// is closed. This value can be accessed in the `onClosed` function.
///
///
/// See also:
///
///  * [Transitions with animated containers](https://material.io/design/motion/choreography.html#transformation)
///    in the Material spec.
///
///
///
const scrimBlackColor = Colors.black38;

@optionalTypeArgs
class BlurContainerTransform<T extends Object?> extends StatefulWidget {
  /// Creates an [BlurContainerTransform].
  ///
  /// All arguments except for [key] must not be null. The arguments
  /// [openBuilder] and [closedBuilder] are required.
  const BlurContainerTransform({
    super.key,
    this.closedColor = Colors.white,
    this.openColor = Colors.white,
    this.middleColor,
    this.onTap,
    this.closedElevation = 1.0,
    this.openElevation = 4.0,
    this.closedShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    this.openShape = const RoundedRectangleBorder(),
    this.onClosed,
    required this.closedBuilder,
    required this.openBuilder,
    this.tappable = true,
    this.transitionDuration = const Duration(milliseconds: 380),
    this.transitionType = ContainerTransitionType.fade,
    this.useRootNavigator = false,
    this.routeSettings,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Background color of the container while it is closed.
  ///
  /// When the container is opened, it will first transition from this color
  /// to [middleColor] and then transition from there to [openColor] in one
  /// smooth animation. When the container is closed, it will transition back to
  /// this color from [openColor] via [middleColor].
  ///
  /// Defaults to [Colors.white].
  ///
  /// See also:
  ///
  ///  * [Material.color], which is used to implement this property.
  final Color closedColor;

  /// Background color of the container while it is open.
  ///
  /// When the container is closed, it will first transition from [closedColor]
  /// to [middleColor] and then transition from there to this color in one
  /// smooth animation. When the container is closed, it will transition back to
  /// [closedColor] from this color via [middleColor].
  ///
  /// Defaults to [Colors.white].
  ///
  /// See also:
  ///
  ///  * [Material.color], which is used to implement this property.
  final Color openColor;

  final GestureTapCallback? onTap;

  /// The color to use for the background color during the transition
  /// with [ContainerTransitionType.fadeThrough].
  ///
  /// Defaults to [Theme]'s [ThemeData.canvasColor].
  ///
  /// See also:
  ///
  ///  * [Material.color], which is used to implement this property.
  final Color? middleColor;

  /// Elevation of the container while it is closed.
  ///
  /// When the container is opened, it will transition from this elevation to
  /// [openElevation]. When the container is closed, it will transition back
  /// from [openElevation] to this elevation.
  ///
  /// Defaults to 1.0.
  ///
  /// See also:
  ///
  ///  * [Material.elevation], which is used to implement this property.
  final double closedElevation;

  /// Elevation of the container while it is open.
  ///
  /// When the container is opened, it will transition to this elevation from
  /// [closedElevation]. When the container is closed, it will transition back
  /// from this elevation to [closedElevation].
  ///
  /// Defaults to 4.0.
  ///
  /// See also:
  ///
  ///  * [Material.elevation], which is used to implement this property.
  final double openElevation;

  /// Shape of the container while it is closed.
  ///
  /// When the container is opened it will transition from this shape to
  /// [openShape]. When the container is closed, it will transition back to this
  /// shape.
  ///
  /// Defaults to a [RoundedRectangleBorder] with a [Radius.circular] of 4.0.
  ///
  /// See also:
  ///
  ///  * [Material.shape], which is used to implement this property.
  final ShapeBorder closedShape;

  /// Shape of the container while it is open.
  ///
  /// When the container is opened it will transition from [closedShape] to
  /// this shape. When the container is closed, it will transition from this
  /// shape back to [closedShape].
  ///
  /// Defaults to a rectangular.
  ///
  /// See also:
  ///
  ///  * [Material.shape], which is used to implement this property.
  final ShapeBorder openShape;

  /// Called when the container was popped and has returned to the closed state.
  ///
  /// The return value from the popped screen is passed to this function as an
  /// argument.
  ///
  /// If no value is returned via [Navigator.pop] or [BlurContainerTransform.openBuilder.action],
  /// `null` will be returned by default.
  final ClosedCallback<T?>? onClosed;

  /// Called to obtain the child for the container in the closed state.
  ///
  /// The [Widget] returned by this builder is faded out when the container
  /// opens and at the same time the widget returned by [openBuilder] is faded
  /// in while the container grows to fill the surrounding [Navigator].
  ///
  /// The `action` callback provided to the builder can be called to open the
  /// container.
  final CloseContainerBuilder closedBuilder;

  /// Called to obtain the child for the container in the open state.
  ///
  /// The [Widget] returned by this builder is faded in when the container
  /// opens and at the same time the widget returned by [closedBuilder] is
  /// faded out while the container grows to fill the surrounding [Navigator].
  ///
  /// The `action` callback provided to the builder can be called to close the
  /// container.
  final OpenContainerBuilder<T> openBuilder;

  /// Whether the entire closed container can be tapped to open it.
  ///
  /// Defaults to true.
  ///
  /// When this is set to false the container can only be opened by calling the
  /// `action` callback that is provided to the [closedBuilder].
  final bool tappable;

  /// The time it will take to animate the container from its closed to its
  /// open state and vice versa.
  ///
  /// Defaults to 300ms.
  final Duration transitionDuration;

  /// The type of fade transition that the container will use for its
  /// incoming and outgoing widgets.
  ///
  /// Defaults to [ContainerTransitionType.fade].
  final ContainerTransitionType transitionType;

  /// The [useRootNavigator] argument is used to determine whether to push the
  /// route for [openBuilder] to the Navigator furthest from or nearest to
  /// the given context.
  ///
  /// By default, [useRootNavigator] is false and the route created will push
  /// to the nearest navigator.
  final bool useRootNavigator;

  /// Provides additional data to the [openBuilder] route pushed by the Navigator.
  final RouteSettings? routeSettings;

  /// The [closedBuilder] will be clipped (or not) according to this option.
  ///
  /// Defaults to [Clip.antiAlias], and must not be null.
  ///
  /// See also:
  ///
  ///  * [Material.clipBehavior], which is used to implement this property.
  final Clip clipBehavior;

  @override
  State<BlurContainerTransform<T?>> createState() =>
      _BlurContainerTransformState<T>();
}

class _BlurContainerTransformState<T>
    extends State<BlurContainerTransform<T?>> {
  // Key used in [_OpenContainerRoute] to hide the widget returned by
  // [OpenContainer.openBuilder] in the source route while the container is
  // opening/open. A copy of that widget is included in the
  // [_OpenContainerRoute] where it fades out. To avoid issues with double
  // shadows and transparency, we hide it in the source route.
  final GlobalKey<_HideableState> _hideableKey = GlobalKey<_HideableState>();

  // Key used to steal the state of the widget returned by
  // [OpenContainer.openBuilder] from the source route and attach it to the
  // same widget included in the [_OpenContainerRoute] where it fades out.
  final GlobalKey _closedBuilderKey = GlobalKey();

  // Add state for visual feedback
  bool _isPressed = false;

  Future<void> openContainer() async {
    widget.onTap?.call();

    // Set pressed state for visual feedback
    setState(() => _isPressed = true);

    // Add haptic feedback for immediate response
    HapticFeedback.lightImpact();

    final Color middleColor =
        widget.middleColor ?? Theme.of(context).canvasColor;
    final T? data = await Navigator.of(
      context,
      rootNavigator: widget.useRootNavigator,
    ).push(_OpenContainerRoute<T>(
      closedColor: widget.closedColor,
      openColor: widget.openColor,
      middleColor: middleColor,
      closedElevation: widget.closedElevation,
      openElevation: widget.openElevation,
      closedShape: widget.closedShape,
      openShape: widget.openShape,
      closedBuilder: widget.closedBuilder,
      openBuilder: widget.openBuilder,
      hideableKey: _hideableKey,
      closedBuilderKey: _closedBuilderKey,
      transitionDuration: widget.transitionDuration,
      transitionType: widget.transitionType,
      useRootNavigator: widget.useRootNavigator,
      routeSettings: widget.routeSettings,
    ));

    // Reset pressed state when returned
    if (mounted) {
      setState(() => _isPressed = false);
    }

    if (widget.onClosed != null) {
      widget.onClosed!(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Hideable(
      key: _hideableKey,
      child: GestureDetector(
        onTap: widget.tappable ? openContainer : null,
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Material(
            clipBehavior: widget.clipBehavior,
            color: Colors.transparent,
            elevation: 0,
            shape: widget.closedShape,
            child: Builder(
              key: _closedBuilderKey,
              builder: (BuildContext context) {
                return widget.closedBuilder(context, openContainer);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Controls the visibility of its child.
///
/// The child can be in one of three states:
///
///  * It is included in the tree and fully visible. (The `placeholderSize` is
///    null and `isVisible` is true.)
///  * It is included in the tree, but not visible; its size is maintained.
///    (The `placeholderSize` is null and `isVisible` is false.)
///  * It is not included in the tree. Instead a [SizedBox] of dimensions
///    specified by `placeholderSize` is included in the tree. (The value of
///    `isVisible` is ignored).
class _Hideable extends StatefulWidget {
  const _Hideable({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<_Hideable> createState() => _HideableState();
}

class _HideableState extends State<_Hideable> {
  /// When non-null the child is replaced by a [SizedBox] of the set size.
  Size? get placeholderSize => _placeholderSize;
  Size? _placeholderSize;

  set placeholderSize(Size? value) {
    if (_placeholderSize == value) {
      return;
    }
    setState(() {
      _placeholderSize = value;
    });
  }

  /// When true the child is not visible, but will maintain its size.
  ///
  /// The value of this property is ignored when [placeholderSize] is non-null
  /// (i.e. [isInTree] returns false).
  bool get isVisible => _visible;
  bool _visible = true;

  set isVisible(bool value) {
    if (_visible == value) {
      return;
    }
    setState(() {
      _visible = value;
    });
  }

  /// Whether the child is currently included in the tree.
  ///
  /// When it is included, it may be visible or not according to [isVisible].
  bool get isInTree => _placeholderSize == null;

  @override
  Widget build(BuildContext context) {
    if (_placeholderSize != null) {
      return SizedBox.fromSize(size: _placeholderSize);
    }
    return Visibility(
      visible: _visible,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      child: widget.child,
    );
  }
}

class _OpenContainerRoute<T> extends ModalRoute<T> {
  _OpenContainerRoute({
    required this.closedColor,
    required this.openColor,
    required this.middleColor,
    required double closedElevation,
    required this.openElevation,
    required ShapeBorder closedShape,
    required this.openShape,
    required this.closedBuilder,
    required this.openBuilder,
    required this.hideableKey,
    required this.closedBuilderKey,
    required this.transitionDuration,
    required this.transitionType,
    required this.useRootNavigator,
    required RouteSettings? routeSettings,
  })  :
        // _elevationTween = Tween<double>(
        //   begin: closedElevation,
        //   end: openElevation,
        // ),
        _shapeTween = ShapeBorderTween(
          begin: closedShape,
          end: openShape,
        ),
        _colorTween = _getColorTween(
          transitionType: transitionType,
          closedColor: closedColor,
          openColor: openColor,
          middleColor: middleColor,
        ),
        _closedOpacityTween = _getClosedOpacityTween(transitionType),
        _openOpacityTween = _getOpenOpacityTween(transitionType),
        super(settings: routeSettings);

  static _FlippableTweenSequence<Color?> _getColorTween({
    required ContainerTransitionType transitionType,
    required Color closedColor,
    required Color openColor,
    required Color middleColor,
  }) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<Color?>(
          <TweenSequenceItem<Color?>>[
            TweenSequenceItem<Color>(
              tween: ConstantTween<Color>(closedColor),
              weight: 1 / 5,
            ),
            TweenSequenceItem<Color?>(
              tween: ColorTween(begin: closedColor, end: openColor),
              weight: 1 / 5,
            ),
            TweenSequenceItem<Color>(
              tween: ConstantTween<Color>(openColor),
              weight: 3 / 5,
            ),
          ],
        );
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<Color?>(
          <TweenSequenceItem<Color?>>[
            TweenSequenceItem<Color?>(
              tween: ColorTween(begin: closedColor, end: middleColor),
              weight: 1 / 5,
            ),
            TweenSequenceItem<Color?>(
              tween: ColorTween(begin: middleColor, end: openColor),
              weight: 4 / 5,
            ),
          ],
        );
    }
  }

  static _FlippableTweenSequence<double> _getClosedOpacityTween(
      ContainerTransitionType transitionType) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: ConstantTween(1),
              weight: 0.5,
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(0.0),
              weight: .5,
            ),
          ],
        );
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 1.0, end: 0.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(0.0),
              weight: 4 / 5,
            ),
          ],
        );
    }
  }

  static _FlippableTweenSequence<double> _getOpenOpacityTween(
      ContainerTransitionType transitionType) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(0.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(1.0),
              weight: 3 / 5,
            ),
          ],
        );
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(0.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              weight: 4 / 5,
            ),
          ],
        );
    }
  }

  final Color closedColor;
  final Color openColor;
  final Color middleColor;
  final double openElevation;
  final ShapeBorder openShape;
  final CloseContainerBuilder closedBuilder;
  final OpenContainerBuilder<T> openBuilder;

  // See [_OpenContainerState._hideableKey].
  final GlobalKey<_HideableState> hideableKey;

  // See [_OpenContainerState._closedBuilderKey].
  final GlobalKey closedBuilderKey;

  @override
  final Duration transitionDuration;
  final ContainerTransitionType transitionType;

  final bool useRootNavigator;

  // final Tween<double> _elevationTween;
  final ShapeBorderTween _shapeTween;
  final _FlippableTweenSequence<double> _closedOpacityTween;
  final _FlippableTweenSequence<double> _openOpacityTween;
  final _FlippableTweenSequence<Color?> _colorTween;

  // static final TweenSequence<Color?> _scrimFadeInTween = TweenSequence<Color?>(
  //   <TweenSequenceItem<Color?>>[
  //     TweenSequenceItem<Color?>(
  //       tween: ColorTween(begin: Colors.transparent, end: scrimBlackColor),
  //       weight: 1 / 5,
  //     ),
  //     TweenSequenceItem<Color>(
  //       tween: ConstantTween<Color>(scrimBlackColor),
  //       weight: 4 / 5,
  //     ),
  //   ],
  // );
  // static final Tween<Color?> _scrimFadeOutTween = ColorTween(
  //   begin: Colors.transparent,
  //   end: scrimBlackColor,
  // );

  // Key used for the widget returned by [OpenContainer.openBuilder] to keep
  // its state when the shape of the widget tree is changed at the end of the
  // animation to remove all the craft that was necessary to make the animation
  // work.
  final GlobalKey _openBuilderKey = GlobalKey();

  // Defines the position and the size of the (opening) [OpenContainer] within
  // the bounds of the enclosing [Navigator].
  final RectTween _rectTween = RectTween();

  AnimationStatus? _lastAnimationStatus;
  AnimationStatus? _currentAnimationStatus;

  @override
  TickerFuture didPush() {
    _takeMeasurements(navigatorContext: hideableKey.currentContext!);

    animation!.addStatusListener((AnimationStatus status) {
      _lastAnimationStatus = _currentAnimationStatus;
      _currentAnimationStatus = status;
      switch (status) {
        case AnimationStatus.dismissed:
          // First attempt to restore the hideable widget
          _toggleHideable(hide: false);

          // Schedule another attempt after a short delay (50ms)
          // This ensures that if the first attempt happens before measurements update,
          // the second attempt will correctly restore the placeholder size after the frame stabilizes.
          Future.delayed(const Duration(milliseconds: 50), () {
            _toggleHideable(hide: false);
          });
          break;
        case AnimationStatus.completed:
          _toggleHideable(hide: true);
          break;
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
      }
    });

    return super.didPush();
  }

  @override
  bool didPop(T? result) {
    _takeMeasurements(
      navigatorContext: subtreeContext!,
      delayForSourceRoute: true,
    );
    return super.didPop(result);
  }

  @override
  void dispose() {
    if (hideableKey.currentState?.isVisible == false) {
      // This route may be disposed without dismissing its animation if it is
      // removed by the navigator.
      SchedulerBinding.instance
          .addPostFrameCallback((Duration d) => _toggleHideable(hide: false));
    }
    super.dispose();
  }

  void _toggleHideable({required bool hide}) {
    if (hideableKey.currentState != null) {
      hideableKey.currentState!
        ..placeholderSize = null
        ..isVisible = !hide;
    }
  }

  void _takeMeasurements({
    required BuildContext navigatorContext,
    bool delayForSourceRoute = false,
  }) {
    final RenderBox navigator = Navigator.of(
      navigatorContext,
      rootNavigator: useRootNavigator,
    ).context.findRenderObject()! as RenderBox;
    final Size navSize = _getSize(navigator);
    _rectTween.end = Offset.zero & navSize;
    void takeMeasurementsInSourceRoute([Duration? _]) {
      if (!navigator.attached || hideableKey.currentContext == null) {
        return;
      }
      _rectTween.begin = _getRect(hideableKey, navigator);
      hideableKey.currentState!.placeholderSize = _rectTween.begin!.size;
    }

    if (delayForSourceRoute) {
      SchedulerBinding.instance
          .addPostFrameCallback(takeMeasurementsInSourceRoute);
    } else {
      takeMeasurementsInSourceRoute();
    }
  }

  Size _getSize(RenderBox render) {
    assert(render.hasSize);
    return render.size;
  }

  // Returns the bounds of the [RenderObject] identified by `key` in the
  // coordinate system of `ancestor`.
  Rect _getRect(GlobalKey key, RenderBox ancestor) {
    assert(key.currentContext != null);
    assert(ancestor.hasSize);
    final RenderBox render =
        key.currentContext!.findRenderObject()! as RenderBox;
    assert(render.hasSize);
    return MatrixUtils.transformRect(
      render.getTransformTo(ancestor),
      Offset.zero & render.size,
    );
  }

  bool get _transitionWasInterrupted {
    bool wasInProgress = false;
    bool isInProgress = false;

    switch (_currentAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        isInProgress = false;
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        isInProgress = true;
        break;
      case null:
        break;
    }
    switch (_lastAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        wasInProgress = false;
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        wasInProgress = true;
        break;
      case null:
        break;
    }
    return wasInProgress && isInProgress;
  }

  void closeContainer({T? returnValue}) {
    Navigator.of(subtreeContext!).pop(returnValue);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          if (animation.isCompleted) {
            return SizedBox.expand(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 0,
                    shape: openShape,
                    child: Container(
                      color: scrimBlackColor,
                      child: Builder(
                        key: _openBuilderKey,
                        builder: (BuildContext context) {
                          return openBuilder(context, closeContainer);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          final Animation<double> curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
            reverseCurve:
                _transitionWasInterrupted ? null : Curves.fastOutSlowIn.flipped,
          );
          TweenSequence<Color?>? colorTween;
          TweenSequence<double>? closedOpacityTween, openOpacityTween;
          // Animatable<Color?>? scrimTween;
          switch (animation.status) {
            case AnimationStatus.dismissed:
            case AnimationStatus.forward:
              closedOpacityTween = _closedOpacityTween;
              openOpacityTween = _openOpacityTween;
              colorTween = _colorTween;
              // scrimTween = _scrimFadeInTween;
              break;
            case AnimationStatus.reverse:
              if (_transitionWasInterrupted) {
                closedOpacityTween = _closedOpacityTween;
                openOpacityTween = _openOpacityTween;
                colorTween = _colorTween;
                // scrimTween = _scrimFadeInTween;
                break;
              }
              closedOpacityTween = _closedOpacityTween.flipped;
              openOpacityTween = _openOpacityTween.flipped;
              colorTween = _colorTween.flipped;
              // scrimTween = _scrimFadeOutTween;
              break;
            case AnimationStatus.completed:
              assert(false); // Unreachable.
              break;
          }
          assert(colorTween != null);
          assert(closedOpacityTween != null);
          assert(openOpacityTween != null);
          // assert(scrimTween != null);
          final Rect rect = _rectTween.evaluate(curvedAnimation)!;
          return SizedBox.expand(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: Tween(begin: 0.0, end: 10.0).evaluate(animation),
                  sigmaY: Tween(begin: 0.0, end: 10.0).evaluate(animation),
                  tileMode: TileMode.mirror),
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      ColorTween(begin: Colors.transparent, end: Colors.black)
                          .evaluate(animation)!,
                      Colors.transparent,
                    ])),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Transform.translate(
                    offset: Offset(rect.left, rect.top),
                    child: SizedBox(
                      width: rect.width,
                      height: rect.height,
                      child: Material(
                        clipBehavior: Clip.antiAlias,
                        animationDuration: Duration.zero,
                        color: Colors.transparent,
                        // color: scrimTween!.evaluate(animation),
                        shape: _shapeTween.evaluate(curvedAnimation),
                        // elevation: _elevationTween.evaluate(curvedAnimation),
                        child: Stack(
                          fit: StackFit.passthrough,
                          children: <Widget>[
                            FittedBox(
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.topLeft,
                              child: Transform.scale(
                                scale: Tween<double>(
                                  begin: 1,
                                  end: 0.8,
                                ).evaluate(curvedAnimation),
                                child: Transform.translate(
                                  offset: Tween<Offset>(
                                    begin: Offset.zero,
                                    //TOP visibility offset
                                    end: Offset(rect.left, rect.top + 110),
                                  ).evaluate(curvedAnimation),
                                  child: SizedBox(
                                    width: _rectTween.begin!.width,
                                    height: _rectTween.begin!.height,
                                    child: (hideableKey
                                                .currentState?.isInTree ??
                                            false)
                                        ? null
                                        : FadeTransition(
                                            opacity: _closedOpacityTween
                                                .animate(curvedAnimation),
                                            child: Builder(
                                              key: closedBuilderKey,
                                              builder: (BuildContext context) {
                                                // Use dummy "open container" callback
                                                // since we are in the process of opening.
                                                return closedBuilder(
                                                    context, () {});
                                              },
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            // Open child fading in.
                            FittedBox(
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                width: _rectTween.end!.width,
                                height: _rectTween.end!.height,
                                child: FadeTransition(
                                  opacity: openOpacityTween!.animate(animation),
                                  child: Builder(
                                    key: _openBuilderKey,
                                    builder: (BuildContext context) {
                                      return openBuilder(
                                          context, closeContainer);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;
}

class _FlippableTweenSequence<T> extends TweenSequence<T> {
  _FlippableTweenSequence(this._items) : super(_items);

  final List<TweenSequenceItem<T>> _items;
  _FlippableTweenSequence<T>? _flipped;

  _FlippableTweenSequence<T>? get flipped {
    if (_flipped == null) {
      final List<TweenSequenceItem<T>> newItems = <TweenSequenceItem<T>>[];
      for (int i = 0; i < _items.length; i++) {
        newItems.add(TweenSequenceItem<T>(
          tween: _items[i].tween,
          weight: _items[_items.length - 1 - i].weight,
        ));
      }
      _flipped = _FlippableTweenSequence<T>(newItems);
    }
    return _flipped;
  }
}
