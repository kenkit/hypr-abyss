#!/usr/bin/env bash
# ==============================================================================
# Helper para widget de música en Hyprlock
# Se oculta totalmente si no hay música o si está en pausa.
# Muestra un círculo giratorio continuo sincronizado con la reproducción.
# ==============================================================================

# Si playerctl no está instalado o no hay ningún reproductor activo, no mostrar nada
if ! command -v playerctl >/dev/null 2>&1; then
    exit 0
fi

status=$(playerctl status 2>/dev/null)

# Solo mostrar cuando la música esté activamente reproduciéndose ("Playing")
if [[ "$status" != "Playing" ]]; then
    exit 0
fi

title=$(playerctl metadata --format "{{title}}" 2>/dev/null | cut -c 1-28)
artist=$(playerctl metadata --format "{{artist}}" 2>/dev/null | cut -c 1-24)
player=$(playerctl metadata --format "{{playerName}}" 2>/dev/null)

if [[ -z "$title" ]]; then
    exit 0
fi

# Círculo giratorio que rota continuamente al ritmo del tiempo/música
circles=( "◐" "◓" "◑" "◒" )
sec=$(date +%s)
circle_icon="${circles[$(( sec % 4 ))]}"

# Icono según el reproductor
brand_icon="󰎆"
if [[ "$player" =~ [sS]potify ]]; then
    brand_icon=""
elif [[ "$player" =~ [fF]irefox|[zZ]en ]]; then
    brand_icon=""
fi

if [[ -n "$artist" ]]; then
    echo "<span foreground=\"#00ffcc\">$circle_icon $brand_icon</span>  <b>$title</b> <span foreground=\"#8892b0\">• $artist</span>"
else
    echo "<span foreground=\"#00ffcc\">$circle_icon $brand_icon</span>  <b>$title</b>"
fi
