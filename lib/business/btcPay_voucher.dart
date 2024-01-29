// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:http_tor/http_tor.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:wallet/wallet.dart';
import 'dart:async';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/business/account.dart';

enum BtcPayVoucherRedeemResult { Success, Timeout, VoucherInvalid }

class BtcPayVoucher {
  String id = "";
  String name = "";
  String description = "";
  String uri = "";
  String? amount;
  String? currency;
  bool? autoApproveClaims;
  String? errorMessage;

  BtcPayVoucher(String url) {
    id = getPullPaymentIdFromUrl(url);
    uri = getUrifromUrl(url);
  }

  String getPullPaymentIdFromUrl(String url) {
    Uri uri = Uri.parse(url);
    return uri.pathSegments.last;
  }

  String getUrifromUrl(String url) {
    Uri uri = Uri.parse(url);
    return uri.host;
  }

  static bool isVoucher(String url) {
    return url.contains("btcpay");
  }

  Future<BtcPayVoucherRedeemResult> getinfo() async {
    String url = "https://" + uri + "/api/v1/pull-payments/" + id;

    HttpTor _http = await HttpTor(Tor.instance, EnvoyScheduler().parallel);

    Response? response = null;

    try {
      response = await _http.get(url);
    } on TimeoutException {
      return BtcPayVoucherRedeemResult.Timeout;
    }

    switch (response.statusCode) {
      case 200:
        {
          final json = jsonDecode(response.body);
          amount = json['amount'] ?? null;
          currency = json['currency'] ?? null;
          autoApproveClaims = json['autoApproveClaims'] ?? null;
          name = json['name'] ?? null;
          description = json['description'] ?? null;
          return BtcPayVoucherRedeemResult.Success;
        }

      default:
        // Request failed
        break;
    }

    return BtcPayVoucherRedeemResult.VoucherInvalid;
  }

  Future<BtcPayVoucherRedeemResult> createPayout(String address) async {
    String url = "https://" + uri + "/api/v1/pull-payments/" + id + "/payouts";

    HttpTor _http = await HttpTor(Tor.instance, EnvoyScheduler().parallel);

    Response? response = null;
    Map<String, dynamic> data = {
      "destination": address,
      "amount": amount,
      // it is possible to pay only part of the voucher amount
      "paymentMethod": "BTC-OnChain"
    };
    var requestBody = json.encode(data);

    try {
      response = await _http.post(url,
          headers: {
            'Content-Type': 'application/json', // Set the content type to JSON
          },
          body: requestBody);
    } on TimeoutException {
      return BtcPayVoucherRedeemResult.Timeout;
    }

    switch (response.statusCode) {
      case 200:
        {
          //final json = jsonDecode(response.body); // do something with data if needed
          return BtcPayVoucherRedeemResult.Success;
        }
      case 400 || 422:
        {
          final json = jsonDecode(response.body);
          errorMessage = json[0]['message'] ?? "oops";

          return BtcPayVoucherRedeemResult.VoucherInvalid;
        }

      default:
        // Request failed
        break;
    }

    return BtcPayVoucherRedeemResult.VoucherInvalid;
  }
}

void addPendingTx(String address, Account account) {
  EnvoyStorage().addPendingTx(address, account.id ?? "", DateTime.now(),
      TransactionType.btcPay, 0, 0, address);
}

btcPaySync(Account account) async {
  final pendingBtcPayTxs =
      await EnvoyStorage().getPendingTxs(account.id!, TransactionType.btcPay);

  if (pendingBtcPayTxs.isEmpty) return;

  for (var pendingBtcPayTx in pendingBtcPayTxs) {
    account.wallet.transactions
        .where((tx) => tx.outputs!.contains(pendingBtcPayTx.address))
        .forEach((actualBtcPayTx) {
      EnvoyStorage().deletePendingTx(pendingBtcPayTx.address!);
    });
  }
}
