// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/coin_tag.dart';

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

Future<List<String>> getTxData(Wallet wallet) async {
  List<Transaction> transactions = wallet.transactions;
  String origin = extractDescriptor(wallet.externalDescriptor ?? "");
  List<String> txDataList = [];

  for (Transaction tx in transactions) {
    String note = await EnvoyStorage().getTxNote(tx.txId) ?? "";
    String txData = buildKeyJson("tx", tx.txId, note, origin: origin);
    txDataList.add(txData);
  }

  return txDataList;
}

Future<List<String>> getUtxosData(Account account) async {
  List<Utxo> utxos = account.wallet.utxos;
  List<String> locked = await CoinRepository().getBlockedCoins();
  List<CoinTag> tags =
      await CoinRepository().getCoinTags(accountId: account.id);
  List<String> utxoDataList = [];

  for (Utxo utxo in utxos) {
    String utxoInfo = "${utxo.txid}:${utxo.vout}";

    // Set label based on whether utxoInfo is in coinsId
    String label =
        tags.firstWhereOrNull((tag) => tag.coinsId.contains(utxoInfo))?.name ??
            "";
    bool isSpendable = !locked.contains(utxoInfo);

    // Generate utxoData and add it to the list
    String utxoData =
        buildKeyJson("output", utxoInfo, label, spendable: isSpendable);
    utxoDataList.add(utxoData);
  }

  return utxoDataList;
}
