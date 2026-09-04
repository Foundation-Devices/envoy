// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

/// Runs asynchronous operations one at a time without overlapping a timed-out
/// operation with the next queued operation.
class SerializedOperationQueue<T> {
  Future<void> _tail = Future.value();
  final Set<Completer<T>> _pending = {};

  Future<T> enqueue(
    Future<T> Function() operation, {
    Duration? timeout,
    FutureOr<T> Function()? onTimeout,
    Duration timeoutCompletionGrace = const Duration(seconds: 2),
  }) {
    final completer = Completer<T>();
    _pending.add(completer);

    _tail = _tail.then((_) async {
      _pending.remove(completer);
      if (completer.isCompleted) return;

      try {
        final operationFuture = operation();
        if (timeout == null) {
          completer.complete(await operationFuture);
          return;
        }

        try {
          completer.complete(await operationFuture.timeout(timeout));
        } on TimeoutException catch (error, stackTrace) {
          if (onTimeout == null) {
            completer.completeError(error, stackTrace);
          } else {
            try {
              completer.complete(await onTimeout());
            } catch (error, stackTrace) {
              completer.completeError(error, stackTrace);
            }
          }

          // Future.timeout only stops waiting. Keep ownership of the queue
          // head briefly so platform recovery can complete this write, but
          // do not let a lost platform-channel reply block the queue forever.
          try {
            await operationFuture.timeout(timeoutCompletionGrace);
          } catch (_) {
            // The caller already received the timeout result.
          }
        }
      } catch (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      }
    });

    return completer.future;
  }

  /// Completes operations that have not started yet without running them.
  void completePending(T result) {
    for (final completer in _pending) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    }
    _pending.clear();
  }
}
