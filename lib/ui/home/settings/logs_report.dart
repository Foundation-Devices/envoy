// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnvoyLogsScreen extends StatefulWidget {
  const EnvoyLogsScreen({Key? key}) : super(key: key);

  @override
  State<EnvoyLogsScreen> createState() => _EnvoyLogsScreenState();
}

class _EnvoyLogsScreenState extends State<EnvoyLogsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: const Text("Logs"), // TODO: FIGMA
        leading: const CupertinoNavigationBarBackButton(
          color: Colors.white,
        ),
        actions: [
          IconButton(
              onPressed: () async {
                try {
                  String logs = await EnvoyReport().getLogAsString();
                  await Clipboard.setData(ClipboardData(text: logs));
                  EnvoyToast(
                    backgroundColor: Colors.lightBlue,
                    replaceExisting: true,
                    duration: const Duration(milliseconds: 2000),
                    message: "Logs copied to clipboard", // TODO: FIGMA
                    icon: const Icon(
                      Icons.copy,
                      color: EnvoyColors.teal,
                    ),
                  ).show(context);
                } catch (e) {
                  print(e);
                }
              },
              icon: const Icon(Icons.copy)),
          IconButton(
              onPressed: () async {
                EnvoyReport().share();
              },
              icon: const Icon(Icons.ios_share))
        ],
        centerTitle: true,
      ),
      backgroundColor: EnvoyColors.white95,
      body: FutureBuilder<List<Map>>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map>? logs = snapshot.data;
            if (logs?.length == 0) {
              return const Center(child: Text("No logs found")); // TODO: FIGMA
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    Map log = logs![index];
                    String category = (log["category"] ?? "None") as String;
                    String message = (log["message"] ?? "None") as String;
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
                                    text: "\nStack Trace\n\n", // TODO: FIGMA
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
                  }, childCount: logs?.length ?? 0))
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        future: EnvoyReport().getAllLogs(),
      ),
    );
  }
}
