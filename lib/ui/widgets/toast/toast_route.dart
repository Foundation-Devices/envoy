// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:flutter/material.dart';

enum EnvoyToastRouteStatus { SHOWING, DISMISSED, IS_APPEARING, IS_HIDING }

typedef ToastStatusCallback = void Function(EnvoyToastRouteStatus? status);
const String ENVY_TOAST_ROUTE = "./envoy_toast";

class EnvoyToastRoute<T> extends OverlayRoute<T> {
  final EnvoyToast envoy;
  final Builder _builder;
  final Completer<T> _transitionCompleter = Completer<T>();
  final ToastStatusCallback? _onStatusChanged;

  Alignment? _initialAlignment;
  Alignment? _endAlignment;
  bool _wasDismissedBySwipe = false;
  Timer? _timer;
  T? _result;
  EnvoyToastRouteStatus? currentStatus;

  EnvoyToastRoute({
    required this.envoy,
    super.settings,
  })  : _builder = Builder(builder: (BuildContext innerContext) {
          return GestureDetector(
            onTap: envoy.onTap != null ? () => envoy.onTap!(envoy) : null,
            child: envoy,
          );
        }),
        _onStatusChanged = envoy.onStatusChanged {
    _configureAlignment();
  }

  void _configureAlignment() {
    _initialAlignment = const Alignment(-1.0, -2.0);
    _endAlignment = envoy.endOffset != null
        ? const Alignment(-1.0, -1.0) +
            Alignment(envoy.endOffset!.dx, envoy.endOffset!.dy)
        : const Alignment(-1.0, -1.0);
  }

  Future<T> get completed => _transitionCompleter.future;

  bool get opaque => false;

  @override
  Future<RoutePopDisposition> willPop() {
    if (!envoy.isDismissible) {
      return Future.value(RoutePopDisposition.doNotPop);
    }

    return Future.value(RoutePopDisposition.pop);
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    final overlays = <OverlayEntry>[];

    overlays.add(
      OverlayEntry(
          builder: (BuildContext context) {
            final Widget annotatedChild = Semantics(
              focused: false,
              container: true,
              explicitChildNodes: true,
              child: AlignTransition(
                alignment: _animation!,
                child: envoy.isDismissible
                    ? _getDismissible(_builder)
                    : Container(
                        margin: envoy.margin,
                        child: _builder,
                      ),
              ),
            );
            return annotatedChild;
          },
          maintainState: false,
          opaque: opaque),
    );
    return overlays;
  }

  String dismissibleKeyGen = '';

  Widget _getDismissible(Widget child) {
    return Dismissible(
        direction: DismissDirection.up,
        resizeDuration: null,
        confirmDismiss: (_) {
          if (currentStatus == EnvoyToastRouteStatus.IS_APPEARING ||
              currentStatus == EnvoyToastRouteStatus.IS_HIDING) {
            return Future.value(false);
          }
          return Future.value(true);
        },
        key: Key(dismissibleKeyGen),
        onDismissed: (_) {
          dismissibleKeyGen += '1';
          _cancelTimer();
          _wasDismissedBySwipe = true;

          if (isCurrent) {
            navigator!.pop();
          } else {
            navigator!.removeRoute(this);
          }
        },
        child: Container(
          margin: envoy.margin,
          child: _builder,
        ));
  }

  @override
  bool get finishedWhenPopped =>
      _controller!.status == AnimationStatus.dismissed;

  /// The animation that drives the route's transition and the previous route's
  /// forward transition.
  Animation<Alignment>? get animation => _animation;
  Animation<Alignment>? _animation;

  /// The animation controller that the route uses to drive the transitions.
  ///
  /// The animation itself is exposed by the [animation] property.
  @protected
  AnimationController? get controller => _controller;
  AnimationController? _controller;

  AnimationController createAnimationController() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot reuse a $runtimeType after disposing it.');
    assert(envoy.animationDuration >= Duration.zero);
    return AnimationController(
      duration: envoy.animationDuration,
      debugLabel: debugLabel,
      vsync: navigator!,
    );
  }

  Animation<Alignment> createAnimation() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot reuse a $runtimeType after disposing it.');
    assert(_controller != null);
    return AlignmentTween(begin: _initialAlignment, end: _endAlignment).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: envoy.forwardAnimationCurve,
        reverseCurve: envoy.reverseAnimationCurve,
      ),
    );
  }

  //copy of `routes.dart`
  void _handleStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        currentStatus = EnvoyToastRouteStatus.SHOWING;
        if (_onStatusChanged != null) _onStatusChanged!(currentStatus);
        if (overlayEntries.isNotEmpty) overlayEntries.first.opaque = opaque;

        break;
      case AnimationStatus.forward:
        currentStatus = EnvoyToastRouteStatus.IS_APPEARING;
        if (_onStatusChanged != null) _onStatusChanged!(currentStatus);
        break;
      case AnimationStatus.reverse:
        currentStatus = EnvoyToastRouteStatus.IS_HIDING;
        if (_onStatusChanged != null) _onStatusChanged!(currentStatus);
        if (overlayEntries.isNotEmpty) overlayEntries.first.opaque = false;
        break;
      case AnimationStatus.dismissed:
        assert(!overlayEntries.first.opaque);
        // We might still be the current route if a subclass is controlling the
        // the transition and hits the dismissed status. For example, the iOS
        // back gesture drives this animation to the dismissed status before
        // popping the navigator.
        currentStatus = EnvoyToastRouteStatus.DISMISSED;
        if (_onStatusChanged != null) _onStatusChanged!(currentStatus);

        if (!isCurrent) {
          navigator!.finalizeRoute(this);
          if (overlayEntries.isNotEmpty) {
            overlayEntries.clear();
          }
          assert(overlayEntries.isEmpty);
        }
        break;
    }
    changedInternalState();
  }

  @override
  void install() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot install a $runtimeType after disposing it.');
    _controller = createAnimationController();
    assert(_controller != null,
        '$runtimeType.createAnimationController() returned null.');
    _animation = createAnimation();
    assert(_animation != null, '$runtimeType.createAnimation() returned null.');
    super.install();
  }

  @override
  TickerFuture didPush() {
    assert(_controller != null,
        '$runtimeType.didPush called before calling install() or after calling dispose().');
    assert(!_transitionCompleter.isCompleted,
        'Cannot reuse a $runtimeType after disposing it.');
    _animation!.addStatusListener(_handleStatusChanged);
    _configureTimer();
    super.didPush();
    return _controller!.forward();
  }

  @override
  void didReplace(Route<dynamic>? oldRoute) {
    assert(_controller != null,
        '$runtimeType.didReplace called before calling install() or after calling dispose().');
    assert(!_transitionCompleter.isCompleted,
        'Cannot reuse a $runtimeType after disposing it.');
    if (oldRoute is EnvoyToastRoute) {
      _controller!.value = oldRoute._controller!.value;
    }
    _animation!.addStatusListener(_handleStatusChanged);
    super.didReplace(oldRoute);
  }

  @override
  bool didPop(T? result) {
    assert(_controller != null,
        '$runtimeType.didPop called before calling install() or after calling dispose().');
    assert(!_transitionCompleter.isCompleted,
        'Cannot reuse a $runtimeType after disposing it.');

    _result = result;
    _cancelTimer();

    if (_wasDismissedBySwipe) {
      Timer(const Duration(milliseconds: 200), () {
        _controller!.reset();
      });

      _wasDismissedBySwipe = false;
    } else {
      _controller!.reverse();
    }

    return super.didPop(result);
  }

  void _configureTimer() {
    if (envoy.duration != null) {
      if (_timer != null && _timer!.isActive) {
        _timer!.cancel();
      }
      _timer = Timer(envoy.duration!, () {
        if (isCurrent) {
          navigator!.pop();
        } else if (isActive) {
          navigator!.removeRoute(this);
        }
      });
    } else {
      if (_timer != null) {
        _timer!.cancel();
      }
    }
  }

  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  /// Whether this route can perform a transition to the given route.
  ///
  /// Subclasses can override this method to restrict the set of routes they
  /// need to coordinate transitions with.
  bool canTransitionTo(EnvoyToastRoute<dynamic> nextRoute) => true;

  /// Whether this route can perform a transition from the given route.
  ///
  /// Subclasses can override this method to restrict the set of routes they
  /// need to coordinate transitions with.
  bool canTransitionFrom(EnvoyToastRoute<dynamic> previousRoute) => true;

  @override
  void dispose() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot dispose a $runtimeType twice.');
    _controller?.dispose();
    _transitionCompleter.complete(_result);
    super.dispose();
  }

  /// A short description of this route useful for debugging.
  String get debugLabel => '$runtimeType';

  @override
  String toString() => '$runtimeType(animation: $_controller)';
}

EnvoyToastRoute showToast<T>(
    {required BuildContext context, required EnvoyToast toast}) {
  return EnvoyToastRoute<T>(
    envoy: toast,
    settings: const RouteSettings(name: ENVY_TOAST_ROUTE),
  );
}
