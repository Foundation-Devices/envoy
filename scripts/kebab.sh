#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Send commands to the Kebab rig via MQTT.
# Usage: ./scripts/kebab.sh <command>
#
# Commands:
#   home                 Home stepper motors to initial position
#   iphone_scan_prime    Position so iPhone can scan Prime QR code
#   prime_scan_iphone    Position so Prime can scan iPhone QR code
#   face_tester_1        Face devices toward tester position 1 (left)
#   face_tester_2        Face devices toward tester position 2 (right)
#   disable_motors       Disable all stepper motors (allows manual movement)

set -euo pipefail

MQTT_HOST="localhost"
MQTT_PORT="1235"
MQTT_TOPIC="kebab/command"

VALID_COMMANDS=(
    home
    iphone_scan_prime
    prime_scan_iphone
    face_tester_1
    face_tester_2
    disable_motors
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    for cmd in "${VALID_COMMANDS[@]}"; do
        echo "  $cmd"
    done
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

COMMAND="$1"

# Validate command
VALID=false
for cmd in "${VALID_COMMANDS[@]}"; do
    if [ "$COMMAND" = "$cmd" ]; then
        VALID=true
        break
    fi
done

if [ "$VALID" = false ]; then
    echo -e "${RED}Error: Unknown command '$COMMAND'${NC}"
    echo ""
    usage
fi

# Check for mosquitto_pub
if ! command -v mosquitto_pub >/dev/null 2>&1; then
    echo -e "${RED}Error: mosquitto_pub not found${NC}"
    echo -e "Install with: ${YELLOW}brew install mosquitto${NC}"
    exit 1
fi

echo -e "${YELLOW}Sending '$COMMAND' to Kebab rig...${NC}"

if mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -t "$MQTT_TOPIC" -m "$COMMAND"; then
    echo -e "${GREEN}Done.${NC}"
else
    echo -e "${RED}Failed to send command. Check MQTT broker connection.${NC}"
    exit 1
fi
