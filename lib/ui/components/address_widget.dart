// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
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

  final TextStyle textStyleBold =
      EnvoyTypography.body.copyWith(color: EnvoyColors.textPrimary);
  final TextStyle textStyleNormal = EnvoyTypography.body.copyWith(
    color: EnvoyColors.textTertiary,
  );

  AddressWidget(
      {super.key,
      required this.address,
      this.short = false,
      this.widgetKey,
      this.align = TextAlign.right,
      this.sideChunks = 2,
      this.showWarningOnCopy = true});

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler = MediaQuery.of(context).textScaler.clamp(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.8,
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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Address copied to clipboard!'))); //TODO: FIGMA
          }
        }
      },
      child: RichText(
        textScaler: TextScaler.linear(textScaleFactor),
        text: TextSpan(
          children: short
              ? _buildShortAddressTextSpans(address)
              : _buildFullAddressTextSpans(address),
        ),
        textAlign: align!,
      ),
    );
  }

  List<TextSpan> _buildShortAddressTextSpans(String address) {
    List<TextSpan> fullTextSpans = _buildAddressChunks(address);
    List<TextSpan> shortTextSpans = [];

    if (fullTextSpans.length <= sideChunks * 2 * 2) {
      return fullTextSpans;
    }

    shortTextSpans
        .addAll(fullTextSpans.getRange(0, 2 * sideChunks)); // "space" included

    shortTextSpans.add(
      TextSpan(
        text: '...',
        style: textStyleNormal,
      ),
    );

    shortTextSpans.addAll(fullTextSpans.getRange(
        fullTextSpans.length - 2 * sideChunks, fullTextSpans.length));

    return shortTextSpans;
  }

  List<TextSpan> _buildFullAddressTextSpans(String address) {
    return _buildAddressChunks(address);
  }

  List<TextSpan> _buildAddressChunks(String address) {
    List<TextSpan> textSpans = [];
    const int chunkSize = 4;
    bool isBold = true;

    for (int i = 0; i < address.length; i += chunkSize) {
      int currentChunkSize =
          (address.length >= (i + chunkSize)) ? chunkSize : address.length - i;
      String chunk = address.substring(i, i + currentChunkSize);

      if (i != 0) {
        // Add a space before each chunk (except the first one)
        textSpans.add(TextSpan(text: ' ', style: textStyleNormal));
      }

      textSpans.add(
        TextSpan(
          text: chunk,
          style: isBold ? textStyleBold : textStyleNormal,
        ),
      );

      isBold = !isBold; // Alternate between bold and regular
    }

    return textSpans;
  }

  double calculateOptimalPadding(String address, BuildContext context,
      {double allHorizontalPaddings = 0}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double addressBox = screenWidth - allHorizontalPaddings;
    double addressHalfWidth = 0;
    double optimalPadding = 0;

    TextPainter textPainter = TextPainter(
      // calculate address width in a single line
      text: TextSpan(children: _buildAddressChunks(address)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();

    addressHalfWidth = textPainter.width * 0.5 +
        EnvoySpacing.large2; // half the address width + a bit more

    if (addressBox > addressHalfWidth) {
      // calculate padding if it is positive
      optimalPadding = (addressBox - addressHalfWidth) * 0.5;
    } else {
      optimalPadding = EnvoySpacing.xs;
    }

    return optimalPadding;
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
