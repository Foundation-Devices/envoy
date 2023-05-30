// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

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

  final int _logCapacity = 100;
  Database? _db;
  final StoreRef<int, Map<String, Object?>> _logsStore =
      intMapStoreFactory.store("logs");

  init() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    final appDocumentDir = await getApplicationDocumentsDirectory();
    _db = await dbFactory.openDatabase(join(appDocumentDir.path, "logs.db"));
    FlutterError.onError = (FlutterErrorDetails details) {
      writeReport(details);
    };
    //purge old logs
    if (_db != null) {
      if ((await _logsStore.find(_db!)).length > _logCapacity) {
        _logsStore.delete(_db!,
            finder: Finder(
                sortOrders: [SortOrder(Field.key, true)], limit: _logCapacity));
      }
    }
  }

  writeReport(FlutterErrorDetails? details) {
    Map<String, String?> report = Map();
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
    final allLogs = await this.getAllLogs();
    String logs = "";
    allLogs.forEach((element) {
      String log = "";
      try {
        String exception = (element["exception"] ?? "") as String;
        String stackTrace = (element["stackTrace"] ?? "") as String;
        String lib = (element["lib"] ?? "") as String;
        String time = (element["time"] ?? "") as String;

        log = "\nTime       : ${time} \n"
            "Library     : ${lib} \n"
            "Exception   : ${exception} \n"
            ""
            "Stack Trace : ${stackTrace} \n"
            "";
      } catch (e) {
        print(e);
      }
      if (log.isNotEmpty)
        logs =
            "$logs\n" + List.generate(20, (index) => "-").join("") + "\n${log}";
    });
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
}
