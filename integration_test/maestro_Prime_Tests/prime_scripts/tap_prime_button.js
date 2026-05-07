// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Called from Maestro via `runScript:`. Asks the local prime-bridge
// (started by run_maestro.sh) to fire passport-drive's tap on Prime
// at the canned (24, 760) coordinate.
//
// Maestro's runScript sandbox only has `http.request`, no shell exec —
// hence the bridge.
//
// How to use
//   From Maestro YAML:
//     - runScript: prime_scripts/tap_prime_button.js
//
//   From shell (via tap-prime-button.sh):
//     ./tap-prime-button.sh                # taps once
//     ./tap-prime-button.sh -s out.png     # taps then captures a screenshot

var response = http.post(
  "http://127.0.0.1:7556/prime/tap-button",
  {
    headers: { "Content-Type": "application/json" },
    body: "{}"
  }
);

if (!response.ok) {
  throw "prime-bridge tap failed: HTTP " + response.status + " " + response.body;
}

output.tap = "ok";
