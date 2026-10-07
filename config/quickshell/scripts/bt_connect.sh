#!/usr/bin/env bash
MAC="$1"
ACTION="$2" # "connect" o "disconnect" o "toggle"

if [[ -z "$MAC" ]]; then
    exit 1
fi

info=$(bluetoothctl info "$MAC" 2>/dev/null)
if echo "$info" | grep -q "Connected: yes"; then
    bluetoothctl disconnect "$MAC"
    notify-send -u normal -a "Bluetooth" -i bluetooth "Bluetooth Desconectado" "$MAC"
else
    bluetoothctl connect "$MAC"
    notify-send -u normal -a "Bluetooth" -i bluetooth "Bluetooth Conectado" "$MAC"
fi
