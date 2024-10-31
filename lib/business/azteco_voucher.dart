// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:http_tor/http_tor.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/scheduler.dart';
import 'dart:async';

enum AztecoVoucherRedeemResult {
  success,
  timeout,
  voucherInvalid // Able to reach server but problem with voucher
}

class AztecoVoucher {
  List<String> code = [];

  AztecoVoucher(String url) {
    // Parse the url to code
    // Old format: "https://azte.co/?c1=1111&c2=2222&c3=3333&c4=4444";
    // New format: "https://azte.co/redeem?code=1111222233334444"

    Uri uri = Uri.parse(url);
    Map<String, dynamic> queryParams = uri.queryParameters;

    if (queryParams.length == 4) {
      code = [
        queryParams['c1'],
        queryParams['c2'],
        queryParams['c3'],
        queryParams['c4']
      ];
    }
    if (queryParams.length == 1) {
      String queryData = queryParams['code'];

      for (int i = 0; i < queryData.length; i += 4) {
        code.add(queryData.substring(i, i + 4));
      }
    }
  }

  Future<AztecoVoucherRedeemResult> redeem(String address) async {
    String url = getRedeemUrl(address);

    HttpTor http = HttpTor(Tor.instance, EnvoyScheduler().parallel);

    Response? response;

    try {
      response = await http.get(url);
    } on TimeoutException {
      return AztecoVoucherRedeemResult.timeout;
    }

    switch (response.statusCode) {
      case 200:
        // Request succeeded, parse the response
        return AztecoVoucherRedeemResult.success;

      default:
        // Request failed
        break;
    }

    return AztecoVoucherRedeemResult.voucherInvalid;
  }

  String getRedeemUrl(String address) {
    return "https://azte.co/fd_despatch.php?CODE_1=${code[0]}&CODE_2=${code[1]}&CODE_3=${code[2]}&CODE_4=${code[3]}&ADDRESS=$address";
  }

  static bool isVoucher(String url) {
    Uri uri = Uri.parse(url);
    return uri.host == "azte.co";
  }
}

void addPendingTx(String address, Account account) {
  EnvoyStorage().addPendingTx(address, account.id ?? "", DateTime.now(),
      TransactionType.azteco, 0, 0, address);
  EnvoyStorage().addTxNote(note: S().azteco_note, key: address);
}
