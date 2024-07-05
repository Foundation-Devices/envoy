// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/locale.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'expansion_panel.dart' as envoy;
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'dart:math' as math;

final faqsProvider = Provider((ref) => extractFaqs());

class FaqEntry {
  final String question;
  final String answer;
  final List<String> links;

  FaqEntry(this.question, this.answer, this.links);
}

List<FaqEntry> extractFaqs() {
  List<FaqEntry> faqs = [];
  int index = 1;

  for (;;) {
    String? question =
        getTranslationByKey("envoy_faq_question_${index.toString()}");
    if (question == null) {
      break;
    }

    String? answer =
        getTranslationByKey("envoy_faq_answer_${index.toString()}");
    if (answer == null) {
      break;
    }

    List<String> links = [];
    int linkIndex = 1;
    // First, check if there is a single link without an index
    String? singleLink =
        getTranslationByKey("envoy_faq_link_${index.toString()}");

    if (singleLink != null) {
      links.add(singleLink);
    } else {
      // If no single link is found, check for multiple links
      for (;;) {
        String? link = getTranslationByKey(
            "envoy_faq_link_${index.toString()}_${linkIndex.toString()}");
        if (link == null) {
          break;
        }
        links.add(link);
        linkIndex++;
      }
    }

    faqs.add(FaqEntry(question, answer, links));
    index++;
  }

  return faqs;
}

class Faq extends ConsumerWidget {
  final String? searchText;

  const Faq({
    super.key,
    this.searchText,
  });

  @override
  Widget build(context, ref) {
    var faqs = ref.watch(faqsProvider);
    if (searchText != null || searchText != "") {
      faqs = faqs
          .where((entry) =>
              entry.question.toLowerCase().contains(searchText!.toLowerCase()))
          .toList();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (faqs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
            child: Text(
              S().learning_center_title_faq,
              style: EnvoyTypography.body
                  .copyWith(color: EnvoyColors.textPrimary)
                  .setWeight(FontWeight.w600),
            ),
          ),
        Material(
          color: Colors.transparent,
          child: envoy.ExpansionPanelList.radio(
            elevation: 0,
            dividerColor: Colors.transparent,
            expandedHeaderPadding: EdgeInsets.zero,
            children: faqs
                .map((e) => envoy.ExpansionPanelRadio(
                      hasIcon: false,
                      canTapOnHeader: true,
                      backgroundColor: Colors.transparent,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return FaqItemWidget(
                          title: e.question,
                          isExpanded: isExpanded,
                          text: e.answer,
                          links: e.links,
                        );
                      },
                      body: const SizedBox(
                        height: 0,
                        width: 0,
                      ),
                      value: e.question,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class FaqBodyText extends StatelessWidget {
  final String text;
  final List<dynamic> links;

  const FaqBodyText(this.text, {super.key, required this.links});

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle =
        EnvoyTypography.body.copyWith(color: EnvoyColors.textSecondary);
    TextStyle linkStyle =
        EnvoyTypography.button.copyWith(color: EnvoyColors.accentPrimary);

    List<TextSpan> spans = [];

    var firstPass = text.split("[[");

    int linkIndex = 0;
    for (var span in firstPass) {
      if (!span.contains("]]")) {
        spans.add(TextSpan(text: span));
      } else {
        int index = linkIndex;
        spans.add(TextSpan(
            text: span.split("]]")[0],
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse(links[index]));
              }));

        spans.add(TextSpan(text: span.split("]]")[1]));
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

class FaqItemWidget extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final String text;
  final List<dynamic> links;

  const FaqItemWidget(
      {super.key,
      required this.title,
      required this.isExpanded,
      required this.text,
      required this.links});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: EnvoySpacing.small), //EnvoySpacing.small)
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
                      child: Text(
                        title,
                        style: EnvoyTypography.button
                            .copyWith(color: EnvoyColors.accentPrimary),
                      ),
                    ),
                    Transform.rotate(
                        angle: isExpanded ? (180 * math.pi / 180) : 0,
                        child: const EnvoyIcon(
                          EnvoyIcons.chevron_down,
                          color: EnvoyColors.accentPrimary,
                        ))
                  ],
                ),
                if (isExpanded)
                  const SizedBox(
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
