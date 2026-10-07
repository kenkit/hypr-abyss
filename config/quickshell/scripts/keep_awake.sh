#!/usr/bin/env bash
# ==============================================================================
# Keep Awake (Inhibidor de Suspensión / Cafeína)
# ==============================================================================

ACTION="${1:-status}" # "toggle", "status", "start", "stop"
PID_FILE="/dev/shm/keep_awake.pid"
TIME_FILE="/dev/shm/keep_awake.time"

is_active() {
    if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
        return 0
    fi
    return 1
}

start_awake() {
    if is_active; then return; fi
    nohup systemd-inhibit --what=idle:sleep --who="ControlCenter" --why="Keep_Awake" sleep infinity </dev/null >/dev/null 2>&1 &
    local pid=$!
    disown "$pid" 2>/dev/null
    echo "$pid" > "$PID_FILE"
    date +"%I:%M %p" > "$TIME_FILE"
    notify-send -u normal -a "Control Center" -i preferences-desktop-screensaver "Keep Awake Activado" "Suspensión bloqueada"
}

stop_awake() {
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null)
        if [[ -n "$pid" ]]; then
            kill -TERM "$pid" 2>/dev/null
            kill -9 "$pid" 2>/dev/null
        fi
    fi
    pkill -f "why=Keep_Awake" 2>/dev/null
    rm -f "$PID_FILE" "$TIME_FILE"
    notify-send -u normal -a "Control Center" -i preferences-desktop-screensaver "Keep Awake Desactivado" "Suspensión restaurada"
}

case "$ACTION" in
    "toggle")
        if is_active; then
            stop_awake
        else
            start_awake
        fi
        ;;
    "start")
        start_awake
        ;;
    "stop")
        stop_awake
        ;;
    "status")
        ;;
esac

if is_active; then
    st_time=$(cat "$TIME_FILE" 2>/dev/null)
    printf '{"active": true, "since": "%s"}\n' "${st_time:-Hoy}"
else
    printf '{"active": false, "since": ""}\n'
fi
