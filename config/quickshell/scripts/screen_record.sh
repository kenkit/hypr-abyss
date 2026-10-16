#!/usr/bin/env bash
# ==============================================================================
# Controlador de Grabación de Pantalla (wf-recorder con Audio Mixto y AAC)
# ==============================================================================

export PATH="$HOME/.local/bin:$PATH"

ACTION="${1:-toggle}" # "toggle", "start_full", "start_region", "stop", "status", "list"
MODE="${2:-fullscreen}"

PID_FILE="/dev/shm/wf_recorder.pid"
AUDIO_MODS_FILE="/dev/shm/wf_recorder_audio_modules"
REC_DIR=$(xdg-user-dir VIDEOS 2>/dev/null)
if [[ -z "$REC_DIR" || ! -d "$REC_DIR" ]]; then
    REC_DIR="$HOME/Videos"
fi
mkdir -p "$REC_DIR"

is_recording() {
    if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
        return 0
    fi
    return 1
}

cleanup_audio() {
    if [[ -f "$AUDIO_MODS_FILE" ]]; then
        local mods
        mods=$(cat "$AUDIO_MODS_FILE" 2>/dev/null)
        rm -f "$AUDIO_MODS_FILE"
        for m in $mods; do
            pactl unload-module "$m" 2>/dev/null || true
        done
    fi
}

setup_audio() {
    cleanup_audio
    local def_sink def_source
    def_sink=$(pactl get-default-sink 2>/dev/null)
    def_source=$(pactl get-default-source 2>/dev/null)

    local mix_sink
    mix_sink=$(pactl load-module module-null-sink sink_name=qs_record_mix sink_properties=device.description=QuickshellRecordMix 2>/dev/null)
    if [[ -n "$mix_sink" ]]; then
        local lb1 lb2
        lb1=$(pactl load-module module-loopback source="${def_sink}.monitor" sink=qs_record_mix latency_msec=20 2>/dev/null)
        lb2=""
        if [[ -n "$def_source" ]]; then
            lb2=$(pactl load-module module-loopback source="$def_source" sink=qs_record_mix latency_msec=20 2>/dev/null)
        fi
        echo "$mix_sink $lb1 $lb2" > "$AUDIO_MODS_FILE"
        AUDIO_OPTS=(--audio=qs_record_mix.monitor)
    elif [[ -n "$def_sink" ]]; then
        AUDIO_OPTS=(--audio="${def_sink}.monitor")
    else
        AUDIO_OPTS=(-a)
    fi
}

start_recording() {
    if is_recording; then
        return
    fi
    
    local RECORDER="$HOME/.local/bin/wf-recorder"
    if ! command -v "$RECORDER" >/dev/null 2>&1; then
        RECORDER="wf-recorder"
    fi

    local out_file="$REC_DIR/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"
    echo "$out_file" > "/dev/shm/wf_recorder_current"

    # Cierra el Centro de Control para liberar el área y no estorbar la grabación
    quickshell ipc call controlcenter close 2>/dev/null
    sleep 0.35

    if [[ "$MODE" == "region" ]]; then
        local geo
        geo=$(slurp 2>/dev/null)
        if [[ -z "$geo" ]]; then
            rm -f "/dev/shm/wf_recorder_current"
            return
        fi
        setup_audio
        nohup "$RECORDER" "${AUDIO_OPTS[@]}" -C aac -g "$geo" -f "$out_file" </dev/null >/tmp/wf_recorder.log 2>&1 &
    else
        setup_audio
        nohup "$RECORDER" "${AUDIO_OPTS[@]}" -C aac -f "$out_file" </dev/null >/tmp/wf_recorder.log 2>&1 &
    fi

    local pid=$!
    disown "$pid" 2>/dev/null
    echo "$pid" > "$PID_FILE"
    notify-send -u normal -a "Screen Recorder" -i media-record "Recording Started" "Mode: $MODE\nSaving to $(basename "$REC_DIR")"
    if [[ ! -f /dev/shm/notif_muted && ! -f /dev/shm/dnd_active ]]; then
        pw-play "$HOME/.local/share/sounds/freedesktop/stereo/camera-shutter.oga" 2>/dev/null &
    fi
}

stop_recording() {
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null)
        if [[ -n "$pid" ]]; then
            kill -INT "$pid" 2>/dev/null
        fi
        rm -f "$PID_FILE"
        cleanup_audio
        sleep 0.8
        local cur_file
        cur_file=$(cat "/dev/shm/wf_recorder_current" 2>/dev/null)
        rm -f "/dev/shm/wf_recorder_current"
        notify-send -u normal -a "Screen Recorder" -i video-x-generic "Recording Finished" "$(basename "${cur_file:-Recording}")"
        if [[ ! -f /dev/shm/notif_muted && ! -f /dev/shm/dnd_active ]]; then
            pw-play "$HOME/.local/share/sounds/freedesktop/stereo/complete.oga" 2>/dev/null &
        fi
    else
        pkill -INT -f wf-recorder 2>/dev/null
        cleanup_audio
    fi
}

case "$ACTION" in
    "toggle")
        if is_recording; then
            stop_recording
        else
            start_recording
        fi
        ;;
    "start_full")
        MODE="fullscreen"
        start_recording
        ;;
    "start_region")
        MODE="region"
        start_recording
        ;;
    "stop")
        stop_recording
        ;;
    "status")
        if is_recording; then
            cur=$(cat "/dev/shm/wf_recorder_current" 2>/dev/null)
            echo "{\"recording\": true, \"file\": \"$(basename "$cur")\"}"
        else
            echo '{"recording": false, "file": ""}'
        fi
        ;;
    "list")
        python3 -c "
import glob, os, json
files = glob.glob(os.path.expanduser('~/Vídeos/*.mp4'))
files.sort(key=os.path.getmtime, reverse=True)
res = []
for f in files[:5]:
    res.append({
        'name': os.path.basename(f),
        'path': f,
        'size': f'{os.path.getsize(f) / (1024*1024):.1f} MB'
    })
print(json.dumps(res))
"
        ;;
esac
