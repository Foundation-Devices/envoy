// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/stream_replay_cache.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:ngwallet/ngwallet.dart';

// Mirror Core's acct_num % 6 cycling for Prime-sourced single-sig accounts.
// Prime's stored color is ignored; the index is the source of truth.
String _colorForPrimeAccountIndex(int index) {
  final palette = EnvoyColors.listAccountTileColors;
  final c = palette[index % palette.length];
  return '#${(c.r * 255).round().toRadixString(16).padLeft(2, '0')}'
      '${(c.g * 255).round().toRadixString(16).padLeft(2, '0')}'
      '${(c.b * 255).round().toRadixString(16).padLeft(2, '0')}';
}

class BleAccountHandler extends PassportMessageHandler {
  final _applyPassphraseStream =
      StreamController<api.ApplyPassphrase?>.broadcast();
  api.ApplyPassphrase? _latestApplyPassphrase;

  Stream<api.ApplyPassphrase?> get applyPassphraseStream =>
      _applyPassphraseStream.stream.replayLatest(_latestApplyPassphrase);

  api.ApplyPassphrase? get latestApplyPassphrase => _latestApplyPassphrase;

  late final void Function() _onExchangeRateChanged;
  Timer? _rateRefreshTimer;

  final _unpairRequestStream =
      StreamController<api.UnpairingRequest?>.broadcast();

  Stream<api.UnpairingRequest?> get unpairRequestStream =>
      _unpairRequestStream.stream.asBroadcastStream();

  BleAccountHandler(super.connection) {
    setupExchangeRateListener();
    // Re-push the rate periodically so Prime's "Last Update" indicator
    // stays fresh even when the BTC price hasn't moved.
    _rateRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!qlConnection.isQLActive()) return;
      if (_sendingData) {
        _resendRateOnReady = true;
        return;
      }
      unawaited(sendExchangeRate());
    });
  }

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_AccountUpdate ||
        message is api.QuantumLinkMessage_CreateMagicBackupEvent ||
        message is api.QuantumLinkMessage_UnpairingRequest ||
        message is api.QuantumLinkMessage_ApplyPassphrase ||
        message is api.QuantumLinkMessage_PrimeFiatPreference;
  }

  int lastExchangeRateHash = 0;

  void setupExchangeRateListener() {
    _onExchangeRateChanged = () async {
      if (lastExchangeRateHash != ExchangeRate().history.hashCode) {
        final result = await sendExchangeRateHistory();
        if (result == true) {
          lastExchangeRateHash = ExchangeRate().history.hashCode;
        }

        await sendExchangeRate();
      }
    };
    ExchangeRate().addListener(_onExchangeRateChanged);
  }

  @override
  void dispose() {
    _rateRefreshTimer?.cancel();
    ExchangeRate().removeListener(_onExchangeRateChanged);
    _applyPassphraseStream.close();
    _unpairRequestStream.close();
    super.dispose();
  }

  @override
  Future<void> handleMessage(api.QuantumLinkMessage message) async {
    if (message case api.QuantumLinkMessage_AccountUpdate accountUpdate) {
      kPrint("Got account update message: ${accountUpdate.field0.accountId}");
      await _handleAccountUpdate(accountUpdate.field0);
    } else if (message
        case api.QuantumLinkMessage_ApplyPassphrase applyPassphrase) {
      _latestApplyPassphrase = applyPassphrase.field0;
      _applyPassphraseStream.add(_latestApplyPassphrase);
    } else if (message
        case api.QuantumLinkMessage_UnpairingRequest unpairingRequest) {
      //Acknowledge the unpairing request, then disconnect and trigger the unpairing flow in the UI
      qlConnection.writeMessage(
        api.QuantumLinkMessage.unpairingResponse(
          api.UnpairingResponse(success: true),
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      _unpairRequestStream.add(unpairingRequest.field0);
      if (qlConnection.getDevice() != null) {
        await Devices().clearDeviceQLKeys(qlConnection.getDevice()!);
      }
      qlConnection.disconnect();
    } else if (message
        case api.QuantumLinkMessage_PrimeFiatPreference fiatPreference) {
      await _handleFiatPreference(fiatPreference.field0);
    }
  }

  Future<void> _handleFiatPreference(api.PrimeFiatPreference pref) async {
    final device = qlConnection.getDevice();
    if (device == null) return;

    if (pref.currencyCode.isEmpty) return;
    if (device.primeFiatCurrency == pref.currencyCode) return;
    await Devices().updatePrimeFiatCurrency(pref.currencyCode, device);
    if (_sendingData) {
      // A history or rate send is in flight; queue a resend for after it.
      _resendRateOnReady = true;
    } else {
      unawaited(sendExchangeRate());
    }
    // Also push a fresh chart in the new currency; bails if a send is in flight.
    unawaited(sendExchangeRateHistory());
  }

  Future<void> _handleAccountUpdate(api.AccountUpdate accountUpdate) async {
    kPrint("Got account update!");
    kPrint("Got payload! ${accountUpdate.accountId}");
    final payload = accountUpdate.update;
    var config = await EnvoyAccountHandler.getConfigFromRemote(
      remoteUpdate: payload,
    );
    kPrint(
      "Got config ${config.id} ${config.descriptors.map((e) => e.external_)}",
    );

    // When a seed is imported from a Core to Prime, the serialized account
    // data may carry the original Core's serial. Always use the connected
    // Prime device's serial so the account is correctly identified as Prime.
    // primeSerial is set synchronously on the pairing response, before the
    // async addDevice() completes, so it is always available here.
    final connectedSerial =
        qlConnection.getDevice()?.serial ?? qlConnection.primeSerial;

    if (connectedSerial != null && config.deviceSerial != connectedSerial) {
      kPrint(
        "Overriding deviceSerial from '${config.deviceSerial}' to '$connectedSerial'",
      );
      config = NgAccountConfig(
        name: config.name,
        color: config.color,
        seedHasPassphrase: config.seedHasPassphrase,
        deviceSerial: connectedSerial,
        dateAdded: config.dateAdded,
        preferredAddressType: config.preferredAddressType,
        index: config.index,
        descriptors: config.descriptors,
        dateSynced: config.dateSynced,
        network: config.network,
        id: config.id,
        multisig: config.multisig,
        archived: config.archived,
      );
    }

    // Single-sig: derive color from index regardless of what Prime sent.
    if (config.multisig == null) {
      config = NgAccountConfig(
        name: config.name,
        color: _colorForPrimeAccountIndex(config.index),
        seedHasPassphrase: config.seedHasPassphrase,
        deviceSerial: config.deviceSerial,
        dateAdded: config.dateAdded,
        preferredAddressType: config.preferredAddressType,
        index: config.index,
        descriptors: config.descriptors,
        dateSynced: config.dateSynced,
        network: config.network,
        id: config.id,
        multisig: config.multisig,
        archived: config.archived,
      );
    }

    final taprootEnabled = Settings().taprootEnabled();
    final hasTaproot = config.descriptors.any(
      (d) => d.addressType == AddressType.p2Tr,
    );
    final desiredAddressType =
        (taprootEnabled && hasTaproot) ? AddressType.p2Tr : AddressType.p2Wpkh;

    final fingerprint = NgAccountManager.getFingerprint(
      config.descriptors.first.internal,
    );
    if (fingerprint == null) {
      throw Exception("Invalid fingerprint $fingerprint");
    }
    final dir = NgAccountManager.getAccountDirectory(
      deviceSerial: config.deviceSerial ?? "prime",
      network: config.network.toString(),
      fingerprint: fingerprint,
      number: config.index,
    );
    kPrint("Account path! ${dir.path}");

    if (await dir.exists()) {
      EnvoyReport().log(
        "AccountManager",
        "Failed to create account directory for ${config.name}:${config.deviceSerial}, already exists: ${dir.path}",
      );

      final acc = NgAccountManager().accounts.firstWhereOrNull(
            (a) => a.id == config.id,
          );
      kPrint("Account already exists, updating handler $acc");

      if (acc != null) {
        kPrint("Account already exists, updating handler");
        final handler = acc.handler;
        if (handler != null) {
          await handler.renameAccount(name: config.name);
          await handler.setArchived(archived: config.archived);
          await handler.setPreferredAddressType(
            addressType: desiredAddressType,
          );
          // Read the handler's live config (NgAccountManager snapshot is stale).
          final currentColor = handler.config().color;
          if (currentColor.toLowerCase() != config.color.toLowerCase()) {
            await handler.setColor(color: config.color);
          }
          kPrint("Account updated!");
        }
      }

      return;
    } else {
      await dir.create(recursive: true);
    }

    final accountHandler = await EnvoyAccountHandler.addAccountFromConfig(
      dbPath: dir.path,
      config: config,
    );
    await NgAccountManager().addAccount(
      await accountHandler.state(),
      accountHandler,
    );
    await accountHandler.setPreferredAddressType(
      addressType: desiredAddressType,
    );
    kPrint("Account added!");
  }

  Future<void> sendAccountUpdate(api.AccountUpdate accountUpdate) async {
    await qlConnection.writeMessage(
      api.QuantumLinkMessage.accountUpdate(accountUpdate),
    );
  }

  bool _sendingData = false;
  bool _resendRateOnReady = false;

  void resetSendingState() {
    _sendingData = false;
    // Drop any queued periodic resend; the link is gone.
    _resendRateOnReady = false;
  }

  void _scheduleResendIfPending() {
    if (_resendRateOnReady) {
      _resendRateOnReady = false;
      unawaited(sendExchangeRate());
    }
  }

  Future<void> sendExchangeRate() async {
    if (_sendingData) return;

    final device = qlConnection.getDevice();
    if (device?.onboardingComplete != true) {
      kPrint(
        "Device not onboarded, skipping sending exchange rate. ${qlConnection.deviceId}",
      );
      return;
    }
    try {
      _sendingData = true;
      final exchangeRate = ExchangeRate();

      final primeCurrency = device?.primeFiatCurrency;
      final envoyCurrency = exchangeRate.history.currency;
      final currencyCode = (primeCurrency != null && primeCurrency.isNotEmpty)
          ? primeCurrency
          : (envoyCurrency.isNotEmpty ? envoyCurrency : "USD");

      final double rate;
      if (currencyCode == "USD") {
        rate = exchangeRate.usdRate!;
      } else if (currencyCode == exchangeRate.getCode() &&
          exchangeRate.selectedCurrencyRate != null) {
        rate = exchangeRate.selectedCurrencyRate!;
      } else {
        rate = await exchangeRate.getRateForCode(currencyCode);
      }

      final timestampMs = DateTime.now().millisecondsSinceEpoch;

      final exchangeRateMessage = api.ExchangeRate(
        currencyCode: currencyCode,
        rate: rate,
        timestamp: BigInt.from(timestampMs / 1000),
      );

      // Re-check liveness: a non-USD fetch above is async and the link
      // could have dropped while we were awaiting it.
      if (!qlConnection.isQLActive()) return;

      kPrint(
          "Sending exchange rate ($currencyCode) to Prime: ${qlConnection.deviceId}");
      await qlConnection.writeMessage(
        api.QuantumLinkMessage.exchangeRate(exchangeRateMessage),
      );
    } catch (e) {
      kPrint('Failed to send exchange rate to Prime: $e');
    } finally {
      _sendingData = false;
      _scheduleResendIfPending();
    }
  }

  Future<bool> sendExchangeRateHistory() async {
    if (_sendingData) return false;

    final device = qlConnection.getDevice();
    if (device?.onboardingComplete != true) {
      kPrint("Device not onboarded, skipping sending exchange rate history.");
      return false;
    }

    final primeCurrency = device?.primeFiatCurrency;

    try {
      _sendingData = true;

      final ExchangeRateHistory? source;
      if (primeCurrency != null &&
          primeCurrency.isNotEmpty &&
          primeCurrency != ExchangeRate().history.currency) {
        // Fetch a fresh series for Prime's currency without disturbing Envoy's UI.
        source = await ExchangeRate().fetchHistoryForCode(primeCurrency);
      } else {
        source = ExchangeRate().history;
      }
      if (source == null || source.points.isEmpty) {
        kPrint("No exchange rate history to send.");
        return false;
      }

      // Convert Dart RatePoint -> API PricePoint
      final apiPoints = source.points.map((p) {
        return api.PricePoint(
          rate: p.price,
          timestamp: BigInt.from(p.timestamp),
        );
      }).toList();

      final historyMessage = api.ExchangeRateHistory(
        history: apiPoints,
        currencyCode: source.currency,
      );

      final result = await qlConnection.writeMessage(
        api.QuantumLinkMessage.exchangeRateHistory(historyMessage),
      );
      kPrint(
        "Sent ${apiPoints.length} exchange rate points for currency ${source.currency}",
      );
      return result;
    } catch (e) {
      kPrint('Failed to send exchange rate history: $e');
      return false;
    } finally {
      _sendingData = false;
      _scheduleResendIfPending();
    }
  }
}
