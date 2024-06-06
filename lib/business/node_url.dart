// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

const String TCP_PREFIX = "tcp://";
const String SSL_PREFIX = "ssl://";

const String TCP_SUFFIX = ":t";
const String SSL_SUFFIX = ":s";

const String TCP_PORT = ":50001";
const String SSL_PORT = ":50002";

String parseNodeUrl(String nodeUrl) {
  if (nodeUrl.startsWith(TCP_PREFIX) || nodeUrl.startsWith(SSL_PREFIX)) {
    return nodeUrl;
  } else {
    if (nodeUrl.endsWith(SSL_SUFFIX)) {
      return SSL_PREFIX +
          nodeUrl.substring(0, nodeUrl.length - SSL_SUFFIX.length);
    }

    if (nodeUrl.endsWith(TCP_SUFFIX)) {
      return TCP_PREFIX +
          nodeUrl.substring(0, nodeUrl.length - TCP_SUFFIX.length);
    }

    if (nodeUrl.endsWith(SSL_PORT)) {
      return SSL_PREFIX + nodeUrl;
    }

    if (nodeUrl.endsWith(TCP_PORT)) {
      return TCP_PREFIX + nodeUrl;
    }
  }

  return nodeUrl;
}

bool isPrivateAddress(String ipAddress) {
  if (ipAddress.startsWith(TCP_PREFIX) || ipAddress.startsWith(SSL_PREFIX)) {
    ipAddress = ipAddress.substring(TCP_PREFIX.length);
  }

  List<String> parts = ipAddress.split('.');

  if (parts.length != 4) {
    // IP address should have four parts separated by dots
    return false;
  }

  try {
    int part1 = int.parse(parts[0]);
    int part2 = int.parse(parts[1]);

    // Check if the first two parts are within the private address ranges
    if ((part1 == 10) ||
        (part1 == 172 && part2 >= 16 && part2 <= 31) ||
        (part1 == 192 && part2 == 168)) {
      return true;
    }
  } catch (e) {
    // Parsing error
    return false;
  }

  // Not a private address
  return false;
}
