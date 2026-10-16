#!/usr/bin/env bash

# 1. Cerrar Quickshell de inmediato
killall quickshell 2>/dev/null

# 2. Despachar la salida nativa de Hyprland
hyprctl dispatch exit 2>/dev/null || loginctl terminate-user "$USER" 2>/dev/null || pkill -KILL -u "$USER"
