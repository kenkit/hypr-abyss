#!/usr/bin/env bash
# ==============================================================================
# Monitor Silencioso de Actualizaciones para Arch Linux (Hyprland / Dunst)
# ==============================================================================

ICON="$HOME/.config/hypr/icons/update.png"
[[ ! -f "$ICON" ]] && ICON="system-software-update"

UPDATE_SCRIPT="$HOME/.config/hypr/scripts/system_update.sh"

# Comprobar conexión a Internet silenciosamente
if ! ping -c 1 -W 2 archlinux.org >/dev/null 2>&1 && ! ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
    exit 0
fi

# Detección segura de actualizaciones oficiales y AUR (sin tocar base de datos local)
official_list=$(checkupdates 2>/dev/null || true)
aur_list=$(paru -Qua 2>/dev/null || true)

official_count=0
aur_count=0
[[ -n "$official_list" ]] && official_count=$(echo "$official_list" | grep -cve "^\s*$" || true)
[[ -n "$aur_list" ]] && aur_count=$(echo "$aur_list" | grep -cve "^\s*$" || true)
total_count=$(( official_count + aur_count ))

if (( total_count > 0 )); then
    summary="Updates Available"
    body="There are <b>${total_count}</b> updates ready (${official_count} official, ${aur_count} AUR)."

    # Enviar notificación interactiva con opciones de acción directa
    action=$(notify-send \
        -a "Arch Updater" \
        -i "$ICON" \
        -u normal \
        -t 15000 \
        -h string:x-dunst-stack-tag:arch_updates \
        -A "update=🚀 Update Now" \
        -A "view=📋 View Packages" \
        "$summary" \
        "$body" 2>/dev/null || true)

    case "$action" in
        "update"|"2")
            kitty --class arch-updater --title "Arch Linux System Update" -e "$UPDATE_SCRIPT" &
            ;;
        "view"|"1")
            kitty --class arch-updater --title "Pending Updates" -e bash -c "
                echo -e '\033[1;36m=== OFFICIAL PACKAGES ($official_count) ===\033[0m';
                echo '$official_list';
                echo '';
                echo -e '\033[1;35m=== AUR PACKAGES ($aur_count) ===\033[0m';
                echo '$aur_list';
                echo '';
                read -rp 'Start update now? [y/N]: ' ans;
                if [[ \$ans =~ ^[yYsS]$ ]]; then
                    '$UPDATE_SCRIPT';
                fi
            " &
            ;;
    esac
elif [[ "$1" == "--notify-always" || "$1" == "--manual" ]]; then
    notify-send \
        -a "Arch Updater" \
        -i "$ICON" \
        -u low \
        -t 3500 \
        -h string:x-dunst-stack-tag:arch_updates \
        "System Up to Date" \
        "All official and AUR packages are up to date."
fi
