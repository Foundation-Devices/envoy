// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/node_url.dart';

/// Whether an Electrum client should validate the server's TLS certificate.
///
/// A Tor onion service is authenticated by its onion address, and personal
/// node packages commonly add a local or self-signed TLS certificate on top.
/// Clearnet servers still require TLS validation when reached through Tor.
bool shouldValidateElectrumCertificate({
  required String server,
  required bool viaTor,
  required bool hasCertificateException,
}) {
  if (hasCertificateException) {
    return false;
  }

  return !(viaTor && isOnionElectrumServer(server));
}

bool isOnionElectrumServer(String server) {
  final value = server.contains('://') ? server : 'tcp://$server';
  final uri = Uri.tryParse(value);
  if (uri == null || uri.host.isEmpty) {
    return false;
  }

  final host = uri.host.toLowerCase().replaceFirst(RegExp(r'\.$'), '');
  return host.endsWith('.onion');
}

bool hasElectrumCertificateException({
  required String server,
  required Iterable<String> exceptions,
}) {
  final normalizedServer = normalizeElectrumCertificateServer(server);
  return exceptions.any(
    (exception) =>
        normalizeElectrumCertificateServer(exception) == normalizedServer,
  );
}

String normalizeElectrumCertificateServer(String server) {
  return parseNodeUrl(server).toLowerCase();
}
