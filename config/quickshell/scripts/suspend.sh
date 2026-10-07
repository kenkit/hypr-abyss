#!/usr/bin/env bash
# ==============================================================================
# Suspensión Segura con Bloqueo Previo de Pantalla
# Al despertar la PC, aparecerá la pantalla de bloqueo pidiendo la contraseña
# ==============================================================================

# 1. Asegurar que hyprlock se lance con renderizado inmediato
if ! pidof hyprlock >/dev/null 2>&1; then
    hyprlock --immediate-render &
    # Esperar a que el proceso hyprlock esté listo y haya tomado el lock de sesión
    for i in {1..20}; do
        if pidof hyprlock >/dev/null 2>&1; then
            break
        fi
        sleep 0.05
    done
    sleep 0.4
fi

# 2. Suspender el sistema de forma segura
systemctl suspend
