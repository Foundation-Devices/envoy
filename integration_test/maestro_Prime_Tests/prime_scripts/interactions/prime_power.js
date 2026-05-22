// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Press + release Prime's power button.
//
// How to use
//   From Maestro YAML:
//     - runScript: prime_scripts/interactions/prime_power.js
//
//   From shell (via prime-power.sh):
//     ./prime-power.sh

var response = http.post(
  "http://127.0.0.1:7556/prime/power",
  {
    headers: { "Content-Type": "application/json" },
    body: "{}"
  }
);

if (!response.ok) {
  throw "prime-bridge power failed: HTTP " + response.status + " " + response.body;
}

output.power = "ok";
