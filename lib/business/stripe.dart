import 'dart:convert';
import 'package:envoy/business/keys_manager.dart';
import 'package:flutter/material.dart';
import 'package:http_tor/http_tor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:ngwallet/ngwallet.dart';

// TODO: add more info to the OnrampSessionInfo class
class OnrampSessionInfo {
  final String id;
  final String clientSecret;
  final String? redirectUrl;
  final String? status;
  final String accountId;

  OnrampSessionInfo({
    required this.id,
    required this.clientSecret,
    this.redirectUrl,
    this.status,
    required this.accountId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientSecret': clientSecret,
      'redirectUrl': redirectUrl,
      'status': status,
      'accountId': accountId,
    };
  }

  factory OnrampSessionInfo.fromMap(Map<String, dynamic> map) {
    return OnrampSessionInfo(
        id: map['id'],
        clientSecret: map['clientSecret'],
        redirectUrl: map['redirectUrl'],
        status: map['status'],
        accountId: map['accountId']);
  }

  @override
  String toString() {
    return 'OnrampSessionInfo(id: $id, status: $status, redirectUrl: $redirectUrl, accountId: $accountId)';
  }
}

Future<OnrampSessionInfo?> createOnrampSession(
    String address, String accountId) async {
  const url = 'https://api.stripe.com/v1/crypto/onramp_sessions';

  final body = 'wallet_addresses[bitcoin]=$address'
      '&destination_currency=btc'
      '&destination_network=bitcoin';

  try {
    final response = await HttpTor().post(
      url,
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

Future<String?> getOnrampSessionStatus(String sessionId) async {
  final url = 'https://api.stripe.com/v1/crypto/onramp_sessions/$sessionId';

  final response = await HttpTor().get(
    url,
    headers: {
      'Authorization': 'Bearer $stripeSecretKey',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final status = json['status'];
    kPrint('Session status: $status');
    // Update the stored Onramp session (if exists)
    await EnvoyStorage().updateOnrampSessionStatus(sessionId, status);
    return status;
  } else {
    kPrint('Failed to fetch Onramp session: ${response.statusCode}');
    kPrint('Response body: ${response.body}');
    return null;
  }
}

Future<void> launchOnrampSession(
  BuildContext context,
  String address, {
  required EnvoyAccount selectedAccount,
  required Function(bool) onRampOpenChanged,
}) async {
  final session = await createOnrampSession(address, selectedAccount.id);

  if (session == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create Onramp session')),
      );
    }
    return;
  }

  if (session.redirectUrl != null && session.redirectUrl!.isNotEmpty) {
    final uri = Uri.parse(session.redirectUrl!);

    if (await canLaunchUrl(uri)) {
      if (context.mounted) {
        onRampOpenChanged(true);
      }

      await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch ${session.redirectUrl}')),
        );
      }
    }
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No redirect URL provided for session')),
      );
    }
  }
}

// TODO: call in some timer
Future<void> checkAllOnrampSessionStatuses() async {
  // Retrieve all stored sessions
  final sessions = await EnvoyStorage().getAllOnrampSessions();

  if (sessions.isEmpty) {
    kPrint('No Onramp sessions found.');
    return;
  }

  kPrint('Checking status for ${sessions.length} Onramp sessions...');

  for (final session in sessions) {
    final sessionId = session.id;
    final url = 'https://api.stripe.com/v1/crypto/onramp_sessions/$sessionId';

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

        if (status != null) {
          // Update local storage
          await EnvoyStorage().updateOnrampSessionStatus(sessionId, status);

          // Handle each possible status
          switch (status) {
            case 'initialized':
              kPrint('Session $sessionId is initialized.');
              break;

            case 'rejected':
              kPrint('Session $sessionId was rejected.');
              break;

            case 'requires_payment':
              kPrint('Session $sessionId requires payment.');
              break;

            case 'fulfillment_processing':
              // TODO: add amount, fee and adsress!!!
              EnvoyStorage().addPendingTx(session.id, session.accountId,
                  DateTime.now(), TransactionType.stripe, 0, 0, "address");
              kPrint('Session $sessionId is being processed.');
              break;

            case 'fulfillment_complete':
              EnvoyStorage().addPendingTx(session.id, session.accountId,
                  DateTime.now(), TransactionType.stripe, 0, 0, "address");
              kPrint('Session $sessionId is complete!');
              break;

            default:
              kPrint('Session $sessionId has unknown status: $status');
          }
        } else {
          kPrint('No status field for session $sessionId.');
        }
      } else {
        // Handle Stripe API error response
        final body = jsonDecode(response.body);

        if (body is Map && body.containsKey('error')) {
          final error = body['error'];
          final code = error['code'];
          final message = error['message'];

          kPrint('❗ Stripe error for session $sessionId: [$code] $message');

          if (code == 'resource_missing') {
            // Remove missing sessions from storage
            await EnvoyStorage().deleteOnrampSession(sessionId);
            kPrint('Removed missing session $sessionId from local storage.');
          }
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
