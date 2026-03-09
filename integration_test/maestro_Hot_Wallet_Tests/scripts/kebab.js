// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Sends a command to the Kebab rig via the HTTP bridge.
//
// Available commands:
//   home               - Home stepper motors to initial position
//   iphone_scan_prime  - Position so iPhone can scan Prime QR code
//   prime_scan_iphone  - Position so Prime can scan iPhone QR code
//   face_tester_1      - Face devices toward tester position 1 (left)
//   face_tester_2      - Face devices toward tester position 2 (right)
//   disable_motors     - Disable all stepper motors (allows manual movement)
//
// Usage in a Maestro flow:
//
//   - runScript:
//       file: scripts/kebab.js
//       env:
//         KEBAB_COMMAND: "home"

var command = KEBAB_COMMAND;
if (!command) {
    throw 'KEBAB_COMMAND env var is required';
}

var response = http.get('http://localhost:5555/' + command);

if (response.status !== 200) {
    throw 'Kebab command "' + command + '" failed: ' + response.body;
}
