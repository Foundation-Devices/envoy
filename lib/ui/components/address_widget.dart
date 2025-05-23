// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/state/home_page_state.dart';

class AddressWidget extends StatelessWidget {
  final String address;
  final bool short;
  final Key? widgetKey;
  final TextAlign? align;
  final int sideChunks;
  final bool showWarningOnCopy;
  final bool returnAddressHalves;

  final TextStyle textStyleBold =
      EnvoyTypography.body.copyWith(color: EnvoyColors.textPrimary);
  final TextStyle textStyleNormal = EnvoyTypography.body.copyWith(
    color: EnvoyColors.textTertiary,
  );

  AddressWidget({
    super.key,
    required this.address,
    this.short = false,
    this.widgetKey,
    this.align = TextAlign.right,
    this.sideChunks = 2,
    this.showWarningOnCopy = true,
    this.returnAddressHalves = false,
  });

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler = MediaQuery.of(context).textScaler.clamp(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.6,
        );
    double baseFontScale = 1;
    double textScaleFactor = textScaler.scale(baseFontScale);

    return GestureDetector(
      onLongPress: () async {
        bool dismissed = await EnvoyStorage()
            .checkPromptDismissed(DismissiblePrompt.copyAddressWarning);
        if (!dismissed && context.mounted && showWarningOnCopy) {
          showWarningOnAddressCopy(context, address);
        } else {
          Clipboard.setData(ClipboardData(text: address));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Address copied to clipboard!')), //TODO: FIGMA
            );
          }
        }
      },
      child: returnAddressHalves
          ? Column(
              children: [
                RichText(
                  textScaler: TextScaler.linear(textScaleFactor),
                  text: TextSpan(
                    children: _buildFirstHalfAddressChunks(address),
                  ),
                  textAlign: align!,
                ),
                RichText(
                  textScaler: TextScaler.linear(textScaleFactor),
                  text: TextSpan(
                    children: _buildSecondHalfAddressChunks(address),
                  ),
                  textAlign: align!,
                ),
              ],
            )
          : RichText(
              textScaler: TextScaler.linear(textScaleFactor),
              text: TextSpan(
                children: _buildAddressTextSpans(),
              ),
              textAlign: align!,
            ),
    );
  }

  List<TextSpan> _buildAddressTextSpans() {
    if (short) {
      return _buildShortAddressTextSpans(address);
    }
    return _buildAddressChunks(address);
  }

  List<TextSpan> _buildShortAddressTextSpans(String address) {
    List<TextSpan> fullTextSpans = _buildAddressChunks(address);
    List<TextSpan> shortTextSpans = [];

    if (fullTextSpans.length <= sideChunks * 2 * 2) {
      return fullTextSpans;
    }

    shortTextSpans
        .addAll(fullTextSpans.getRange(0, sideChunks * 2)); // "space" included
    shortTextSpans.add(TextSpan(text: '...', style: textStyleNormal));
    shortTextSpans.addAll(fullTextSpans.getRange(
        fullTextSpans.length - sideChunks * 2, fullTextSpans.length));

    return shortTextSpans;
  }

  List<TextSpan> _buildAddressChunks(String address) {
    return _buildAddressChunksInRange(address, 0, (address.length / 4).ceil());
  }

  List<TextSpan> _buildFirstHalfAddressChunks(String address) {
    int totalChunks = (address.length / 4).ceil();
    int mid = (totalChunks / 2).ceil();
    return _buildAddressChunksInRange(address, 0, mid);
  }

  List<TextSpan> _buildSecondHalfAddressChunks(String address) {
    int totalChunks = (address.length / 4).ceil();
    int mid = (totalChunks / 2).ceil();
    return _buildAddressChunksInRange(address, mid, totalChunks);
  }

  List<TextSpan> _buildAddressChunksInRange(
      String address, int startChunk, int endChunk) {
    List<TextSpan> textSpans = [];
    const int chunkSize = 4;
    bool isBold = true;

    for (int i = startChunk; i < endChunk; i++) {
      int start = i * chunkSize;
      int end = (start + chunkSize < address.length)
          ? start + chunkSize
          : address.length;
      String chunk = address.substring(start, end);

      // Add a space before each chunk (except the first one)
      if (i != startChunk) {
        textSpans.add(TextSpan(text: ' ', style: textStyleNormal));
      }

      textSpans.add(TextSpan(
        text: chunk,
        style: isBold ? textStyleBold : textStyleNormal,
      ));

      isBold = !isBold;
    }

    return textSpans;
  }
}

void showWarningOnAddressCopy(BuildContext context, String address) {
  showEnvoyPopUp(
      context,
      S().copyToClipboard_address,
      S().component_continue,
      (BuildContext context) {
        Clipboard.setData(ClipboardData(text: address));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Address copied to clipboard!"), //TODO: FIGMA
        ));
        Navigator.pop(context);
      },
      icon: EnvoyIcons.info,
      secondaryButtonLabel: S().component_cancel,
      onSecondaryButtonTap: (BuildContext context) {
        Navigator.pop(context);
      },
      checkBoxText: S().component_dontShowAgain,
      checkedValue: false,
      onCheckBoxChanged: (checkedValue) {
        if (!checkedValue) {
          EnvoyStorage().addPromptState(DismissiblePrompt.copyAddressWarning);
        } else if (checkedValue) {
          EnvoyStorage()
              .removePromptState(DismissiblePrompt.copyAddressWarning);
        }
      });
}
