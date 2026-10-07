#!/usr/bin/env bash
ACTION="${1:-toggle}"

if [[ "$ACTION" == "toggle" ]]; then
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
fi

raw=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
# Output example: Volume: 1.00 [MUTED] or Volume: 0.85
muted=false
if echo "$raw" | grep -q "\[MUTED\]"; then
    muted=true
fi
vol=$(echo "$raw" | awk '{print int($2 * 100)}')
vol=${vol:-100}

echo "{\"muted\": $muted, \"volume\": $vol}"
