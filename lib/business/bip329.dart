// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:ngwallet/ngwallet.dart';

String getXpub(NgDescriptor ngDescriptor, EnvoyAccount account) {
  // Check if the wallet is hot
  if (!account.isHot) {
    return account.name;
  } else {
    // Extract xpub from publicExternalDescriptor
    //TODO: fix for unified descriptors
    String descriptor = ngDescriptor.external_ ?? "";
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

//TODO: fix for unified wallet transactions
Future<List<String>> getTxData(EnvoyAccount account) async {
  List<String> txDataList = [];
  // List<BitcoinTransaction> transactions = account.transactions;
  // for(NgDescriptor descriptor in account.descriptors) {
  //
  //   String origin = extractDescriptor(descriptor.external_ ?? "");
  //   List<String> txDataList = [];
  //   for (Transaction tx in transactions) {
  //     String note = await EnvoyStorage().getTxNote(tx.txId) ?? "";
  //     String txData = buildKeyJson("tx", tx.txId, note, origin: origin);
  //     txDataList.add(txData);
  //   }
  //
  // }

  return txDataList;
}

Future<List<String>> getUtxosData(List<Output> utxos) async {
  List<String> utxoDataList = [];
  for (Output utxo in utxos) {
    // Generate utxoData and add it to the list

    String utxoData = buildKeyJson(
        "output", "${utxo.txId}:${utxo.vout}", utxo.tag ?? "",
        spendable: !utxo.doNotSpend);
    utxoDataList.add(utxoData);
  }

  return utxoDataList;
}

List<Output> mergeLatestOutputs(
    List<Output> currentOutputs, List<Output> latestOutputs) {
  final Map<String, Output> merged = {
    for (final output in currentOutputs)
      "${output.txId}:${output.vout}": output,
  };

  for (final latest in latestOutputs) {
    final key = "${latest.txId}:${latest.vout}";
    final existing = merged[key];

    if (existing == null ||
        existing.tag != latest.tag ||
        existing.doNotSpend != latest.doNotSpend) {
      // Add new or updated output
      merged[key] = latest;
    }
  }

  return merged.values.toList();
}
