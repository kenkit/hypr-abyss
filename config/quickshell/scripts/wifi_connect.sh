#!/usr/bin/env bash
# ==============================================================================
# Conecta a una red WiFi mediante nmcli
# ==============================================================================

SSID="$1"
PASS="$2"

if [[ -z "$SSID" ]]; then
    exit 1
fi

if [[ -n "$PASS" ]]; then
    res=$(nmcli dev wifi connect "$SSID" password "$PASS" 2>&1)
else
    res=$(nmcli dev wifi connect "$SSID" 2>&1)
fi

status=$?
if [[ $status -eq 0 ]]; then
    notify-send -u normal -a "WiFi" -i network-wireless "WiFi Connected" "Connected to $SSID"
    echo '{"success": true, "message": "Connected to '"$SSID"'"}'
else
    notify-send -u critical -a "WiFi" -i network-wireless-offline "WiFi Connection Failed" "$res"
    echo '{"success": false, "message": "'"$res"'"}'
fi
