// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';

class AddressWidget extends StatelessWidget {
  final String address;
  final TextStyle textStyleBold = EnvoyTypography.body
      .copyWith(color: EnvoyColors.textSecondary, fontWeight: FontWeight.bold);
  final TextStyle textStyleNormal = EnvoyTypography.body
      .copyWith(color: EnvoyColors.textTertiary, fontWeight: FontWeight.normal);
  final bool short;

  AddressWidget({
    required this.address,
    this.short = false,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: short
            ? _buildShortAddressTextSpans(address)
            : _buildFullAddressTextSpans(address),
      ),
    );
  }

  List<TextSpan> _buildShortAddressTextSpans(String address) {
    List<TextSpan> fullTextSpans = _buildAddressChunks(address);
    List<TextSpan> shortTextSpans = [];
    final int numOfSideChunks = 2;

    if (fullTextSpans.length <= numOfSideChunks) {
      return fullTextSpans;
    }

    shortTextSpans.addAll(
        fullTextSpans.getRange(0, 2 * numOfSideChunks)); // "space" included

    shortTextSpans.add(
      TextSpan(
        text: '...',
        style: textStyleNormal.copyWith(
          color: EnvoyColors.textTertiary,
          fontWeight: FontWeight.normal,
        ),
      ),
    );

    shortTextSpans.addAll(fullTextSpans.getRange(
        fullTextSpans.length - 2 * numOfSideChunks, fullTextSpans.length));

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

      if (i > 0) {
        // Add a space before each chunk (except the first one)
        textSpans.add(const TextSpan(text: ' '));
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
}
