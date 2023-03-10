// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';

class ExportSeedModalWords extends StatefulWidget {
  final List<String> seed;

  const ExportSeedModalWords({Key? key, required this.seed}) : super(key: key);

  @override
  State<ExportSeedModalWords> createState() => _ExportSeedModalWordsState();
}

class _ExportSeedModalWordsState extends State<ExportSeedModalWords> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * .70,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 4,
                            crossAxisSpacing: 22.0,
                            mainAxisSpacing: 30,
                          ),
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            final TextStyle textTheme = TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold);
                            return Container(
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              constraints:
                                  BoxConstraints(maxWidth: 200, maxHeight: 80),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  Text("${index + 1}. ", style: textTheme),
                                  Expanded(
                                      child: Text("${widget.seed[index]}",
                                          style: textTheme)),
                                ],
                              ),
                            );
                          }, childCount: widget.seed.length),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 28),
                    child: Column(
                      children: [
                        EnvoyButton(
                          S().export_seed_modal_12_words_CTA2,
                          type: EnvoyButtonTypes.SECONDARY,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: EnvoyButton(
                            S().export_seed_modal_12_words_CTA1,
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ]));
  }
}
