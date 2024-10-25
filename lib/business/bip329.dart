// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:wallet/wallet.dart';

String getXpub(Wallet wallet) {
  // Check if the wallet is hot
  if (!wallet.hot) {
    return wallet.name;
  } else {
    // Extract xpub from publicExternalDescriptor
    String descriptor = wallet.publicExternalDescriptor ?? "";
    int start = descriptor.indexOf(']') + 1;
    int end = descriptor.indexOf('/', start);
    if (start > 0 && end > start) {
      return descriptor.substring(start, end);
    } else {
      return ''; // Return empty string if format is not as expected
    }
  }
}

String buildKeyJson(String type, String ref, String label,
    {String? origin, bool? spendable}) {
  // Define the map structure
  Map<String, dynamic> data = {
    "type": type,
    "ref": ref,
    "label": label,
  };

  // Add optional fields if they're provided
  if (origin != null && origin.isNotEmpty) {
    data["origin"] = origin;
  }
  if (spendable != null) {
    data["spendable"] = spendable;
  }

  // Convert map to JSON string
  return jsonEncode(data);
}

String extractDescriptor(String input) {
  // Find the position of the closing bracket "]"
  int end = input.indexOf(']') + 1;

  // Extract the substring from the start up to and including the "]" bracket
  if (end > 0) {
    return '${input.substring(0, end)})'; // Add ")" at the end
  } else {
    return ''; // Return an empty string if the format is not as expected
  }
}
