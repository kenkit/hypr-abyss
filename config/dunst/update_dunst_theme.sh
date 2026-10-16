#!/usr/bin/env bash
# ==============================================================================
# Sincroniza el tema de Dunst con los colores de Pywal
# ==============================================================================

WAL_COLORS="$HOME/.cache/wal/colors.sh"
if [[ -f "$WAL_COLORS" ]]; then
    # shellcheck disable=SC1090
    source "$WAL_COLORS"
else
    background="#0d1117"
    foreground="#f0f6fc"
    color4="#00ffcc"
    color1="#ff5555"
    color2="#405A7C"
fi

DUNST_CONF="$HOME/.config/dunst/dunstrc"
mkdir -p "$HOME/.config/dunst"

cat <<EOF > "$DUNST_CONF"
[global]
    monitor = 0
    follow = mouse
    width = (280, 360)
    height = (60, 150)
    origin = top-right
    offset = (16, 48)
    scale = 0
    notification_limit = 5

    ### Barra de Progreso OSD ###
    progress_bar = true
    progress_bar_height = 6
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    progress_bar_corner_radius = 4
    highlight = "${color4:-#00ffcc}"

    ### Apariencia Frosted Glass ###
    transparency = 12
    separator_height = 2
    padding = 12
    horizontal_padding = 14
    text_icon_padding = 10
    frame_width = 1
    corner_radius = 14
    frame_color = "${color4:-#00ffcc}"
    separator_color = frame

    ### Tipografía y Formato ###
    font = Adwaita Sans 10, sans-serif 10
    line_height = 2
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = middle
    ignore_newline = false
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes

    ### Iconos ###
    enable_recursive_icon_lookup = true
    icon_theme = Papirus-Dark, Adwaita
    icon_position = left
    min_icon_size = 24
    max_icon_size = 44

    ### Historial y Sonido ###
    sticky_history = yes
    history_length = 30
    dmenu = /usr/bin/rofi -dmenu -p dunst:
    browser = /usr/bin/xdg-open
    always_run_script = false

    ### Acciones del Ratón ###
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[urgency_low]
    background = "${background:-#0d1117}"
    foreground = "${foreground:-#f0f6fc}"
    frame_color = "${color2:-#405A7C}"
    timeout = 4
    script = $HOME/.config/dunst/sound.sh

[urgency_normal]
    background = "${background:-#0d1117}"
    foreground = "${foreground:-#f0f6fc}"
    frame_color = "${color4:-#00ffcc}"
    timeout = 6
    script = $HOME/.config/dunst/sound.sh

[urgency_critical]
    background = "#1a0808"
    foreground = "#ff7b72"
    frame_color = "${color1:-#ff5555}"
    timeout = 0
    script = $HOME/.config/dunst/sound.sh
EOF

# Recarga Dunst sin matar el servicio systemd ni generar conflictos de D-Bus
dunstctl reload 2>/dev/null || killall -HUP dunst 2>/dev/null || true
