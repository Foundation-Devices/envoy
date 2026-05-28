// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Screenshot the Prime, OCR it, and assert that a given text appears on
// the screen. Maestro analogue of `assertVisible:` for the Prime, since
// Maestro can't see Prime's UI tree directly.
//
// Polls every second up to TIMEOUT_S so transient/animation screens don't
// false-fail. Defaults to substring matching; set REGEX="1" for full regex.
//
// How to use
//   - runScript:
//       file: prime_scripts/helpers/prime_assert_visible.js
//       env:
//         TEXT: "Create PIN"
//
//   - runScript:
//       file: prime_scripts/helpers/prime_assert_visible.js
//       env:
//         TEXT: "Word #[0-9]+"
//         REGEX: "1"
//         TIMEOUT_S: "10"

var BRIDGE = "http://127.0.0.1:7556/prime/assert-visible";

if (typeof TEXT !== "string" || TEXT === "") {
  throw "[prime_assert_visible] required env var TEXT is missing or empty";
}

var body = { text: TEXT };
if (typeof REGEX === "string" && REGEX !== "" && REGEX !== "0") {
  body.regex = true;
}
if (typeof TIMEOUT_S === "string" && TIMEOUT_S !== "") {
  body.timeout_s = parseInt(TIMEOUT_S, 10);
}

console.log("[prime_assert_visible] POST " + BRIDGE +
            " — looking for \"" + TEXT + "\"" +
            (body.regex ? " (regex)" : "") +
            (body.timeout_s ? " timeout=" + body.timeout_s + "s" : ""));

var response;
try {
  response = http.post(
    BRIDGE,
    { headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) }
  );
} catch (e) {
  throw "[prime_assert_visible] bridge unreachable at " + BRIDGE +
        " — is prime_bridge.sh running on port 7556?\n" +
        "         raw error: " + e;
}

if (!response.ok) {
  // The bridge wraps the helper's stderr in JSON; surface it so the failure
  // includes the OCR dump from the last attempted screenshot.
  var info = response.body;
  try {
    var parsed = JSON.parse(response.body);
    info = (parsed.stderr || parsed.stdout || response.body);
  } catch (e) { /* keep raw */ }
  throw "[prime_assert_visible] \"" + TEXT + "\" NOT visible on Prime.\n" +
        "         " + info;
}

console.log("[prime_assert_visible] OK");
output.assertVisible = "ok";
