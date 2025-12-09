// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:envoy/business/keys_manager.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:flutter/material.dart';
import 'package:http_tor/http_tor.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:ngwallet/ngwallet.dart';
import 'dart:async';
import 'package:envoy/account/envoy_transaction.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:url_launcher/url_launcher_string.dart';

const stripeApiUrl = 'https://api.stripe.com/v1/crypto/onramp_sessions';

class StripeSessionMonitor {
  static final StripeSessionMonitor _instance =
      StripeSessionMonitor._internal();

  factory StripeSessionMonitor() => _instance;

  StripeSessionMonitor._internal();

  Timer? _timer;

  void init({Duration interval = const Duration(minutes: 1)}) {
    if (_timer?.isActive ?? false) return;

    _checkAllSessions();
    _timer = Timer.periodic(interval, (_) => _checkAllSessions());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkAllSessions() async {
    try {
      await checkAllOnrampSessionStatuses();
    } catch (e) {
      kPrint('[StripeSessionMonitor] Error while checking sessions: $e');
    }
  }
}

class OnrampSessionInfo {
  final String id;
  final String clientSecret;
  final String? redirectUrl;
  final String? status;
  final String accountId;
  final String? transactionId;
  final double? destinationAmount;
  final double? networkFee;
  final double? transactionFee;
  final String? walletAddress;
  final String? sourceCurrency;

  OnrampSessionInfo({
    required this.id,
    required this.clientSecret,
    this.redirectUrl,
    this.status,
    required this.accountId,
    this.transactionId,
    this.destinationAmount,
    this.networkFee,
    this.transactionFee,
    this.walletAddress,
    this.sourceCurrency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientSecret': clientSecret,
      'redirectUrl': redirectUrl,
      'status': status,
      'accountId': accountId,
      'transactionId': transactionId,
      'destinationAmount': destinationAmount,
      'networkFee': networkFee,
      'transactionFee': transactionFee,
      'walletAddress': walletAddress,
      'sourceCurrency': sourceCurrency,
    };
  }

  factory OnrampSessionInfo.fromMap(Map<String, dynamic> map) {
    return OnrampSessionInfo(
      id: map['id'],
      clientSecret: map['clientSecret'],
      redirectUrl: map['redirectUrl'],
      status: map['status'],
      accountId: map['accountId'],
      transactionId: map['transactionId'],
      destinationAmount: _tryParseDouble(map['destinationAmount']),
      networkFee: _tryParseDouble(map['networkFee']),
      transactionFee: _tryParseDouble(map['transactionFee']),
      walletAddress: map['walletAddress'],
      sourceCurrency: map['sourceCurrency'],
    );
  }

  static double? _tryParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  OnrampSessionInfo copyWith({
    String? status,
    String? transactionId,
    double? destinationAmount,
    double? networkFee,
    double? transactionFee,
    String? walletAddress,
    String? sourceCurrency,
  }) {
    return OnrampSessionInfo(
      id: id,
      clientSecret: clientSecret,
      redirectUrl: redirectUrl,
      accountId: accountId,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      destinationAmount: destinationAmount ?? this.destinationAmount,
      networkFee: networkFee ?? this.networkFee,
      transactionFee: transactionFee ?? this.transactionFee,
      walletAddress: walletAddress ?? this.walletAddress,
      sourceCurrency: sourceCurrency ?? this.sourceCurrency,
    );
  }

  @override
  String toString() {
    return 'OnrampSessionInfo('
        'id: $id, '
        'status: $status, '
        'transactionId: $transactionId, '
        'destinationAmount: $destinationAmount, '
        'networkFee: $networkFee, '
        'transactionFee: $transactionFee, '
        'walletAddress: $walletAddress, '
        'sourceCurrency: $sourceCurrency, '
        'redirectUrl: $redirectUrl, '
        'accountId: $accountId)';
  }
}

Future<OnrampSessionInfo?> createOnrampSession(
    String address, String accountId) async {
  final body = 'wallet_addresses[bitcoin]=$address'
      '&destination_networks[0]=bitcoin'
      '&destination_currencies[0]=btc'
      '&destination_currency=btc'
      '&destination_network=bitcoin';

  try {
    final response = await HttpTor().post(
      stripeApiUrl,
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      // Build session model from response
      final session = OnrampSessionInfo(
        id: json['id'],
        clientSecret: json['client_secret'],
        redirectUrl: json['redirect_url'],
        status: json['status'] ?? 'created',
        accountId: accountId,
      );

      await EnvoyStorage().addNewOnrampSession(session);

      return session;
    } else {
      kPrint('❌ Failed to create Onramp session: ${response.statusCode}');
      kPrint('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    kPrint('⚠️ Error creating Onramp session: $e');
    return null;
  }
}

Future<void> checkAllOnrampSessionStatuses() async {
  final sessions = await EnvoyStorage().getAllOnrampSessions();

  if (sessions.isEmpty) {
    return;
  }

  for (final session in sessions) {
    final sessionId = session.id;
    final url = '$stripeApiUrl/$sessionId';

    try {
      final response = await HttpTor().get(
        url,
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final status = json['status'] as String?;
        final details = json['transaction_details'] as Map<String, dynamic>?;

        String? transactionId;
        double? destinationAmount;
        double? networkFee;
        double? transactionFee;
        String? walletAddress;
        String? sourceCurrency;

        if (details != null) {
          transactionId = details['transaction_id'];
          destinationAmount =
              double.tryParse(details['destination_amount'] ?? '');
          walletAddress = details['wallet_address'] as String?;
          sourceCurrency = details['source_currency'] as String?;

          if (details['fees'] != null) {
            final fees = details['fees'] as Map;
            networkFee = double.tryParse(fees['network_fee_amount'] ?? '');
            transactionFee =
                double.tryParse(fees['transaction_fee_amount'] ?? '');
          }
        }

        // Update local storage with session info
        await EnvoyStorage().updateOnrampSession(
          sessionId,
          status: status,
          transactionId: transactionId,
          destinationAmount: destinationAmount,
          networkFee: networkFee,
          transactionFee: transactionFee,
          walletAddress: walletAddress,
          sourceCurrency: sourceCurrency,
        );

        // Handle each possible status
        switch (status) {
          case 'initialized':
            kPrint('Session $sessionId is initialized.');
            break;

          case 'rejected':
            await EnvoyStorage().deleteOnrampSession(sessionId);
            await EnvoyStorage().deletePendingTx(sessionId);
            kPrint('Session $sessionId was rejected.');
            break;

          case 'requires_payment':
            kPrint('Session $sessionId requires payment.');
            break;

          case 'fulfillment_processing':
            EnvoyTransaction? pendingTx =
                await EnvoyStorage().getPendingTx(session.id);
            if (pendingTx == null) {
              int amountInSats = (destinationAmount! * 100000000).toInt();
              await EnvoyStorage().addPendingTx(
                session.id,
                session.accountId,
                DateTime.now(),
                TransactionType.stripe,
                amountInSats,
                0,
                walletAddress ?? 'unknown',
                note: S().stripe_note,
                stripeId: session.id,
              );
            }
            kPrint('Session $sessionId is being processed.');
            break;

          case 'fulfillment_complete':
            EnvoyTransaction? pendingTx =
                await EnvoyStorage().getPendingTx(session.id);
            if (pendingTx == null) {
              int amountInSats = (destinationAmount! * 100000000).toInt();
              await EnvoyStorage().addPendingTx(
                session.id,
                session.accountId,
                DateTime.now(),
                TransactionType.stripe,
                amountInSats,
                0,
                walletAddress ?? 'unknown',
                note: S().stripe_note,
                stripeId: session.id,
              );
            }

            break;

          default:
            kPrint('Session $sessionId has unknown status: $status');
        }
      } else {
        // Handle Stripe API error response
        final body = jsonDecode(response.body);

        if (body is Map && body.containsKey('error')) {
          final error = body['error'];
          final code = error['code'];
          final message = error['message'];

          kPrint('❗ Stripe error for session $sessionId: [$code] $message');

          await EnvoyStorage().deleteOnrampSession(sessionId);
          await EnvoyStorage().deletePendingTx(sessionId);
          EnvoyReport().log("Stripe",
              'Stripe error for session $sessionId: [$code] $message');
        } else {
          kPrint(
              'Failed to check session $sessionId: ${response.statusCode} ${response.body}');
        }
      }
    } catch (e) {
      kPrint('Error checking Onramp session $sessionId: $e');
    }
  }
}

Future<bool> waitForOnrampSessionCompletion(String sessionId) async {
  const pollInterval = Duration(seconds: 5);
  const timeout = Duration(minutes: 10);
  final endTime = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(endTime)) {
    try {
      final url = '$stripeApiUrl/$sessionId';
      final response = await HttpTor().get(
        url,
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final status = json['status'] as String?;
        final details = json['transaction_details'] as Map<String, dynamic>?;

        String? transactionId;
        double? destinationAmount;
        double? networkFee;
        double? transactionFee;
        String? walletAddress;
        String? sourceCurrency;

        if (details != null) {
          transactionId = details['transaction_id'];
          destinationAmount =
              double.tryParse(details['destination_amount'] ?? '');
          walletAddress = details['wallet_address'] as String?;
          sourceCurrency = details['source_currency'] as String?;

          if (details['fees'] != null) {
            final fees = details['fees'] as Map;
            networkFee = double.tryParse(fees['network_fee_amount'] ?? '');
            transactionFee =
                double.tryParse(fees['transaction_fee_amount'] ?? '');
          }
        }

        // Update local storage with session info
        await EnvoyStorage().updateOnrampSession(
          sessionId,
          status: status,
          transactionId: transactionId,
          destinationAmount: destinationAmount,
          networkFee: networkFee,
          transactionFee: transactionFee,
          walletAddress: walletAddress,
          sourceCurrency: sourceCurrency,
        );

        if (status == 'fulfillment_processing' ||
            status == 'fulfillment_complete') {
          return true;
        } else if (status == 'rejected') {
          return false;
        }
      } else {
        await EnvoyStorage().deleteOnrampSession(sessionId);
        await EnvoyStorage().deletePendingTx(sessionId);
        return false;
      }
    } catch (e) {
      kPrint('Error checking Onramp session $sessionId: $e');
    }

    await Future.delayed(pollInterval);
  }

  return false;
}

Future<(bool, OnrampSessionInfo?)> launchOnrampSession(
  BuildContext context,
  String address, {
  required EnvoyAccount selectedAccount,
}) async {
  final session = await createOnrampSession(address, selectedAccount.id);

  if (session == null ||
      session.redirectUrl == null ||
      session.redirectUrl!.isEmpty) {
    kPrint('❌ Failed to create Onramp session');
    return (false, session);
  }

  final launched = await launchUrlString(session.redirectUrl!);
  if (!launched) {
    kPrint('❌ Could not launch ${session.redirectUrl}');
    return (false, session);
  }

  // Poll for session status (blocks until success/fail/timeout)
  final success = await waitForOnrampSessionCompletion(session.id);

  final updatedSession =
      await EnvoyStorage().getStoredOnrampSession(session.id);

  if (success && updatedSession != null) {
    kPrint('✅ Onramp session ${updatedSession.id} succeeded.');
    EnvoyTransaction? pendingTx =
        await EnvoyStorage().getPendingTx(updatedSession.id);
    if (pendingTx == null && updatedSession.destinationAmount != null) {
      int amountInSats =
          (updatedSession.destinationAmount! * 100000000).toInt();
      await EnvoyStorage().addPendingTx(
        updatedSession.id,
        updatedSession.accountId,
        DateTime.now(),
        TransactionType.stripe,
        amountInSats,
        0,
        address,
        note: S().stripe_note,
        stripeId: session.id,
      );
    }
    return (true, updatedSession);
  } else {
    kPrint('❌ Onramp session ${session.id} failed.');
    return (false, session);
  }
}
