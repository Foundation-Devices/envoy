// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:http_tor/http_tor.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/util/console.dart';

Future<bool> getCashFromSignetFaucet(Account account, int sats) async {
  if (account.wallet.network == Network.Signet) {
    String url = 'https://faucet.mutinynet.com/api/onchain';
    HttpTor http = HttpTor(Tor.instance, EnvoyScheduler().parallel);
    String address = await account.wallet.getAddress();
    Map<String, dynamic> data = {
      "sats": sats,
      "address": address,
    };
    var requestBody = json.encode(data);

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );
      if (response.statusCode == 200) {
        kPrint("Request successful");
        return true;
      } else {
        kPrint("Request failed with status: ${response.statusCode}");
        return false;
      }
    } on TimeoutException {
      kPrint("Request timed out");
      return false;
    } catch (e) {
      kPrint("An error occurred: $e");
      return false;
    }
  } else {
    kPrint("Not Signet network");
    return false;
  }
}
