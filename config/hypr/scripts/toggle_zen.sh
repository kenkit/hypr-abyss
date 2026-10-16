#!/usr/bin/env bash

# Si la ventana de Zen Browser no existe en ningún espacio
if ! hyprctl clients | grep -qiE "class:.*(zen|Navigator)"; then
    zen-browser &
    # Esperar hasta que Hyprland registre la ventana (máximo 4 segundos)
    for i in {1..40}; do
        if hyprctl clients | grep -qiE "class:.*(zen|Navigator)"; then
            break
        fi
        sleep 0.1
    done
fi

# Alternar la visualización del scratchpad especial del navegador
hyprctl dispatch togglespecialworkspace browser
