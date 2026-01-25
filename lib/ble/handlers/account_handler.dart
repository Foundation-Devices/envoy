// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///
import 'package:collection/collection.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:ngwallet/ngwallet.dart';

class BleAccountHandler extends PassportMessageHandler {
  BleAccountHandler(super.connection){
    setupExchangeRateListener();
  }

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_AccountUpdate ||
        message is api.QuantumLinkMessage_CreateMagicBackupEvent ||
        message is api.QuantumLinkMessage_RestoreMagicBackupRequest;
  }



  void setupExchangeRateListener() {
    ExchangeRate().addListener(() async {
      await sendExchangeRate();
    });
  }


  @override
  Future<void> handleMessage(api.QuantumLinkMessage message) async {
    if (message case api.QuantumLinkMessage_AccountUpdate accountUpdate) {
      kPrint("Got account update message: ${accountUpdate.field0.accountId}");
      _handleAccountUpdate(accountUpdate.field0);
    }
  }

  void _handleAccountUpdate(api.AccountUpdate accountUpdate) async {
    kPrint("Got account update!");
    kPrint("Got payload! ${accountUpdate.accountId}");
    final payload = accountUpdate.update;
    final config =
        await EnvoyAccountHandler.getConfigFromRemote(remoteUpdate: payload);
    kPrint(
        "Got config ${config.id} ${config.descriptors.map((e) => e.external_)}");
    final fingerprint =
        NgAccountManager.getFingerprint(config.descriptors.first.internal);
    if (fingerprint == null) {
      throw Exception("Invalid fingerprint $fingerprint");
    }
    final dir = NgAccountManager.getAccountDirectory(
        deviceSerial: config.deviceSerial ?? "prime",
        network: config.network.toString(),
        fingerprint: fingerprint,
        number: config.index);
    kPrint("Account path! ${dir.path}");

    if (await dir.exists()) {
      EnvoyReport().log("AccountManager",
          "Failed to create account directory for ${config.name}:${config.deviceSerial}, already exists: ${dir.path}");

      final acc = NgAccountManager()
          .accounts
          .firstWhereOrNull((a) => a.id == config.id);
      kPrint("Account already exists, updating handler $acc");

      if (acc != null) {
        kPrint("Account already exists, updating handler");
        final handler = acc.handler;
        if (handler != null) {
          await handler.renameAccount(name: config.name);
          await handler.setArchived(archived: config.archived);
          kPrint("Account updated!");
          return;
        }
      }
    } else {
      await dir.create(recursive: true);
    }

    final accountHandler = await EnvoyAccountHandler.addAccountFromConfig(
        dbPath: dir.path, config: config);
    await NgAccountManager()
        .addAccount(await accountHandler.state(), accountHandler);
    kPrint("Account added!");
  }




  Future<void> sendAccountUpdate(api.AccountUpdate accountUpdate) async {
    await qlConnection.writeMessage(api.QuantumLinkMessage.accountUpdate(accountUpdate));
  }

  bool _sendingData = false;
  double _lastSentBtcPrice = 0.0;

  Future<void> sendExchangeRate() async {
    if (_sendingData) return;
    kPrint(
        "Preparing to send exchange rate to Prime... $_sendingData devices ${qlConnection.deviceId}");
    try {
      _sendingData = true;
      final exchangeRate = ExchangeRate();
      final currentExchange = exchangeRate.usdRate!;

      // Only send if price actually changed
      if (_lastSentBtcPrice == currentExchange) {
        return;
      }

      final timestamp = exchangeRate.usdRateTimestamp?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch;

      final exchangeRateMessage = api.ExchangeRate(
        currencyCode: "USD",
        rate: currentExchange,
        timestamp: BigInt.from(timestamp / 1000),
      );

      qlConnection.writeMessage(api.QuantumLinkMessage.exchangeRate(exchangeRateMessage));

      _lastSentBtcPrice = currentExchange;
    } catch (e) {
      kPrint('Failed to send exchange rate to Prime: $e');
    } finally {
      _sendingData = false;
    }
  }



  Future<void> sendExchangeRateHistory() async {
    if (_sendingData) return;
    try {
      _sendingData = true;

      final historyPoints = ExchangeRate().history.points;
      final currency = ExchangeRate().history.currency;

      if (historyPoints.isEmpty) {
        kPrint("No exchange rate history to send.");
        return;
      }

      // Convert Dart RatePoint -> API PricePoint
      final apiPoints = historyPoints.map((p) {
        return api.PricePoint(
          rate: p.price,
          timestamp: BigInt.from(p.timestamp),
        );
      }).toList();

      final historyMessage = api.ExchangeRateHistory(
        history: apiPoints,
        currencyCode: currency,
      );

      await qlConnection.writeMessage(
          api.QuantumLinkMessage.exchangeRateHistory(historyMessage));

      kPrint(
          "Sent ${apiPoints.length} exchange rate points for currency $currency");
    } catch (e) {
      kPrint('Failed to send exchange rate history: $e');
    } finally {
      _sendingData = false;
    }
  }



}
