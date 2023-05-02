// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';

class ExportSeedModalWords extends StatefulWidget {
  final List<String> seed;
  final bool hasPassphrase;

  const ExportSeedModalWords(
      {Key? key, required this.seed, required this.hasPassphrase})
      : super(key: key);

  @override
  State<ExportSeedModalWords> createState() => _ExportSeedModalWordsState();
}

class _ExportSeedModalWordsState extends State<ExportSeedModalWords> {
  PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      //height: MediaQuery.of(context).size.height * 0.70,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
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
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: CustomScrollView(
                      shrinkWrap: true,
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                              horizontal: constraints.maxWidth < 250 ? 0 : 34),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              height: 400,
                              child: PageView.builder(
                                controller: _pageController,
                                itemBuilder: (context, index) {
                                  var seedList = widget.seed;
                                  List<String> section1 = [];
                                  List<String> section2 = [];
                                  if (index == 1) {
                                    section1 = seedList.sublist(0, 6);
                                    section2 = seedList.sublist(6, 12);
                                  } else {
                                    section1 = seedList.sublist(0, 6);
                                    section2 = seedList.sublist(6, 12);
                                  }
                                  return Builder(builder: (context) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Flexible(
                                            child: _buildMnemonicColumn(
                                                section1, seedList)),
                                        Flexible(
                                            child: _buildMnemonicColumn(
                                                section2, seedList)),
                                      ],
                                    );
                                  });
                                },
                                itemCount: widget.seed.length == 12 ? 1 : 2,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: DotsIndicator(
                            pageController: _pageController,
                            totalPages: widget.seed.length == 12 ? 1 : 2,
                          ),
                        )
                      ],
                    ),
                  ),
                  if (widget.hasPassphrase)
                    Padding(
                      padding: EdgeInsets.only(left: 34, right: 34, top: 25),
                      child: Text(
                          S().export_seed_modal_QR_code_subheading_passphrase,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: EnvoyColors.grey),
                          textAlign: TextAlign.center),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 34, vertical: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        EnvoyButton(
                          S().export_seed_modal_12_words_CTA2,
                          type: EnvoyButtonTypes.secondary,
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
            )
          ]);
        },
      ),
    );
  }

  Widget _buildMnemonicColumn(List<String> list, List<String> seedList) {
    final TextStyle textTheme = TextStyle(
        fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold);
    return Column(
      children: list.map((word) {
        return Container(
          height: 32,
          margin: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          padding: EdgeInsets.symmetric(horizontal: 8),
          constraints: BoxConstraints(maxWidth: 200, maxHeight: 80),
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Text("${seedList.indexOf(word) + 1}. ", style: textTheme),
              Expanded(child: Text("${word}", style: textTheme)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
