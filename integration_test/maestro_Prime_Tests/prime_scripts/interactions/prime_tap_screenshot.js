// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Tap (X, Y), wait WAIT_MS (default 800), capture PATH (default
// /tmp/prime-bridge-shot.png). One USB session, no reconnect overhead.
//
// How to use
//   From Maestro YAML:
//     - runScript:
//         file: prime_scripts/interactions/prime_tap_screenshot.js
//         env:
//           X: "240"
//           Y: "400"
//           WAIT_MS: "800"        # optional
//           PATH: "/tmp/foo.png"  # optional
//
//   From shell (via prime-tap-screenshot.sh):
//     ./prime-tap-screenshot.sh 240 400                       # default 800ms wait
//     ./prime-tap-screenshot.sh 240 400 1500 /tmp/foo.png     # custom wait + path

var body = { x: parseInt(X, 10), y: parseInt(Y, 10) };
if (typeof WAIT_MS !== "undefined" && WAIT_MS) body.wait_ms = parseInt(WAIT_MS, 10);
if (typeof PATH !== "undefined" && PATH) body.path = PATH;

var response = http.post(
  "http://127.0.0.1:7556/prime/tap-screenshot",
  {
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  }
);

if (!response.ok) {
  throw "prime-bridge tap-screenshot failed: HTTP " + response.status + " " + response.body;
}

output.tapScreenshot = "ok";
