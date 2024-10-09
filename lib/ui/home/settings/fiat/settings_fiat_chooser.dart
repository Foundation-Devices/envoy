// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/ui/components/search.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FiatCurrencyChooser extends ConsumerStatefulWidget {
  final Function(String selection) onSelect;

  const FiatCurrencyChooser({super.key, required this.onSelect});

  @override
  ConsumerState<FiatCurrencyChooser> createState() =>
      _FiatCurrencyChooserState();
}

class _FiatCurrencyChooserState extends ConsumerState<FiatCurrencyChooser> {
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();
  final TextEditingController _searchController = TextEditingController();

  List<FiatCurrency> _filteredCurrencies = ExchangeRate().supportedFiat;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        //close modal when click outside
        if (_draggableController.size < .95 &&
            (1 - _draggableController.pixelsToSize(details.localPosition.dy) >
                _draggableController.size)) {
          Navigator.pop(context);
        }
      },
      child: Container(
        color: Colors.transparent,
        child: DraggableScrollableSheet(
          controller: _draggableController,
          initialChildSize: 1,
          minChildSize: .5,
          snapSizes: const [.5, 1],
          shouldCloseOnMinExtent: true,
          snapAnimationDuration: const Duration(milliseconds: 350),
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(EnvoySpacing.medium2),
                  right: Radius.circular(EnvoySpacing.medium2),
                ),
                color: Color(0xff231F20),
              ),
              child: Theme(
                data: ThemeData.dark(),
                child: Builder(builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.small,
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              top: 8.0, bottom: EnvoySpacing.medium1),
                          width: 30.0,
                          height: 3.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                            color: EnvoyColors.gray500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: EnvoySpacing.small,
                            horizontal: EnvoySpacing.small,
                          ),
                          child: SizedBox(
                            height: EnvoySpacing.large1,
                            child: Theme(
                              data: ThemeData.light(),
                              child: FocusScope(
                                onFocusChange: (value) {
                                  if (_draggableController.size != 1 && value) {
                                    _draggableController.animateTo(1,
                                        duration:
                                            const Duration(milliseconds: 210),
                                        curve: Curves.easeOut);
                                  }
                                },
                                child: EnvoySearch(
                                  filterSearchResults: (text) async {
                                    _searchController.text = text;
                                    _filteredCurrencies = ExchangeRate()
                                        .supportedFiat
                                        .where(
                                          (element) =>
                                              element.title
                                                  .toLowerCase()
                                                  .contains(
                                                      text.toLowerCase()) ||
                                              element.code
                                                  .toLowerCase()
                                                  .contains(text.toLowerCase()),
                                        )
                                        .toList();
                                    setState(() {});
                                  },
                                  controller: _searchController,
                                  showClearIcon: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Builder(
                          builder: (context) {
                            return ListView.builder(
                              itemCount: _filteredCurrencies.length,
                              controller: scrollController,
                              itemBuilder: (context, index) {
                                final item = _filteredCurrencies[index];
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(EnvoySpacing.medium2)),
                                    splashColor: Colors.black12,
                                    onTap: () {
                                      widget.onSelect(item.code);
                                      Navigator.of(context).pop();
                                    },
                                    child: ListTile(
                                      horizontalTitleGap: EnvoySpacing.small,
                                      visualDensity: VisualDensity.standard,
                                      dense: false,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: EnvoySpacing.xs,
                                      ).add(const EdgeInsets.only(
                                        left: EnvoySpacing.medium1,
                                        right: EnvoySpacing.medium2,
                                      )),
                                      leading: Container(
                                        width: 24,
                                        height: 24,
                                        alignment: const Alignment(1.0, -0.5),
                                        child: Text(
                                          item.flag,
                                          style: EnvoyTypography.body
                                              .copyWith(fontSize: 16),
                                        ),
                                      ),
                                      titleTextStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                      title: Text(item.title),
                                      trailing: SizedBox(
                                        width: 64,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item.symbol,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500),
                                              textAlign: TextAlign.end,
                                            ),
                                            const SizedBox(
                                                width: EnvoySpacing.small),
                                            Text(item.code,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        )),
                      ],
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
