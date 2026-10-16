#!/usr/bin/env bash
# ==============================================================================
# Bluetooth Connect / Disconnect / Pair Helper for Quickshell
# Permite conectar, desconectar y emparejar dispositivos Bluetooth
# ==============================================================================
MAC="$1"
ACTION="$2" # "connect", "disconnect", o vacío (toggle)

if [[ -z "$MAC" ]]; then
    exit 1
fi

# Obtener nombre amigable para la notificación
name=$(bluetoothctl info "$MAC" 2>/dev/null | awk -F": " '/Name:/ {print $2; exit}')
if [[ -z "$name" ]]; then
    name=$(bluetoothctl devices 2>/dev/null | grep "$MAC" | cut -d' ' -f3-)
fi
name=${name:-"$MAC"}

info=$(bluetoothctl info "$MAC" 2>/dev/null)
is_connected="no"
if echo "$info" | grep -q "Connected: yes"; then
    is_connected="yes"
fi

is_paired="no"
if echo "$info" | grep -q "Paired: yes"; then
    is_paired="yes"
fi

if [[ "$ACTION" == "disconnect" ]] || [[ "$is_connected" == "yes" && "$ACTION" != "connect" ]]; then
    bluetoothctl disconnect "$MAC" >/dev/null 2>&1
    notify-send -u normal -a "Bluetooth" -i bluetooth "Bluetooth Disconnected" "$name" 2>/dev/null
else
    # Si el dispositivo aún no está emparejado, permitir emparejamiento y confiar
    if [[ "$is_paired" != "yes" ]]; then
        bluetoothctl pairable on >/dev/null 2>&1
        bluetoothctl trust "$MAC" >/dev/null 2>&1
        bluetoothctl pair "$MAC" >/dev/null 2>&1
    fi

    # Intentar conexión
    bluetoothctl trust "$MAC" >/dev/null 2>&1
    bluetoothctl connect "$MAC" >/dev/null 2>&1
    
    # Verificar si quedó conectado
    sleep 0.5
    if bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"; then
        notify-send -u normal -a "Bluetooth" -i bluetooth "Bluetooth Connected" "$name" 2>/dev/null
    else
        notify-send -u normal -a "Bluetooth" -i dialog-error "Connection Failed" "Could not connect to $name" 2>/dev/null
    fi
fi
