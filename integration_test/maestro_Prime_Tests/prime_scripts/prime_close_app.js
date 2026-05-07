// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Gracefully close an app on Prime by PID via gui-server.
//
// How to use
//   From Maestro YAML:
//     - runScript:
//         file: prime_scripts/prime_close_app.js
//         env:
//           PID: "40"
//
//   From shell (via prime-close-app.sh):
//     ./prime-close-app.sh 40

var response = http.post(
  "http://127.0.0.1:7556/prime/close-app",
  {
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ pid: parseInt(PID, 10) })
  }
);

if (!response.ok) {
  throw "prime-bridge close-app failed: HTTP " + response.status + " " + response.body;
}

output.closeApp = "ok";
