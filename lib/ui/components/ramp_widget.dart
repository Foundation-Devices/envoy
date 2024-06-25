// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/business/keys_manager.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:http_tor/http_tor.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/home/cards/purchase_completed.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/business/scheduler.dart';

class RampWidget {
  static Future<void> showRamp(
      BuildContext context, Account account, String address) async {
    if (KeysManager().keys == null) {
      return;
    }
    // Show a circular progress indicator dialog to prevent the user from seeing the transition to the home page. (ENV-1190)
    BuildContext dialogContext = context;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: EnvoyColors.surface2,
      builder: (BuildContext context) {
        dialogContext = context;
        return const Center(
          child: CircularProgressIndicator(
            color: EnvoyColors.accentPrimary,
            backgroundColor: EnvoyColors.textInactive,
          ),
        );
      },
    );

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

    // ENV-1111: Ensure the user is at the home route ("/") after exiting Ramp
    mainRouter.go("/");
    await ramp.showRamp(configuration);

    // Dismiss the circular progress indicator dialog
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(dialogContext);
    });
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
        TransactionType.ramp, amount, 0, address,
        purchaseViewToken: purchaseViewToken);
    EnvoyStorage().addTxNote(note: "Ramp Purchase", key: address); //TODO: figma
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
