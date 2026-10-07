#!/usr/bin/env bash

# 1. Cerrar Quickshell de inmediato
killall quickshell 2>/dev/null

# 2. Despachar la salida nativa de Hyprland (Sintaxis Lua de Hyprland 0.56+)
hyprctl dispatch 'hl.dsp.exit()'
