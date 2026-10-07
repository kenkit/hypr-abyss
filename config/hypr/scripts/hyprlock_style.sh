#!/usr/bin/env bash
# ==============================================================================
# Selector de Estilos de Hyprlock (Dolphin-Hyprland)
# ==============================================================================

themes="$HOME/.config/hypr/lockscreens"
destination="$HOME/.config/hypr/hyprlock.conf"

set_lockscreen() {
    local theme=$1
    ln -sf "$theme" "$destination"
    notify-send "Hyprlock" "Tema cambiado a: $(basename "$theme" .conf)" -i dialog-information 2>/dev/null
}

if command -v rofi >/dev/null 2>&1; then
    choice=$(printf "Style-1\nStyle-2\nStyle-3" | rofi -dmenu -p "Seleccionar Estilo Hyprlock")
else
    choice="$1"
fi

case "$choice" in
    Style-1|1)
        set_lockscreen "$themes/hyprlock-1.conf"
        ;;
    Style-2|2)
        set_lockscreen "$themes/hyprlock-2.conf"
        ;;
    Style-3|3)
        set_lockscreen "$themes/hyprlock-3.conf"
        ;;
esac
