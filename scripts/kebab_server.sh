#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Lightweight HTTP-to-MQTT bridge for the Kebab rig.
# Listens on localhost:7555 and forwards commands to MQTT using a persistent
# connection (paho-mqtt), matching the kebab MCP server's approach.
# Start before running Maestro tests, stop after.
#
# Requires: pip3 install paho-mqtt
#
# Usage:
#   ./scripts/kebab_server.sh        # foreground
#   ./scripts/kebab_server.sh &      # background
#   curl http://localhost:7555/home   # send a command

set -euo pipefail

exec python3 - "$@" << 'PYEOF'
import http.server
import json
import sys
import time
from datetime import datetime

import paho.mqtt.client as mqtt

PORT = 7555
MQTT_HOST = "127.0.0.1"
MQTT_PORT = 1235
MQTT_TOPIC = "kebab/command"
MQTT_QOS = 1  # AtLeastOnce, matches the Dart MCP client

VALID_COMMANDS = {
    "home", "iphone_scan_prime", "prime_scan_iphone",
    "face_tester_1", "face_tester_2", "disable_motors", "wake",
}

# --- Persistent MQTT connection ---

mqtt_connected = False

def on_connect(client, userdata, flags, reason_code, properties=None):
    global mqtt_connected
    mqtt_connected = (reason_code == 0)
    status = "connected" if mqtt_connected else f"failed ({reason_code})"
    print(f"MQTT {status} to {MQTT_HOST}:{MQTT_PORT}")
    sys.stdout.flush()

def on_disconnect(client, userdata, flags, reason_code, properties=None):
    global mqtt_connected
    mqtt_connected = False
    print(f"MQTT disconnected (rc={reason_code}), will auto-reconnect", file=sys.stderr)
    sys.stderr.flush()

mqtt_client = mqtt.Client(
    callback_api_version=mqtt.CallbackAPIVersion.VERSION2,
    client_id=f"kebab-http-bridge-{int(time.time() * 1000)}",
    clean_session=True,
)
mqtt_client.on_connect = on_connect
mqtt_client.on_disconnect = on_disconnect
mqtt_client.reconnect_delay_set(min_delay=1, max_delay=10)

print(f"Connecting to MQTT broker at {MQTT_HOST}:{MQTT_PORT}...")
sys.stdout.flush()
try:
    mqtt_client.connect(MQTT_HOST, MQTT_PORT, keepalive=30)
    mqtt_client.loop_start()
except Exception as e:
    print(f"Error: Could not connect to MQTT broker: {e}", file=sys.stderr)
    sys.exit(1)

# --- HTTP server ---

class KebabHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        command = self.path.lstrip("/")
        ts = datetime.now().strftime("%H:%M:%S")

        if command not in VALID_COMMANDS:
            self._respond(400, {"ok": False, "error": "unknown_command", "command": command})
            print(f"[{ts}] Unknown command: {command}", file=sys.stderr)
            return

        if not mqtt_connected:
            self._respond(502, {"ok": False, "error": "mqtt_not_connected"})
            print(f"[{ts}] {command} -> MQTT not connected", file=sys.stderr)
            return

        result = mqtt_client.publish(MQTT_TOPIC, command, qos=MQTT_QOS)
        result.wait_for_publish(timeout=5)

        if result.rc == mqtt.MQTT_ERR_SUCCESS:
            self._respond(200, {"ok": True, "command": command})
            print(f"[{ts}] {command} -> OK")
        else:
            self._respond(502, {"ok": False, "error": "mqtt_publish_failed"})
            print(f"[{ts}] {command} -> publish failed (rc={result.rc})", file=sys.stderr)

        sys.stdout.flush()
        sys.stderr.flush()

    def _respond(self, status, body):
        data = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", len(data))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, format, *args):
        pass  # suppress default access logs

server = http.server.HTTPServer(("127.0.0.1", PORT), KebabHandler)
print(f"Kebab HTTP bridge listening on http://localhost:{PORT}")
print(f"Commands: {', '.join(sorted(VALID_COMMANDS))}")
print("Press Ctrl+C to stop.")
sys.stdout.flush()

try:
    server.serve_forever()
except KeyboardInterrupt:
    print("\nStopping...")
    mqtt_client.loop_stop()
    mqtt_client.disconnect()
    server.server_close()
    print("Stopped.")
PYEOF
