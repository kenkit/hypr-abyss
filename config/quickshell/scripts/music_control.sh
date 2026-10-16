#!/bin/bash
ACTION="$1"
VALUE="$2"
SOCK="/tmp/kiss_music_mpv.sock"

if [ "$ACTION" = "quit" ]; then
    echo "{\"command\": [\"quit\"]}" | socat - "$SOCK" 2>/dev/null
    pkill -f "music_play.sh" 2>/dev/null
    sleep 0.05
    pkill -9 -f "$SOCK" 2>/dev/null
    rm -f "$SOCK" 2>/dev/null
    exit 0
fi

if [ ! -S "$SOCK" ]; then
    exit 0
fi

case "$ACTION" in
    seek)
        echo "{\"command\": [\"seek\", $VALUE, \"relative\"]}" | socat - "$SOCK" 2>/dev/null
        ;;
    volume)
        echo "{\"command\": [\"set_property\", \"volume\", $VALUE]}" | socat - "$SOCK" 2>/dev/null
        ;;
    toggle)
        echo "{\"command\": [\"cycle\", \"pause\"]}" | socat - "$SOCK" 2>/dev/null
        ;;
    stop)
        echo "{\"command\": [\"stop\"]}" | socat - "$SOCK" 2>/dev/null
        ;;
    quit)
        echo "{\"command\": [\"quit\"]}" | socat - "$SOCK" 2>/dev/null
        pkill -f "/tmp/kiss_music_mpv.sock" 2>/dev/null
        rm -f "$SOCK" 2>/dev/null
        ;;
esac
