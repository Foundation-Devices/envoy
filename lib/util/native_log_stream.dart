// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeLogStream {
  static const _channel = EventChannel('envoy/native_logs');
  static StreamSubscription<void>? _subscription;

  static void init() {
    if (!(Platform.isAndroid || Platform.isIOS) || _subscription != null) {
      return;
    }
    _subscription =
        _channel.receiveBroadcastStream().asyncMap<void>(_storeEvent).listen(
      null,
      onError: (Object error, StackTrace stackTrace) {
        kPrint(
          "Native log stream failed: $error",
          stackTrace: stackTrace,
        );
      },
    );
  }

  static Future<void> _storeEvent(Object? event) async {
    final parsed = parseEvent(event);
    if (parsed == null) {
      kPrint("Native log stream received an invalid event");
      return;
    }
    await EnvoyReport().log(parsed.category, parsed.message);
  }

  @visibleForTesting
  static ({String category, String message})? parseEvent(Object? event) {
    if (event is! Map) {
      return null;
    }
    final category = event['category'];
    final message = event['message'];
    if (category is! String || message is! String) {
      return null;
    }
    return (category: category, message: message);
  }
}
