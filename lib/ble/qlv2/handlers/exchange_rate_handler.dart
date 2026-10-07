// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';
import 'package:envoy/business/exchange_rate.dart' as envoy_fx;
import 'package:envoy/channels/ql_connection.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

class QLV2ExchangeRateHistoryHandler
    implements QLV2RequestHandler<qlv2.InboundRpc_ExchangeRateHistory> {
  @override
  Future<void> handleRequest(
    qlv2.InboundRpc_ExchangeRateHistory rpc,
    QLConnection device,
  ) async {
    final request = rpc.field0.payload;
    final currencyCode = _normalizeCurrencyCode(request.currencyCode);
    final cached = envoy_fx.ExchangeRate().history;
    envoy_fx.ExchangeRateHistory? history;
    try {
      history = await envoy_fx.ExchangeRate().fetchHistoryForCode(currencyCode);
    } catch (_) {
      // A cached or empty response keeps the Passport request recoverable.
    }
    history ??= cached.isUsableFor(currencyCode) ? cached : null;
    await rpc.field0.respond(
      response: _buildHistoryResponse(currencyCode, history),
    );
  }
}

class QLV2ExchangeRateSubscriptionHandler
    implements
        QLV2SubscriptionHandler<qlv2.InboundRpc_ExchangeRateSubscription>,
        QLV2DisposableHandler {
  VoidCallback? _exchangeRateListener;
  qlv2.InboundRpc_ExchangeRateSubscription? _activeRpc;
  double? _lastSentRate;
  BigInt? _lastSentTimestamp;
  int _subscriptionGeneration = 0;

  @override
  Future<void> handleSubscription(
    qlv2.InboundRpc_ExchangeRateSubscription rpc,
    QLConnection device,
  ) async {
    await _finishActiveSubscription();

    final currencyCode =
        _normalizeCurrencyCode(rpc.field0.payload.currencyCode);
    _activeRpc = rpc;
    final generation = ++_subscriptionGeneration;
    _lastSentRate = null;
    _lastSentTimestamp = null;

    Future<void> sendLatest() async {
      final activeRpc = _activeRpc;
      if (activeRpc == null || generation != _subscriptionGeneration) {
        return;
      }

      try {
        final rate = await _buildCurrentRate(currencyCode);
        if (rate == null) {
          return;
        }

        if (generation != _subscriptionGeneration || !device.isQLActive()) {
          return;
        }

        if (_lastSentRate == rate.rate &&
            _lastSentTimestamp == rate.timestamp) {
          return;
        }

        await activeRpc.field0.send(event: rate);
        _lastSentRate = rate.rate;
        _lastSentTimestamp = rate.timestamp;
      } catch (_) {
        await _finishActiveSubscription();
      }
    }

    _exchangeRateListener = () {
      unawaited(sendLatest());
    };
    envoy_fx.ExchangeRate().addListener(_exchangeRateListener!);
    await sendLatest();
  }

  @override
  void dispose() {
    unawaited(_finishActiveSubscription());
  }

  Future<void> _finishActiveSubscription() async {
    final listener = _exchangeRateListener;
    if (listener != null) {
      envoy_fx.ExchangeRate().removeListener(listener);
      _exchangeRateListener = null;
    }

    final rpc = _activeRpc;
    _subscriptionGeneration++;
    _activeRpc = null;
    _lastSentRate = null;
    _lastSentTimestamp = null;

    if (rpc == null) {
      return;
    }

    try {
      await rpc.field0.finish();
    } catch (e) {
      // The peer may already have closed the subscription.
    }
  }
}

typedef VoidCallback = void Function();

qlv2.ExchangeRateHistory _buildHistoryResponse(
  String currencyCode,
  envoy_fx.ExchangeRateHistory? history,
) {
  final List<envoy_fx.RatePoint> points =
      history != null && history.currency.toUpperCase() == currencyCode
          ? history.points.toList()
          : <envoy_fx.RatePoint>[];
  return qlv2.ExchangeRateHistory(
    history: points
        .map((point) => qlv2.PricePoint(
            rate: point.price, timestamp: BigInt.from(point.timestamp)))
        .toList(),
    currencyCode: currencyCode,
  );
}

Future<qlv2.ExchangeRate?> _buildCurrentRate(
  String requestedCurrencyCode,
) async {
  final exchangeRate = envoy_fx.ExchangeRate();
  final selectedCurrencyCode = exchangeRate.getCode().toUpperCase();
  final rate = requestedCurrencyCode == "USD"
      ? exchangeRate.usdRate
      : selectedCurrencyCode == requestedCurrencyCode
          ? exchangeRate.selectedCurrencyRate
          : await exchangeRate.getRateForCode(requestedCurrencyCode);
  if (rate == null) {
    return null;
  }

  final timestamp = requestedCurrencyCode == "USD"
      ? exchangeRate.usdRateTimestamp
      : DateTime.now();

  return qlv2.ExchangeRate(
    currencyCode: requestedCurrencyCode,
    rate: rate,
    timestamp: BigInt.from(
      (timestamp ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000,
    ),
  );
}

String _normalizeCurrencyCode(String currencyCode) {
  final normalized = currencyCode.trim().toUpperCase();
  return normalized.isEmpty ? "USD" : normalized;
}
