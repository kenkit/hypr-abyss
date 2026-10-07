#!/usr/bin/env bash
# ==============================================================================
# Helper para widget de batería en Hyprlock
# ==============================================================================

bat_dir="/sys/class/power_supply"
bat=$(ls "$bat_dir" 2>/dev/null | grep -E "^(BAT|battery)" | head -n 1)

if [[ -n "$bat" && -f "$bat_dir/$bat/capacity" ]]; then
    cap=$(cat "$bat_dir/$bat/capacity" 2>/dev/null || echo "100")
    status=$(cat "$bat_dir/$bat/status" 2>/dev/null || echo "Discharging")
    
    icon="󰁹"
    if [[ "$status" == "Charging" ]]; then
        icon="󰂄"
    elif [[ "$cap" -le 20 ]]; then
        icon="󰁺"
    elif [[ "$cap" -le 40 ]]; then
        icon="󰁼"
    elif [[ "$cap" -le 60 ]]; then
        icon="󰁾"
    elif [[ "$cap" -le 80 ]]; then
        icon="󰂀"
    fi
    echo "$icon  $cap%"
else
    echo "󰚥  AC"
fi
