// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/business/keys_manager.dart';
import 'package:flutter/material.dart';
import 'package:http_tor/http_tor.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';
import 'package:tor/tor.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/home/cards/purchase_completed.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/generated/l10n.dart';

class RampWidget {
  static void showRamp(
      BuildContext context, EnvoyAccount account, String address) {
    if (KeysManager().keys == null) {
      return;
    }

    final ramp = RampFlutter();
    final Configuration configuration = Configuration();
    configuration.hostAppName = "Ramp Flutter";
    configuration.url = "https://app.ramp.network";
    configuration.hostApiKey = KeysManager().keys!.rampKey;
    configuration.userAddress = address;
    configuration.swapAsset = "BTC_BTC";
    ramp.onOnrampPurchaseCreated = (purchase, purchaseViewToken, apiUrl) =>
        onOnrampPurchaseCreated(
            purchase, purchaseViewToken, apiUrl, account, context);
    ramp.onSendCryptoRequested = onSendCryptoRequested;
    ramp.onOfframpSaleCreated = onOfframpSaleCreated;
    ramp.onRampClosed = () => onRampClosed(context);

    configuration.enabledFlows = ['ONRAMP'];
    configuration.hostLogoUrl =
        "https://storage.googleapis.com/cdn-foundation/envoy/foundationLogo.png";

    ramp.showRamp(configuration);

    // ENV-1111: Ensure the user is at the home route ("/") after exiting Ramp
    Future.delayed(const Duration(seconds: 1), () {
      mainRouter.go("/");
    });
  }

  static Future<void> onOnrampPurchaseCreated(
      OnrampPurchase purchase,
      String purchaseViewToken,
      String apiUrl,
      EnvoyAccount account,
      BuildContext context) async {
    String address = purchase.receiverAddress ?? "";
    int amount;
    String amountString = purchase.cryptoAmount ?? "";
    int? rampFee = toSatoshis(purchase.appliedFee, purchase.assetExchangeRate);

    try {
      amount = int.parse(amountString);
    } catch (e) {
      amount = 0;
    }
    String txID = purchase.id!;

    await EnvoyStorage().addPendingTx(txID, account.id, DateTime.now(),
        TransactionType.ramp, amount, 0, address,
        purchaseViewToken: purchaseViewToken,
        rampId: purchase.id,
        rampFee: rampFee);
    EnvoyStorage().addTxNote(note: S().ramp_note, key: txID);
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) {
          return MediaQuery.removePadding(
              context: context,
              child: fullScreenShield(PurchaseComplete(account)));
        }),
      );
    }
  }

  static void onSendCryptoRequested(SendCryptoPayload payload) {
    // Handle send crypto requested
  }

  static void onOfframpSaleCreated(
    OfframpSale sale,
    String saleViewToken,
    String apiUrl,
  ) {
    // Handle offramp sale created
  }

  static void onRampClosed(BuildContext context) {}
}

Future<String?> checkPurchase(String id, String purchaseViewToken) async {
  var response = await HttpTor(Tor.instance, EnvoyScheduler().parallel).get(
    "https://api.ramp.network/api/host-api/purchase/$id?secret=$purchaseViewToken",
  );
  var data = jsonDecode(response.body);

  if (data != null && data.containsKey('status')) {
    return data['status'];
  }

  return null;
}

int? toSatoshis(double? feeAmount, double? exchangeRate) {
  if (feeAmount == null || exchangeRate == null || exchangeRate == 0) {
    return null;
  }

  double amountInBitcoin = feeAmount / exchangeRate;
  int amountInSatoshis = (amountInBitcoin * 100000000).round();

  return amountInSatoshis;
}
