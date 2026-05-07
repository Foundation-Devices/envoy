// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Tap Prime's screen at (X, Y).
//
// How to use
//   From Maestro YAML:
//     - runScript:
//         file: prime_scripts/prime_tap.js
//         env:
//           X: "240"
//           Y: "400"
//
//   From shell (via prime-tap.sh):
//     ./prime-tap.sh 240 400

var response = http.post(
  "http://127.0.0.1:7556/prime/tap",
  {
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ x: parseInt(X, 10), y: parseInt(Y, 10) })
  }
);

if (!response.ok) {
  throw "prime-bridge tap failed: HTTP " + response.status + " " + response.body;
}

output.tap = "ok";
