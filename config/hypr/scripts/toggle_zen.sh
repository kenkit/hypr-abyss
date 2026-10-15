#!/usr/bin/env bash

# Nombre de la clase de la ventana (Zen Browser suele identificarse como zen, zen-alpha o Navigator)
APP_CLASS="zen"
SPECIAL_WS="special:browser"

# Si la ventana no existe, la iniciamos y la movemos al scratchpad
if ! hyprctl clients | grep -qiE "class:.*(zen|Navigator)"; then
    zen-browser &
    # Esperar brevemente a que cree la ventana
    sleep 0.6
    hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS",class:"(?i)(zen|Navigator)"
    hyprctl dispatch togglespecialworkspace browser
else
    # Si ya existe, simplemente alternar su visualización
    hyprctl dispatch togglespecialworkspace browser
fi
