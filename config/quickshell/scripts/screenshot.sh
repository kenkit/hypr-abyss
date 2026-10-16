#!/usr/bin/env bash
# ==============================================================================
# Captura de Pantalla Profesional con Sonido y Notificación
# ==============================================================================

exec >>/tmp/screenshot.log 2>&1
export PATH="$HOME/.local/bin:$PATH"

MODE="${1:-region}" # "region" o "fullscreen"
PICS_DIR=$(xdg-user-dir PICTURES 2>/dev/null)
if [[ -z "$PICS_DIR" || ! -d "$PICS_DIR" ]]; then
    PICS_DIR="$HOME/Pictures"
fi
DIR="$PICS_DIR/Screenshots"
mkdir -p "$DIR"

echo "[$(date)] Captura iniciada con modo: $MODE"

# Cierra el Centro de Control para no obstaculizar la captura y espera a que el compositor libere el foco
quickshell ipc call controlcenter close 2>/dev/null
sleep 0.35

FILE="$DIR/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

if [[ "$MODE" == "fullscreen" ]]; then
    grim "$FILE"
else
    geo=$(slurp 2>&1)
    slurp_exit=$?
    echo "[$(date)] Slurp exit code: $slurp_exit, geometry: '$geo'"
    if [[ $slurp_exit -ne 0 || -z "$geo" ]]; then
        echo "[$(date)] Selección cancelada por el usuario"
        notify-send -u low -a "Screenshot" -t 2000 "Screenshot Cancelled" "No area was selected"
        exit 0
    fi
    grim -g "$geo" "$FILE"
fi

if [[ -f "$FILE" ]]; then
    echo "[$(date)] Captura creada exitosamente: $FILE"
    wl-copy < "$FILE"
    
    # Reproducir sonido de obturador de cámara si no está silenciado
    if [[ ! -f /dev/shm/notif_muted && ! -f /dev/shm/dnd_active ]]; then
        SOUND_FILE="/usr/share/sounds/freedesktop/stereo/camera-shutter.oga"
        if [[ ! -f "$SOUND_FILE" ]]; then
            SOUND_FILE="$HOME/.local/share/sounds/freedesktop/stereo/camera-shutter.oga"
        fi
        
        if command -v paplay >/dev/null 2>&1; then
            paplay "$SOUND_FILE" &
        elif command -v pw-play >/dev/null 2>&1; then
            pw-play "$SOUND_FILE" &
        fi
    fi

    notify-send -u normal -a "Screenshot" -i "$FILE" "Screenshot Saved" "Copied to clipboard and saved to $(basename "$DIR")\n$(basename "$FILE")"
    
    # Pequeña pausa para permitir que el reproductor de sonido finalice
    sleep 0.25
else
    echo "[$(date)] Error: No se pudo generar el archivo $FILE"
fi
