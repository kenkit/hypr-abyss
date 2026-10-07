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
    notify-send -u normal -a "WiFi" -i network-wireless "WiFi Conectado" "Conexión exitosa a $SSID"
    echo '{"success": true, "message": "Conectado a '"$SSID"'"}'
else
    notify-send -u critical -a "WiFi" -i network-wireless-offline "Error de WiFi" "$res"
    echo '{"success": false, "message": "'"$res"'"}'
fi
