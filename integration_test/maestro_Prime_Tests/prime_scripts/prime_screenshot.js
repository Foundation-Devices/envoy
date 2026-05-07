// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Capture Prime's screen via the bridge. Optional env: PATH (PNG output path).
//
// How to use
//   From Maestro YAML:
//     - runScript:
//         file: prime_scripts/prime_screenshot.js
//         env:
//           PATH: "/tmp/prime.png"   // optional
//
//   From shell (via prime-screenshot.sh):
//     ./prime-screenshot.sh -o /tmp/prime.png

var body = {};
if (typeof PATH !== "undefined" && PATH) body.path = PATH;

var response = http.post(
  "http://127.0.0.1:7556/prime/screenshot",
  {
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  }
);

if (!response.ok) {
  throw "prime-bridge screenshot failed: HTTP " + response.status + " " + response.body;
}

output.screenshot = "ok";
