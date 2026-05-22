// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// OCR the 12 BIP-39 words off the Prime "Seed Words" screen and expose them
// as Maestro variables.
//
// Sets:
//   output.seed_1 .. output.seed_12   (individual words; usable as ${output.seed_1})
//
// How to use
//   From Maestro YAML:
//     - runScript:
//         file: prime_scripts/helpers/prime_seeds.js
//
// Requires the Prime to be displaying the Seed Words screen (12 words in a 2×6 grid).

var BRIDGE = "http://127.0.0.1:7556/prime/seeds";

console.log("[prime_seeds] POST " + BRIDGE);

var response;
try {
  response = http.post(
    BRIDGE,
    { headers: { "Content-Type": "application/json" }, body: "{}" }
  );
} catch (e) {
  throw "[prime_seeds] bridge unreachable at " + BRIDGE +
        " — is prime_bridge.sh running on port 7556?\n" +
        "         (run via ./scripts/run_maestro.sh or start it manually)\n" +
        "         raw error: " + e;
}

console.log("[prime_seeds] HTTP " + response.status + " (" +
            (response.body ? response.body.length : 0) + " bytes)");

if (!response.ok) {
  throw "[prime_seeds] bridge returned HTTP " + response.status +
        " — body: " + response.body;
}

var data;
try {
  data = JSON.parse(response.body);
} catch (e) {
  throw "[prime_seeds] could not parse bridge JSON: " + response.body;
}

if (!data.words || data.words.length !== 12) {
  throw "[prime_seeds] expected 12 words, got " +
        (data.words ? data.words.length : 0) +
        " — is the Prime actually on the Seed Words screen?\n" +
        "         bridge stderr: " + (data.stderr || "(empty)");
}

for (var i = 0; i < 12; i++) {
  output["seed_" + (i + 1)] = data.words[i];
}

console.log("[prime_seeds] OK — 12 words captured (first=" + data.words[0] +
            ", last=" + data.words[11] + ")");
