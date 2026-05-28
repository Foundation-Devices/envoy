// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Type text into Prime's currently focused input field.
//
// How to use
//   From Maestro YAML:
//     - runScript:
//         file: prime_scripts/interactions/prime_input_text.js
//         env:
//           TEXT: "hello world"

var response = http.post(
  "http://127.0.0.1:7556/prime/input-text",
  {
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ text: TEXT })
  }
);

if (!response.ok) {
  throw "prime-bridge input-text failed: HTTP " + response.status + " " + response.body;
}

output.inputText = "ok";
