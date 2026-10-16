#!/usr/bin/env bash
# ==============================================================================
# Reproductor de Sonido para Notificaciones (con soporte para Silenciar / DND)
# ==============================================================================

# 1. Si las notificaciones están silenciadas o en modo No Molestar, salir de inmediato
if [[ -f /dev/shm/notif_muted || -f /dev/shm/dnd_active ]]; then
    exit 0
fi

is_paused=$(dunstctl is-paused 2>/dev/null)
if [[ "$is_paused" == "true" ]]; then
    exit 0
fi

# 2. Ignorar notificaciones que ya tienen su propio audio o son OSD (Volumen, Brillo, Captura, Grabador)
appname="$1"
if [[ "$appname" == "Captura" || "$appname" == "Grabador" || "$appname" == "Volume" || "$appname" == "Volumen" || "$appname" == "Brightness" || "$appname" == "Brillo" ]]; then
    exit 0
fi

# 3. Anti-spam / Rate-limit para evitar repeticiones masivas cuando se despausan
last_play_file="/dev/shm/last_notif_sound"
now=$(date +%s%3N 2>/dev/null || date +%s)
if [[ -f "$last_play_file" ]]; then
    last_time=$(cat "$last_play_file" 2>/dev/null || echo 0)
    diff=$(( now - last_time ))
    if (( diff > 0 && diff < 500 )); then
        exit 0
    fi
fi
echo "$now" > "$last_play_file"

# 4. Reproducir sonido de notificación
sound_file="/usr/share/sounds/freedesktop/stereo/message-new-instant.oga"
if [[ ! -f "$sound_file" ]]; then
    sound_file="$HOME/.local/share/sounds/freedesktop/stereo/message-new-instant.oga"
fi

if [[ -f "$sound_file" ]]; then
    if command -v paplay >/dev/null 2>&1; then
        paplay "$sound_file" 2>/dev/null &
    elif command -v pw-play >/dev/null 2>&1; then
        pw-play "$sound_file" 2>/dev/null &
    fi
fi
