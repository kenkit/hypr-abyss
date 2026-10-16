#!/usr/bin/env bash
# ==============================================================================
# Bluetooth Power Toggle Script for Quickshell
# Alterna el encendido y apagado de Bluetooth mediante bluetoothctl y rfkill
# ==============================================================================

ACTION="$1" # "on", "off", o vacío (toggle)

is_powered() {
    bluetoothctl show 2>/dev/null | grep -q "Powered: yes"
}

if [[ "$ACTION" == "off" ]] || { [[ -z "$ACTION" || "$ACTION" == "toggle" ]] && is_powered; }; then
    bluetoothctl power off >/dev/null 2>&1
    notify-send -u low -a "Bluetooth" -i bluetooth-disabled "Bluetooth" "Disabled" 2>/dev/null
else
    # Asegurar que rfkill no bloquee la interfaz (especialmente en portátiles)
    rfkill unblock bluetooth 2>/dev/null
    sleep 0.1
    bluetoothctl power on >/dev/null 2>&1
    bluetoothctl pairable on >/dev/null 2>&1
    # Pequeño retardo para asegurar que BlueZ reporte Powered: yes antes de que termine el proceso
    sleep 0.2
    notify-send -u low -a "Bluetooth" -i bluetooth "Bluetooth" "Enabled" 2>/dev/null
fi
