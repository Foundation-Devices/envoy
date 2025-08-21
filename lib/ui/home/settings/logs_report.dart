// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

class EnvoyLogsScreen extends ConsumerStatefulWidget {
  const EnvoyLogsScreen({super.key});

  @override
  ConsumerState<EnvoyLogsScreen> createState() => _EnvoyLogsScreenState();
}

final envoyReportProvider = ChangeNotifierProvider((ref) => EnvoyReport());

class _EnvoyLogsScreenState extends ConsumerState<EnvoyLogsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: const Text("Logs"),
        leading: const CupertinoNavigationBarBackButton(
          color: Colors.white,
        ),
        actions: [
          IconButton(
              tooltip: "Copy logs",
              onPressed: () async {
                try {
                  String logs = await EnvoyReport().getLogAsString(24);
                  await Clipboard.setData(ClipboardData(text: logs));
                  if (context.mounted) {
                    EnvoyToast(
                      backgroundColor: Colors.lightBlue,
                      replaceExisting: true,
                      duration: const Duration(milliseconds: 2000),
                      message: "Logs copied to clipboard",
                      // TODO: FIGMA
                      icon: const Icon(
                        Icons.copy,
                        color: EnvoyColors.teal,
                      ),
                    ).show(context);
                  }
                } catch (e) {
                  kPrint(e);
                }
              },
              icon: const Icon(Icons.copy)),
          IconButton(
              tooltip: "Share logs",
              onPressed: () async {
                final navigator = Navigator.of(context);
                try {
                  showEnvoyDialog(
                      context: context,
                      builder: Builder(
                        builder: (context) {
                          return const SizedBox(
                            height: 130,
                            width: 220,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 12),
                                Text("Preparing logs for sharing..."),
                              ],
                            ),
                          );
                        },
                      ));
                  //small delay to prevent navigator gets leaked
                  await Future.delayed(const Duration(milliseconds: 200));
                  String path = await EnvoyReport().share();
                  SharePlus.instance.share(ShareParams(
                    files: [XFile(path)],
                    subject: "text/plain",
                    text: "Envoy Log Report",
                  ));
                } catch (e) {
                  EnvoyReport().log("EnvoyReport", e.toString());
                } finally {
                  navigator.pop();
                }
              },
              icon: const Icon(Icons.ios_share)),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer(
          builder: (context, ref, child) {
            final envoyReport = ref.watch(envoyReportProvider);
            return FutureBuilder<List<Map<String, Object?>>>(
              future: envoyReport.getAllLogs(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final logs = (snapshot.data ?? []).toList();
                if (logs.isEmpty) {
                  return const Center(
                      child: Text("No logs found")); // TODO: FIGMA
                }
                return CustomScrollView(
                  slivers: [
                    SliverList.builder(
                      itemBuilder: (context, index) {
                        Map log = logs[index];
                        String category = (log["category"] ?? "None") as String;
                        String message = (log["message"] ?? "None") as String;
                        String occurrences =
                            (log["occurrences"] ?? "1") as String;
                        String exception = log["exception"] ?? "None";
                        String stackTrace = log["stackTrace"] ?? "None";
                        String lib = log["lib"] ?? "None";
                        String time = log["time"] ?? "";

                        // Define reusable text styles
                        final labelStyle = const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        );

                        final valueStyle = const TextStyle(
                          fontSize: 8,
                          color: EnvoyColors.lightBlue,
                          fontFamily: 'monospace',
                        );

                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Table(
                              columnWidths: const {
                                0: IntrinsicColumnWidth(),
                                1: FlexColumnWidth(),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Text("Time :",
                                        style: labelStyle,
                                        textAlign: TextAlign.right),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: EnvoySpacing.small),
                                      child:
                                          Text(time.trim(), style: valueStyle),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Text("Category   :",
                                        style: labelStyle,
                                        textAlign: TextAlign.right),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: EnvoySpacing.small),
                                      child: Text(category, style: valueStyle),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Text("Message :",
                                        style: labelStyle,
                                        textAlign: TextAlign.right),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: EnvoySpacing.small),
                                      child: Text(message, style: valueStyle),
                                    ),
                                  ],
                                ),
                                if (occurrences != "1" && occurrences != "None")
                                  TableRow(
                                    children: [
                                      Text("Occurrences  :",
                                          style: labelStyle,
                                          textAlign: TextAlign.right),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: EnvoySpacing.small),
                                        child: Text(occurrences,
                                            style: valueStyle),
                                      ),
                                    ],
                                  ),
                                if (lib != "None")
                                  TableRow(
                                    children: [
                                      Text("Library  :",
                                          style: labelStyle,
                                          textAlign: TextAlign.right),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: EnvoySpacing.small),
                                        child: Text(lib, style: valueStyle),
                                      ),
                                    ],
                                  ),
                                if (exception != "None")
                                  TableRow(
                                    children: [
                                      Text("Exception :",
                                          style: labelStyle,
                                          textAlign: TextAlign.right),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: EnvoySpacing.small),
                                        child: SelectableText(exception,
                                            style: valueStyle),
                                      ),
                                    ],
                                  ),
                                if (stackTrace != "None")
                                  TableRow(
                                    children: [
                                      Text("StackTrace :",
                                          style: labelStyle,
                                          textAlign: TextAlign.right),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: EnvoySpacing.small),
                                        child: SelectableText(stackTrace,
                                            style: valueStyle),
                                      ),
                                    ],
                                  ),
                                TableRow(
                                  children: [
                                    const Divider(
                                      color: Colors.white10,
                                      thickness: 1,
                                    ),
                                    const Divider(
                                      color: Colors.white10,
                                      thickness: 1,
                                    ),
                                  ],
                                ),
                              ],
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                          ],
                        );
                      },
                      itemCount: logs.length,
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
