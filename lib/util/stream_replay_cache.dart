// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

/// Utility for streams that replay their latest value to new subscribers.
library;

import 'dart:async';

/// Stream that replays the latest cached value to new subscribers.
/// Must be a broadcast stream.
class _ReplayLatestStream<T> extends StreamView<T> {
  T _latest;

  _ReplayLatestStream(this._latest, Stream<T> stream) : super(stream) {
    if (!stream.isBroadcast) {
      throw ArgumentError.value(stream, 'stream', 'Must be a broadcast stream');
    }
    // keep latest value
    stream.listen((event) {
      _latest = event;
    });
  }

  /// Subscribes to the stream and immediately receives the latest cached value.
  ///
  /// The latest value is delivered asynchronously using a microtask to ensure
  /// the subscription is fully established before the replay occurs.
  @override
  StreamSubscription<T> listen(
    void Function(T)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // Immediately replay the latest value *after* subscription is attached
    Future.microtask(() {
      if (onData != null) onData(_latest);
    });

    return super.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

extension ReplayLatest<T> on Stream<T> {
  /// Returns a broadcast stream that replays the latest value to new subscribers.
  /// New listeners immediately receive [startWith] or the most recent event.
  /// Example:
  /// ```dart
  /// final controller = StreamController<int>.broadcast();
  /// final replayedStream = controller.stream.replayLatest(0);
  /// replayedStream.listen((value) {
  ///  print('Listener 1: $value'); // Immediately prints 'Listener 1
  ///  0' on subscription
  ///  });
  ///  controller.add(1); // Prints 'Listener 1: 1'
  ///  replayedStream.listen((value) {
  ///  print('Listener 2: $value'); // Immediately prints 'Listener 2
  ///  1' on subscription
  ///  });
  /// ```
  ///
  Stream<T> replayLatest(T startWith) {
    final broadcast = isBroadcast ? this : asBroadcastStream();
    return _ReplayLatestStream<T>(startWith, broadcast);
  }
}
