// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:http_tor/http_tor.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:wallet/wallet.dart';
import 'dart:async';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/business/account.dart';

enum BtcPayVoucherRedeemResult { Success, Timeout, VoucherInvalid }

enum BtcPayVoucherErrorType { Invalid, Expired, OnChain }

class BtcPayVoucher {
  String id = "";
  String name = "";
  String description = "";
  String uri = "";
  String? amount;
  String? currency;
  bool? autoApproveClaims;
  String errorMessage = "";
  int? amountSats;
  BtcPayVoucherErrorType errorType = BtcPayVoucherErrorType.Invalid;
  String link = "";
  DateTime? expiresAt;

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

  int? getAmountInSats() {
    if (amount == null) return null;
    if (currency == "SATS") {
      try {
        return int.parse(amount!);
      } catch (e) {
        return null;
      }
    }
    if (currency == "BTC") {
      try {
        double btc = double.parse(amount!);
        int satoshis = (btc * 100000000).toInt();
        return satoshis;
      } catch (e) {
        return null;
      }
    }
    if (currency == Settings().selectedFiat) {
      try {
        return ExchangeRate().convertFiatStringToSats(amount!);
      } catch (e) {
        return null;
      }
    }
    return null;
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
          id = json['id'];
          amount = json['amount'];
          currency = json['currency'];
          autoApproveClaims = json['autoApproveClaims'];
          name = json['name'];
          description = json['description'];
          link = json['viewLink'] ?? "";
          amountSats = getAmountInSats();
          int? unixTimestamp = json['expiresAt'];
          expiresAt = convertUnixTimestampToDateTime(unixTimestamp);
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
      return BtcPayVoucherRedeemResult.VoucherInvalid;
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
          errorMessage = json[0]['message'] ?? "";
          errorMessage = errorMessage.toLowerCase();
          if (errorMessage.contains("onchain")) {
            errorType = BtcPayVoucherErrorType.OnChain;
          }

          if (errorMessage.contains("expired")) {
            errorType = BtcPayVoucherErrorType.Expired;
          }

          return BtcPayVoucherRedeemResult.VoucherInvalid;
        }

      default:
        // Request failed
        break;
    }

    return BtcPayVoucherRedeemResult.VoucherInvalid;
  }
}

void addPendingTx(String pullPaymentId, String address, Account account) {
  EnvoyStorage().addPendingTx(pullPaymentId, account.id ?? "", DateTime.now(),
      TransactionType.btcPay, 0, 0, address);
  EnvoyStorage().addTxNote("BTCPay voucher", address); // TODO: FIGMA
}

DateTime? convertUnixTimestampToDateTime(int? unixTimestamp) {
  if (unixTimestamp == null) return null;
  int milliseconds = unixTimestamp * 1000;
  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
  DateTime localDateTime = dateTime.toLocal();
  return localDateTime;
}
