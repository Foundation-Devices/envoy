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

enum BtcPayVoucherRedeemResult { success, timeout, voucherInvalid }

enum BtcPayVoucherErrorType { invalid, expired, onChain, wrongNetwork }

class BtcPayVoucher {
  String pullPaymentId = "";
  String name = "";
  String description = "";
  String uri = "";
  String? amount;
  String? currency;
  bool? autoApproveClaims;
  String errorMessage = "";
  int? amountSats;
  BtcPayVoucherErrorType errorType = BtcPayVoucherErrorType.invalid;
  String link = "";
  DateTime? expiresAt;
  String payoutId = "";

  BtcPayVoucher(String url) {
    pullPaymentId = getPullPaymentIdFromUrl(url);
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
    return url.contains("pull-payments");
  }

  Future<BtcPayVoucherRedeemResult> getinfo() async {
    String url = "https://$uri/api/v1/pull-payments/$pullPaymentId";

    HttpTor http = HttpTor(Tor.instance, EnvoyScheduler().parallel);

    Response? response;

    try {
      response = await http.get(url);
    } on TimeoutException {
      return BtcPayVoucherRedeemResult.timeout;
    }

    switch (response.statusCode) {
      case 200:
        {
          final json = jsonDecode(response.body);
          pullPaymentId = json['id'];
          amount = json['amount'];
          currency = json['currency'];
          autoApproveClaims = json['autoApproveClaims'];
          name = json['name'];
          description = json['description'];
          link = json['viewLink'] ?? "";
          amountSats = getAmountInSats();
          int? unixTimestamp = json['expiresAt'];
          expiresAt = convertUnixTimestampToDateTime(unixTimestamp);
          return BtcPayVoucherRedeemResult.success;
        }

      default:
        // Request failed
        break;
    }

    return BtcPayVoucherRedeemResult.voucherInvalid;
  }

  Future<BtcPayVoucherRedeemResult> createPayout(String address) async {
    String url = "https://$uri/api/v1/pull-payments/$pullPaymentId/payouts";

    HttpTor http = HttpTor(Tor.instance, EnvoyScheduler().parallel);

    Response? response;
    Map<String, dynamic> data = {
      "destination": address,
      "amount": amount,
      // it is possible to pay only part of the voucher amount
      "paymentMethod": "BTC-OnChain"
    };
    var requestBody = json.encode(data);

    try {
      response = await http.post(url,
          headers: {
            'Content-Type': 'application/json', // Set the content type to JSON
          },
          body: requestBody);
    } on TimeoutException {
      return BtcPayVoucherRedeemResult.voucherInvalid;
    }
    switch (response.statusCode) {
      case 200:
        {
          final json = jsonDecode(response.body);
          payoutId = json['id'];
          return BtcPayVoucherRedeemResult.success;
        }
      case 400: // Wellknown error codes
        {
          final json = jsonDecode(response.body);
          errorMessage = json['message'] ?? "";
          String errorCode = json['code'] ?? "";
          if (errorCode == "payment-method-not-supported") {
            errorType = BtcPayVoucherErrorType.onChain;
          }

          if (errorCode == "expired") {
            errorType = BtcPayVoucherErrorType.expired;
          }

          return BtcPayVoucherRedeemResult.voucherInvalid;
        }
      case 422: // Unable to validate the request
        {
          final json = jsonDecode(response.body);
          errorMessage = json[0]['message'] ?? "";
          if (errorMessage ==
              "A valid address was not provided") // The message when network is wrong
          {
            errorType = BtcPayVoucherErrorType.wrongNetwork;
          }

          return BtcPayVoucherRedeemResult.voucherInvalid;
        }

      default:
        // Request failed
        break;
    }

    return BtcPayVoucherRedeemResult.voucherInvalid;
  }
}

void addPendingTx(
  String pullPaymentId,
  String address,
  Account account,
  int? amountSats,
  String? currency,
  String? currencyAmount,
  String payoutId,
  String btcPayVoucherUri,
) {
  EnvoyStorage().addPendingTx(pullPaymentId, account.id ?? "", DateTime.now(),
      TransactionType.btcPay, amountSats ?? 0, 0, address,
      pullPaymentId: pullPaymentId,
      currency: currency,
      currencyAmount: currencyAmount,
      payoutId: payoutId,
      btcPayVoucherUri: btcPayVoucherUri);
  EnvoyStorage()
      .addTxNote(note: "BTCPay voucher", key: pullPaymentId); // TODO: FIGMA
}

DateTime? convertUnixTimestampToDateTime(int? unixTimestamp) {
  if (unixTimestamp == null) return null;
  int milliseconds = unixTimestamp * 1000;
  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
  DateTime localDateTime = dateTime.toLocal();
  return localDateTime;
}

Future<String?> checkPayoutStatus(
    String uri, String pullPaymentId, String payoutId) async {
  var response = await HttpTor(Tor.instance, EnvoyScheduler().parallel).get(
    "https://$uri/api/v1/pull-payments/$pullPaymentId/payouts/$payoutId",
  );
  var data = jsonDecode(response.body);

  if (data != null && data.containsKey('state')) {
    return data['state'];
  }

  return null;
}
