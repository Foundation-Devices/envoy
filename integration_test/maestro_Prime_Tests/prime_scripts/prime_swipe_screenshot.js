// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Swipe (SX,SY)→(EX,EY), wait WAIT_MS (default 1000), capture PATH
// (default /tmp/prime-bridge-shot.png).
//
// How to use
//   From Maestro YAML:
//     - runScript:
//         file: prime_scripts/prime_swipe_screenshot.js
//         env:
//           SX: "240"
//           SY: "600"
//           EX: "240"
//           EY: "200"
//           WAIT_MS: "1000"       # optional
//           PATH: "/tmp/foo.png"  # optional
//
//   From shell (via prime-swipe-screenshot.sh):
//     ./prime-swipe-screenshot.sh 240 600 240 200                       # default 1000ms wait
//     ./prime-swipe-screenshot.sh 240 600 240 200 1500 /tmp/foo.png     # custom wait + path

var body = {
  sx: parseInt(SX, 10),
  sy: parseInt(SY, 10),
  ex: parseInt(EX, 10),
  ey: parseInt(EY, 10)
};
if (typeof WAIT_MS !== "undefined" && WAIT_MS) body.wait_ms = parseInt(WAIT_MS, 10);
if (typeof PATH !== "undefined" && PATH) body.path = PATH;

var response = http.post(
  "http://127.0.0.1:7556/prime/swipe-screenshot",
  {
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  }
);

if (!response.ok) {
  throw "prime-bridge swipe-screenshot failed: HTTP " + response.status + " " + response.body;
}

output.swipeScreenshot = "ok";
