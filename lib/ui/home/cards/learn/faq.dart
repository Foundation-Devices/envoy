// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'expansion_panel.dart' as envoy;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'dart:math' as math;

class Faq extends StatelessWidget {
  const Faq({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: FutureBuilder<String>(
          future: rootBundle.loadString("assets/faq.csv"),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var faq = CsvToListConverter().convert(snapshot.data);
              faq.removeAt(0);
              return Material(
                color: Colors.transparent,
                child: SingleChildScrollView(
                  child: envoy.ExpansionPanelList.radio(
                    elevation: 0,
                    dividerColor: Colors.transparent,
                    expandedHeaderPadding: EdgeInsets.zero,
                    children: faq
                        .map((e) => envoy.ExpansionPanelRadio(
                              hasIcon: false,
                              canTapOnHeader: true,
                              backgroundColor: Colors.transparent,
                              headerBuilder:
                                  (BuildContext context, bool isExpanded) {
                                return FaqItem(
                                  title: e[0],
                                  isExpanded: isExpanded,
                                  text: e[1],
                                  links: e.sublist(2),
                                );
                              },
                              body: Container(
                                height: 0,
                                width: 0,
                              ),
                              value: e[0],
                            ))
                        .toList(),
                  ),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          }),
    );
  }
}

class FaqBodyText extends StatelessWidget {
  final String text;
  final List<dynamic> links;

  const FaqBodyText(this.text, {required this.links});

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle =
        EnvoyTypography.body2Medium.copyWith(color: EnvoyColors.textSecondary);
    TextStyle linkStyle =
        EnvoyTypography.body2Medium.copyWith(color: EnvoyColors.accentPrimary);

    List<TextSpan> spans = [];

    var firstPass = text.split("{");

    int linkIndex = 0;
    for (var span in firstPass) {
      if (!span.contains("}")) {
        spans.add(TextSpan(text: span));
      } else {
        int index = linkIndex;
        spans.add(TextSpan(
            text: span.split("}")[0],
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse(links[index]));
              }));

        spans.add(TextSpan(text: span.split("}")[1]));
        linkIndex++;
      }
    }

    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        style: defaultStyle,
        children: <TextSpan>[...spans],
      ),
    );
  }
}

class FaqItem extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final String text;
  final List<dynamic> links;

  const FaqItem(
      {super.key,
      required this.title,
      required this.isExpanded,
      required this.text,
      required this.links});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: EnvoySpacing.small), //EnvoySpacing.small)
      child: ClipRRect(
        borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
        child: Container(
          color: EnvoyColors.surface2,
          child: Padding(
            padding: const EdgeInsets.all(EnvoySpacing.medium1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          title,
                          style: EnvoyTypography.body2Semibold
                              .copyWith(color: EnvoyColors.accentPrimary),
                        ),
                      ),
                    ),
                    Transform.rotate(
                        angle: isExpanded ? (180 * math.pi / 180) : 0,
                        child: EnvoyIcon(
                          EnvoyIcons.chevron_down,
                          color: EnvoyColors.accentPrimary,
                        ))
                  ],
                ),
                if (isExpanded)
                  SizedBox(
                    height: EnvoySpacing.small,
                  ),
                if (isExpanded)
                  FaqBodyText(
                    text,
                    links: links,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
