#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Localhost HTTP bridge so Maestro `runScript` blocks (which only have
# `http.request`, no shell exec) can drive Prime via passport-drive.
#
# Mirrors the kebab_server.sh pattern, but on a different port.
# Listens on localhost:7556. Endpoints:
#
#   POST /prime/setup             — prime_driver_setup.sh
#   POST /prime/screenshot        — body: { path? }                       (also accepts GET)
#   POST /prime/tap               — body: { x, y }
#   POST /prime/swipe             — body: { sx, sy, ex, ey, steps? }
#   POST /prime/power             — power button press + release
#   POST /prime/tap-screenshot    — body: { x, y, wait_ms?, path? }
#   POST /prime/swipe-screenshot  — body: { sx, sy, ex, ey, wait_ms?, path? }
#   POST /prime/input-text        — body: { text }
#   POST /prime/close-app         — body: { pid }
#   POST /prime/tap-button        — canned (24, 760) tap (legacy alias)
#
# Run before maestro starts, kill on exit (run_maestro.sh does both).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAP_SCRIPTS_DIR="$(cd "$SCRIPT_DIR/../integration_test/maestro_Prime_Tests/prime_scripts" && pwd)"
export SCRIPT_DIR TAP_SCRIPTS_DIR

exec python3 - "$@" << 'PYEOF'
import http.server
import json
import os
import subprocess

PORT = 7556
SCRIPT_DIR = os.environ["SCRIPT_DIR"]            # envoy-dev/scripts/
TAP_SCRIPTS_DIR = os.environ["TAP_SCRIPTS_DIR"]  # …/maestro_Prime_Tests/prime_scripts/


def run(cmd):
    """Run a shell command, capture output, return (rc, stdout, stderr)."""
    proc = subprocess.run(cmd, capture_output=True, text=True)
    return proc.returncode, proc.stdout, proc.stderr


def script(name):
    """Resolve a helper shell script under prime_scripts/."""
    return os.path.join(TAP_SCRIPTS_DIR, name)


class Handler(http.server.BaseHTTPRequestHandler):
    def _reply(self, status, payload):
        body = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _read_body(self):
        n = int(self.headers.get("Content-Length") or 0)
        if n <= 0:
            return {}
        try:
            return json.loads(self.rfile.read(n).decode() or "{}")
        except json.JSONDecodeError:
            return {}

    def _exec(self, argv):
        rc, out, err = run(argv)
        self._reply(200 if rc == 0 else 500, {"rc": rc, "stdout": out, "stderr": err})

    def _route(self, method):
        path = self.path
        body = self._read_body() if method == "POST" else {}

        if path == "/prime/setup" and method == "POST":
            self._exec([os.path.join(SCRIPT_DIR, "prime_driver_setup.sh")])

        elif path == "/prime/tap-button" and method == "POST":
            self._exec([script("tap-prime-button.sh")])

        elif path == "/prime/screenshot":
            out_path = body.get("path", "/tmp/prime-bridge-shot.png")
            self._exec([script("prime-screenshot.sh"), "-o", out_path])

        elif path == "/prime/tap" and method == "POST":
            self._exec([script("prime-tap.sh"), str(body["x"]), str(body["y"])])

        elif path == "/prime/swipe" and method == "POST":
            steps = str(body.get("steps", 15))
            self._exec([
                script("prime-swipe.sh"),
                str(body["sx"]), str(body["sy"]),
                str(body["ex"]), str(body["ey"]),
                steps,
            ])

        elif path == "/prime/power" and method == "POST":
            self._exec([script("prime-power.sh")])

        elif path == "/prime/tap-screenshot" and method == "POST":
            wait_ms = str(body.get("wait_ms", 800))
            out_path = body.get("path", "/tmp/prime-bridge-shot.png")
            self._exec([
                script("prime-tap-screenshot.sh"),
                str(body["x"]), str(body["y"]),
                wait_ms, out_path,
            ])

        elif path == "/prime/swipe-screenshot" and method == "POST":
            wait_ms = str(body.get("wait_ms", 1000))
            out_path = body.get("path", "/tmp/prime-bridge-shot.png")
            self._exec([
                script("prime-swipe-screenshot.sh"),
                str(body["sx"]), str(body["sy"]),
                str(body["ex"]), str(body["ey"]),
                wait_ms, out_path,
            ])

        elif path == "/prime/input-text" and method == "POST":
            self._exec([script("prime-input-text.sh"), str(body["text"])])

        elif path == "/prime/close-app" and method == "POST":
            self._exec([script("prime-close-app.sh"), str(body["pid"])])

        else:
            self._reply(404, {"error": "not found", "path": path, "method": method})

    def do_GET(self):  self._route("GET")
    def do_POST(self): self._route("POST")

    # Quiet down default access logs; keep errors.
    def log_message(self, fmt, *args): pass


httpd = http.server.HTTPServer(("127.0.0.1", PORT), Handler)
print(f"prime-bridge listening on http://127.0.0.1:{PORT}", flush=True)
try:
    httpd.serve_forever()
except KeyboardInterrupt:
    pass
PYEOF
