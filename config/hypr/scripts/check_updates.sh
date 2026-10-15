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
    summary="Actualizaciones Disponibles"
    body="Hay <b>${total_count}</b> paquetes listos para actualizar (${official_count} oficiales, ${aur_count} AUR)."

    # Enviar notificación interactiva con opciones de acción directa
    action=$(notify-send \
        -a "Actualizador de Arch" \
        -i "$ICON" \
        -u normal \
        -t 15000 \
        -h string:x-dunst-stack-tag:arch_updates \
        -A "update=🚀 Actualizar Ahora" \
        -A "view=📋 Ver Paquetes" \
        "$summary" \
        "$body" 2>/dev/null || true)

    case "$action" in
        "update"|"2")
            kitty --class arch-updater --title "Actualización del Sistema Arch Linux" -e "$UPDATE_SCRIPT" &
            ;;
        "view"|"1")
            kitty --class arch-updater --title "Lista de Actualizaciones Pendientes" -e bash -c "
                echo -e '\033[1;36m=== PAQUETES OFICIALES ($official_count) ===\033[0m';
                echo '$official_list';
                echo '';
                echo -e '\033[1;35m=== PAQUETES AUR ($aur_count) ===\033[0m';
                echo '$aur_list';
                echo '';
                read -rp '¿Deseas iniciar la actualización ahora? [s/N]: ' ans;
                if [[ \$ans =~ ^[sS]$ ]]; then
                    '$UPDATE_SCRIPT';
                fi
            " &
            ;;
    esac
elif [[ "$1" == "--notify-always" || "$1" == "--manual" ]]; then
    notify-send \
        -a "Actualizador de Arch" \
        -i "$ICON" \
        -u low \
        -t 3500 \
        -h string:x-dunst-stack-tag:arch_updates \
        "Sistema al Día" \
        "Todos los paquetes oficiales y de AUR están en su última versión."
fi
