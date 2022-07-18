// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'expansion_panel.dart' as envoy;
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

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
                    dividerColor: Colors.black12,
                    children: faq
                        .map((e) => envoy.ExpansionPanelRadio(
                              hasIcon: false,
                              canTapOnHeader: true,
                              backgroundColor: Colors.transparent,
                              headerBuilder:
                                  (BuildContext context, bool isExpanded) {
                                return ListTile(
                                  trailing: Icon(
                                    isExpanded ? Icons.remove : Icons.add,
                                    color: EnvoyColors.darkTeal,
                                    size: 14,
                                  ),
                                  title: Text(
                                    e[0],
                                    style: TextStyle(
                                        color: EnvoyColors.darkTeal,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                                );
                              },
                              body: ListTile(
                                title: FaqBodyText(e[1], onTap: () {
                                  launchUrl(Uri.parse(e[2]));
                                }),
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
  final Function onTap;

  const FaqBodyText(this.text, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle = Theme.of(context).textTheme.bodyText2!;
    TextStyle linkStyle = TextStyle(color: EnvoyColors.darkTeal);

    List<TextSpan> spans = [];

    var firstPass = text.split("{");

    for (var span in firstPass) {
      if (!span.contains("}")) {
        spans.add(TextSpan(text: span));
      } else {
        spans.add(TextSpan(
            text: span.split("}")[0],
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = onTap as GestureTapCallback?));

        spans.add(TextSpan(text: span.split("}")[1]));
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
