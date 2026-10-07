#!/usr/bin/env bash
# ==============================================================================
# Bluetooth Power Toggle Script for Quickshell Dynamic Island
# Alterna el encendido y apagado de Bluetooth mediante bluetoothctl
# ==============================================================================

if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    bluetoothctl power off
else
    bluetoothctl power on
fi
