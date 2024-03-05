// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/util/envoy_storage.dart';

String rampApiKey = Platform.environment['RAMP_API_KEY'] ?? "";

Widget runRamp(Account account) {
  _setupNotifications();
  return RampFlutterApp(
    account: account,
  );
}

final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _setupNotifications() async {
  const InitializationSettings settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  await _localNotificationsPlugin.initialize(settings).then((_) {
    debugPrint('Local Notifications setup success');
  }).catchError((Object error) {
    debugPrint('Local Notifications setup error: $error');
  });
}

class RampFlutterApp extends StatefulWidget {
  const RampFlutterApp({Key? key, required this.account}) : super(key: key);
  final Account account;

  @override
  State<RampFlutterApp> createState() => _RampFlutterAppState();
}

class _RampFlutterAppState extends State<RampFlutterApp> {
  final ramp = RampFlutter();
  final Configuration _configuration = Configuration();
  String address = "";

  @override
  void initState() {
    initializeAsync();
    super.initState();
  }

  Future<void> initializeAsync() async {
    address = await widget.account.wallet.getAddress();
    print(address);
    _configuration.hostAppName = "Ramp Flutter";
    _configuration.url = "https://app.ramp.network";
    _configuration.hostApiKey = rampApiKey;
    _configuration.userAddress = address;
    ramp.onOnrampPurchaseCreated = onOnrampPurchaseCreated;
    ramp.onSendCryptoRequested = onSendCryptoRequested;
    ramp.onOfframpSaleCreated = onOfframpSaleCreated;
    ramp.onRampClosed = onRampClosed;
  }

  Future<void> onOnrampPurchaseCreated(
    OnrampPurchase purchase,
    String purchaseViewToken,
    String apiUrl,
  ) async {
    String address = purchase.receiverAddress ?? "";
    int amount;
    String amountString = purchase.cryptoAmount ?? "";
    try {
      amount = int.parse(amountString);
    } catch (e) {
      amount = 0;
    }
    String txID = purchase.finalTxHash!;
    await EnvoyStorage().addPendingTx(txID, widget.account.id ?? "",
        DateTime.now(), TransactionType.ramp, amount, 0, address);
    EnvoyStorage().addTxNote("Ramp transaction", address);

    _showNotification("Ramp Notification", "onramp purchase created");
  }

  void onSendCryptoRequested(SendCryptoPayload payload) {
    _showNotification("Ramp Notification", "send crypto requested");
  }

  void onOfframpSaleCreated(
    OfframpSale sale,
    String saleViewToken,
    String apiUrl,
  ) {
    _showNotification("Ramp Notification", "offramp sale created");
  }

  void onRampClosed() {
    _showNotification("Ramp Notification", "ramp closed");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeAsync(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.all(EnvoySpacing.medium1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tap the button below to be redirected to the Ramp app",
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Address: " + address,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: EnvoySpacing.large3),
                  child: _showRampButton(),
                )
              ],
            ),
          );
        } else {
          return Center(
            child: SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4.71,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _showRampButton() {
    return ElevatedButton(
      onPressed: () {
        ramp.showRamp(_configuration);
      },
      child: PlatformText("Show Ramp"),
    );
  }

  Future<void> _showNotification(String title, String message) async {
    const AndroidNotificationDetails android =
        AndroidNotificationDetails("channelId", "channelName");
    const NotificationDetails details = NotificationDetails(android: android);
    await _localNotificationsPlugin.show(
      1,
      title,
      message,
      details,
    );
  }
}

rampSync(Account account) async {
  final pendingTxs =
      await EnvoyStorage().getPendingTxs(account.id!, TransactionType.ramp);

  if (pendingTxs.isEmpty) return;

  for (var pendingTx in pendingTxs) {
    account.wallet.transactions.where((tx) {
      return tx.txId == pendingTx.txId;
    }).forEach((txToRemove) {
      EnvoyStorage().deletePendingTx(pendingTx.txId);
    });
  }
}
