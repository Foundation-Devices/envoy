// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Swipe from (SX, SY) to (EX, EY) on Prime. Optional STEPS controls
// drag granularity (default 15).
//
// How to use
//   From Maestro YAML:
//     - runScript:
//         file: prime_scripts/prime_swipe.js
//         env:
//           SX: "240"
//           SY: "600"
//           EX: "240"
//           EY: "200"
//           STEPS: "15"   # optional
//
//   From shell (via prime-swipe.sh):
//     ./prime-swipe.sh 240 600 240 200            # default 15 steps
//     ./prime-swipe.sh 240 600 240 200 30         # 30 steps

var body = {
  sx: parseInt(SX, 10),
  sy: parseInt(SY, 10),
  ex: parseInt(EX, 10),
  ey: parseInt(EY, 10)
};
if (typeof STEPS !== "undefined" && STEPS) body.steps = parseInt(STEPS, 10);

var response = http.post(
  "http://127.0.0.1:7556/prime/swipe",
  {
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  }
);

if (!response.ok) {
  throw "prime-bridge swipe failed: HTTP " + response.status + " " + response.body;
}

output.swipe = "ok";
