// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stack_trace/stack_trace.dart';

class EnvoyReport {
  static final EnvoyReport _instance = EnvoyReport._();

  EnvoyReport._();

  factory EnvoyReport() {
    return _instance;
  }

  final int _logCapacity = 50;
  Database? _db;
  final StoreRef<int, Map<String, Object?>> _logsStore =
      intMapStoreFactory.store("logs");

  init() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    final appDocumentDir = await getApplicationDocumentsDirectory();
    _db = await dbFactory.openDatabase(join(appDocumentDir.path, "logs.db"));
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
      writeReport(details);
    };
    //purge old logs
    if (_db != null) {
      final logsLength = (await _logsStore.find(_db!)).length;
      if (logsLength > _logCapacity) {
        _logsStore.delete(_db!,
            finder: Finder(
                sortOrders: [SortOrder(Field.key, true)], limit: _logCapacity));
      }
    }
  }

  writeReport(FlutterErrorDetails? details) {
    Map<String, String?> report = {};
    if (details != null) {
      report["exception"] = details.exceptionAsString();
      report["lib"] = details.library;
      if (details.stack != null) {
        report["stackTrace"] =
            getStackTraceElements(details.stack!, 50).join("\n");
        report["buildId"] = getBuildId(details.stack!);
      } else {
        report["stackTrace"] =
            details.toString().replaceAll("◤", "").replaceAll("◢", "");
      }
      report["time"] = DateTime.now().toIso8601String();
    }
    if (_db != null) {
      _logsStore.add(_db!, report);
    }
  }

  log(String category, String message) {
    Map<String, String?> report = {};
    report["category"] = category;
    report["message"] = message;
    report["time"] = DateTime.now().toIso8601String();

    if (_db != null) {
      _logsStore.add(_db!, report);
    }
  }

  Future<List<Map<String, Object?>>> getAllLogs() async {
    var log = await _logsStore.find(_db!);
    var logs = log.map((e) => e.value).toList().reversed.toList();
    return logs;
  }

  /// filter out the stack trace lines that are not useful for debugging.
  List<String> getStackTraceElements(StackTrace? stackTrace, int? maxFrames) {
    if (stackTrace == null) {
      stackTrace = StackTrace.current;
    } else {
      stackTrace = FlutterError.demangleStackTrace(stackTrace);
    }
    Iterable<String> lines = stackTrace.toString().trimRight().split('\n');
    if (kIsWeb && lines.isNotEmpty) {
      // Remove extra call to StackTrace.current for web platform.
      // TODO(ferhat): remove when https://github.com/flutter/flutter/issues/37635
      // is addressed.
      lines = lines.skipWhile((String line) {
        return line.contains('StackTrace.current') ||
            line.contains('dart-sdk/lib/_internal') ||
            line.contains('dart:sdk_internal');
      });
    }
    if (maxFrames != null) {
      lines = lines.take(maxFrames);
    }
    return lines.toList();
  }

  String? getBuildId(StackTrace stackTrace) {
    final Trace trace = Trace.parseVM(stackTrace.toString()).terse;
    for (final Frame frame in trace.frames) {
      if (frame is UnparsedFrame) {
        if (frame.member.startsWith("build_id: '") &&
            frame.member.endsWith("'")) {
          return frame.member.substring(11, frame.member.length - 1);
        }
      }
    }
    return null;
  }

  Future<String> getLogAsString() async {
    final allLogs = await getAllLogs();
    String logs = "";
    for (var logMap in allLogs) {
      String log = "";
      try {
        String category = (logMap["category"] ?? "None") as String;
        String message = (logMap["message"] ?? "None") as String;
        String exception = (logMap["exception"] ?? "None") as String;
        String stackTrace = (logMap["stackTrace"] ?? "None") as String;
        String lib = (logMap["lib"] ?? "None") as String;
        String time = (logMap["time"] ?? "") as String;

        log = "\nTime       : $time \n"
            "Category    : $category \n"
            "Message     : $message \n"
            "Library     : $lib \n"
            "Exception   : $exception \n"
            ""
            "Stack Trace : $stackTrace \n"
            "";
      } catch (e) {
        kPrint(e);
      }
      if (log.isNotEmpty) {
        logs = "$logs\n${List.generate(20, (index) => "-").join("")}\n$log";
      }
    }
    return logs;
  }

  void share() async {
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File(join(tempDir.path, "logs.txt"));
    String logs = await getLogAsString();
    await file.writeAsString(logs);
    // ignore: deprecated_member_use
    await Share.shareFiles([file.path],
        text: 'Envoy Log Report', mimeTypes: ["text/plain"]);
  }

  clearAll() {
    _logsStore.delete(_db!);
  }
}
