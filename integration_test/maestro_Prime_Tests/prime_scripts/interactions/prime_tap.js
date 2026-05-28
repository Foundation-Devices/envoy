// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Tap Prime's screen at (X, Y).
//
// Pass X="home" (Y is ignored) to tap the capacitive home button below
// the LCD instead — sensor area is x=0..199, y=850..970; tap lands at
// the center (100, 910).
//
// How to use
//   From Maestro YAML:
//     - runScript:
//         file: prime_scripts/interactions/prime_tap.js
//         env:
//           X: "240"
//           Y: "400"
//     - runScript:
//         file: prime_scripts/interactions/prime_tap.js
//         env:
//           X: "home"

var tapX, tapY;
if (typeof X === "string" && X.toLowerCase() === "home") {
  tapX = 100;
  tapY = 910;
} else {
  tapX = parseInt(X, 10);
  tapY = parseInt(Y, 10);
}

var response = http.post(
  "http://127.0.0.1:7556/prime/tap",
  {
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ x: tapX, y: tapY })
  }
);

if (!response.ok) {
  throw "prime-bridge tap failed: HTTP " + response.status + " " + response.body;
}

output.tap = "ok";
