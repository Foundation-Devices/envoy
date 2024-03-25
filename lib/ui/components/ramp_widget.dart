// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/home/cards/purchase_completed.dart';
import 'package:envoy/ui/shield.dart';

String rampApiKey = Platform.environment['RAMP_API_KEY'] ?? "";

class RampWidget {
  static void showRamp(BuildContext context, Account account, String address) {
    final ramp = RampFlutter();
    final Configuration configuration = Configuration();
    configuration.hostAppName = "Ramp Flutter";
    configuration.url = "https://app.ramp.network";
    configuration.hostApiKey = rampApiKey;
    configuration.userAddress = address;
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
  }

  static Future<void> onOnrampPurchaseCreated(
      OnrampPurchase purchase,
      String purchaseViewToken,
      String apiUrl,
      Account account,
      BuildContext context) async {
    String address = purchase.receiverAddress ?? "";
    int amount;
    String amountString = purchase.cryptoAmount ?? "";
    try {
      amount = int.parse(amountString);
    } catch (e) {
      amount = 0;
    }
    String txID = purchase.id!;

    await EnvoyStorage().addPendingTx(txID, account.id ?? "", DateTime.now(),
        TransactionType.ramp, amount, 0, address);
    EnvoyStorage().addTxNote("Ramp Purchase", address); //TODO: figma
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

  static void onRampClosed(BuildContext context) {
    // Handle ramp closed
  }
}
