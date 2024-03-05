// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/util/tuple.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';

class ExportSeedModalWords extends StatefulWidget {
  final List<String> seed;
  final bool hasPassphrase;

  const ExportSeedModalWords(
      {super.key, required this.seed, required this.hasPassphrase});

  @override
  State<ExportSeedModalWords> createState() => _ExportSeedModalWordsState();
}

class _ExportSeedModalWordsState extends State<ExportSeedModalWords> {
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                  icon: const Icon(Icons.close),
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
                            child: SizedBox(
                              height: 400,
                              child: PageView.builder(
                                controller: _pageController,
                                itemBuilder: (context, pageIndex) {
                                  var seedList = widget.seed;
                                  List<String> section1 = [];
                                  List<String> section2 = [];
                                  if (pageIndex == 0) {
                                    section1 = seedList.sublist(0, 6);
                                    section2 = seedList.sublist(6, 12);
                                  } else {
                                    if (seedList.length == 24) {
                                      section1 = seedList.sublist(12, 18);
                                      section2 = seedList.sublist(18, 24);
                                    }
                                  }

                                  List<Tuple<int, String>> section1WithIndex =
                                      [];
                                  List<Tuple<int, String>> section2WithIndex =
                                      [];

                                  section1.asMap().forEach((index, element) {
                                    int value =
                                        pageIndex == 0 ? index + 1 : index + 13;
                                    section1WithIndex
                                        .add(Tuple(value, element));
                                  });

                                  section2.asMap().forEach((index, element) {
                                    int value =
                                        pageIndex == 0 ? index + 7 : index + 19;
                                    section2WithIndex
                                        .add(Tuple(value, element));
                                  });

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
                                                section1WithIndex)),
                                        Flexible(
                                            child: _buildMnemonicColumn(
                                                section2WithIndex)),
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
                          child: Opacity(
                            opacity: widget.seed.length == 12 ? 0 : 1,
                            child: DotsIndicator(
                              pageController: _pageController,
                              totalPages: widget.seed.length == 12 ? 1 : 2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  if (widget.hasPassphrase)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 34, right: 34, top: 25),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 34, vertical: 28),
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
                            S().component_done,
                            type: EnvoyButtonTypes.primaryModal,
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

  Widget _buildMnemonicColumn(List<Tuple<int, String>> list) {
    final TextStyle textTheme = const TextStyle(
        overflow: TextOverflow.fade,
        fontSize: 15,
        color: Colors.black87,
        fontWeight: FontWeight.bold);
    return Column(
      children: list.map((word) {
        return Container(
          height: 32,
          margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          constraints: const BoxConstraints(maxWidth: 200, maxHeight: 80),
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Text("${word.item1}. ", style: textTheme),
              Flexible(
                  child: Text(
                "${word.item2}",
                style: textTheme,
                maxLines: 1,
                softWrap: false,
              )),
            ],
          ),
        );
      }).toList(),
    );
  }
}
