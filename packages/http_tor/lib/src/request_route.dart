// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

int resolveScheduledProxyPort({
  required bool requiresTor,
  required int currentTorPort,
}) {
  if (!requiresTor) return -1;
  if (currentTorPort == -1) {
    throw StateError('Tor route is unavailable');
  }
  return currentTorPort;
}

Future<T> runWithRouteReplacement<T>({
  required bool requiresTor,
  required Future<int> Function() resolveRoute,
  required Future<T> Function(int port) run,
}) async {
  int? attemptedPort;
  try {
    attemptedPort = await resolveRoute();
    return await run(attemptedPort);
  } catch (error, stackTrace) {
    if (!requiresTor) rethrow;

    late final int replacementPort;
    try {
      replacementPort = await resolveRoute();
    } catch (_) {
      Error.throwWithStackTrace(error, stackTrace);
    }

    if (replacementPort == attemptedPort) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    return run(replacementPort);
  }
}
