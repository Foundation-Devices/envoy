// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
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

final _envoyLogs = FutureProvider((ref) => EnvoyReport().getAllLogs());

class _EnvoyLogsScreenState extends ConsumerState<EnvoyLogsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: const Text("Logs"),
        // TODO: FIGMA
        leading: const CupertinoNavigationBarBackButton(
          color: Colors.white,
        ),
        actions: [
          IconButton(
              tooltip: "Copy logs",
              onPressed: () async {
                try {
                  String logs = await EnvoyReport().getLogAsString();
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
                  Share.shareXFiles([XFile(path)],
                      text: 'Envoy Log Report', subject: "text/plain");
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
      backgroundColor: EnvoyColors.white95,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer(
          builder: (context, ref, child) {
            final data = ref.watch(_envoyLogs);
            return data.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return const Center(
                      child: Text("No logs found")); // TODO: FIGMA
                }
                final latestLogs = logs.reversed.toList();

                return CustomScrollView(
                  slivers: [
                    SliverList.builder(
                      itemBuilder: (context, index) {
                        Map log = latestLogs[index];
                        String category = (log["category"] ?? "None") as String;
                        String message = (log["message"] ?? "None") as String;
                        String occurrences =
                            (log["occurrences"] ?? "1") as String;
                        String exception = log["exception"] ?? "None";
                        String stackTrace = log["stackTrace"] ?? "None";
                        String lib = log["lib"] ?? "None";
                        String time = log["time"] ?? "";
                        return Column(
                          children: [
                            Column(
                              children: [
                                SelectableText.rich(
                                  TextSpan(children: [
                                    const TextSpan(
                                        text: "Time : ", // TODO: FIGMA
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        )),
                                    TextSpan(
                                        text: "$time\n",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        )),
                                    const TextSpan(
                                        text: "Category : ", // TODO: FIGMA
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        )),
                                    TextSpan(
                                        text: "$category\n",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        )),
                                    const TextSpan(
                                        text: "Message : ", // TODO: FIGMA
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        )),
                                    TextSpan(
                                        text: "$message\n",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        )),
                                    const TextSpan(
                                        text: "Occurrences : ", // TODO: FIGMA
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        )),
                                    TextSpan(
                                        text: "$occurrences\n",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        )),
                                    const TextSpan(
                                        text: "Library : ", // TODO: FIGMA
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        )),
                                    TextSpan(
                                        text: "$lib\n",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        )),
                                    const TextSpan(
                                        text: "\nException\n\n", // TODO: FIGMA
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        )),
                                    TextSpan(
                                        text: "$exception\n",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        )),
                                    const TextSpan(
                                        text:
                                            "\nStack Trace\n\n", // TODO: FIGMA
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        )),
                                    TextSpan(
                                        text: "$stackTrace \n",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        ))
                                  ]),
                                  scrollPhysics: const ClampingScrollPhysics(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.w400,
                                          height: 1.2,
                                          color: Colors.grey[400],
                                          fontSize: 11),
                                  // overflow: TextOverflow.ellipsis,
                                  // softWrap: true,
                                ),
                                const Divider(
                                  color: Colors.black,
                                  thickness: 1,
                                ),
                              ],
                            )
                          ],
                        );
                      },
                      itemCount: latestLogs.length,
                    )
                  ],
                );
              },
              error: (error, stackTrace) {
                return Center(
                  child: Text("Error: $error"),
                );
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
