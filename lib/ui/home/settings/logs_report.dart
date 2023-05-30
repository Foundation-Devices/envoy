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
        title: Text("Logs"),
        leading: CupertinoNavigationBarBackButton(
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
                    duration: Duration(milliseconds: 2000),
                    message: "Logs copied to clipboard",
                    icon: Icon(
                      Icons.copy,
                      color: EnvoyColors.teal,
                    ),
                  ).show(context);
                } catch (e) {
                  print(e);
                }
              },
              icon: Icon(Icons.copy)),
          IconButton(
              onPressed: () async {
                EnvoyReport().share();
              },
              icon: Icon(Icons.ios_share))
        ],
        centerTitle: true,
      ),
      backgroundColor: EnvoyColors.white95,
      body: FutureBuilder<List<Map>>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map>? logs = snapshot.data;
            if (logs?.length == 0) {
              return Center(child: Text("No logs found"));
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    Map log = logs![index];
                    String exception = log["exception"] ?? "";
                    String stackTrace = log["stackTrace"] ?? "";
                    String lib = log["lib"] ?? "";
                    String time = log["time"] ?? "";
                    return Column(
                      children: [
                        Column(
                          children: [
                            SelectableText.rich(
                              TextSpan(children: [
                                TextSpan(
                                    text: "Time : ",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    )),
                                TextSpan(
                                    text: "${time}\n",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    )),
                                TextSpan(
                                    text: "Library : ",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    )),
                                TextSpan(
                                    text: "${lib}\n",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    )),
                                TextSpan(
                                    text: "\nException\n\n",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    )),
                                TextSpan(
                                    text: "${exception}\n",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    )),
                                TextSpan(
                                    text: "\nStack Trace\n\n",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    )),
                                TextSpan(
                                    text: "$stackTrace \n",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ))
                              ]),
                              scrollPhysics: ClampingScrollPhysics(),
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
                            Divider(
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
