#!/usr/bin/env bash
# ==============================================================================
# Script de Bloqueo de Pantalla para Hyprland / Quickshell
# ==============================================================================

if command -v hyprlock >/dev/null 2>&1; then
    pidof hyprlock >/dev/null 2>&1 || hyprlock --immediate-render
elif command -v swaylock >/dev/null 2>&1; then
    pidof swaylock >/dev/null 2>&1 || swaylock -f -c 0d1117
elif command -v gtklock >/dev/null 2>&1; then
    pidof gtklock >/dev/null 2>&1 || gtklock
else
    loginctl lock-session
fi
