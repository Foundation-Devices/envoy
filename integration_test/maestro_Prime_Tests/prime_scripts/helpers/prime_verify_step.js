// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// One round of the Prime "Verify Seed Words" quiz: screenshot + OCR the
// "#N" prompt, look up word N in the saved seed list, tap the matching
// candidate button, then tap the bottom "Tap on Word" button.
//
// Requires prime_seeds.js (or prime-seeds.sh) to have written the saved
// list to /tmp/prime-seeds.txt earlier in the flow.
//
// How to use (call once per round; the quiz has 4 rounds):
//   - runScript:
//       file: prime_scripts/helpers/prime_verify_step.js

var BRIDGE = "http://127.0.0.1:7556/prime/verify-step";

console.log("[prime_verify_step] POST " + BRIDGE);

var response;
try {
  response = http.post(
    BRIDGE,
    { headers: { "Content-Type": "application/json" }, body: "{}" }
  );
} catch (e) {
  throw "[prime_verify_step] bridge unreachable at " + BRIDGE +
        " — is prime_bridge.sh running on port 7556?\n" +
        "         (run via ./scripts/run_maestro.sh or start it manually)\n" +
        "         raw error: " + e;
}

console.log("[prime_verify_step] HTTP " + response.status);

if (!response.ok) {
  throw "[prime_verify_step] bridge returned HTTP " + response.status +
        " — body: " + response.body +
        "\n         likely cause: screen isn't the Verify quiz (no \"#N\" found)" +
        " or saved /tmp/prime-seeds.txt is missing.";
}

output.verifyStep = "ok";
console.log("[prime_verify_step] OK");
