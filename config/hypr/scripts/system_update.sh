#!/usr/bin/env bash
# ==============================================================================
# Sistema de Actualización Segura para Arch Linux
# "Sin malograr el sistema": validación previa, prevención de fallos y limpieza
# ==============================================================================
set -e

CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BOLD="\033[1m"
RESET="\033[0m"

clear
echo -e "${CYAN}==================================================================${RESET}"
echo -e "${CYAN}        🛡️  ACTUALIZADOR SEGURO DE ARCH LINUX & HYPRLAND           ${RESET}"
echo -e "${CYAN}==================================================================${RESET}"
echo ""

# 1. Comprobar conexión a Internet
echo -e "${BOLD}[1/7] Verificando conectividad con los servidores...${RESET}"
if ! ping -c 1 -W 3 archlinux.org >/dev/null 2>&1 && ! ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1; then
    echo -e "${RED}[ERROR] No hay conexión a Internet. Cancelando para evitar errores.${RESET}"
    read -rp "Presiona [Enter] para salir..."
    exit 1
fi
echo -e "${GREEN}  ✓ Conexión establecida correctamente.${RESET}"
echo ""

# 2. Comprobar bloqueo huérfano de base de datos (/var/lib/pacman/db.lck)
echo -e "${BOLD}[2/7] Comprobando integridad de la base de datos de Pacman...${RESET}"
if [[ -f /var/lib/pacman/db.lck ]]; then
    if pgrep -x pacman >/dev/null || pgrep -x paru >/dev/null; then
        echo -e "${RED}[ERROR] Hay otro proceso de actualización en segundo plano.${RESET}"
        read -rp "Presiona [Enter] para salir..."
        exit 1
    else
        echo -e "${YELLOW}[AVISO] Se detectó un archivo /var/lib/pacman/db.lck huérfano.${RESET}"
        read -rp "¿Deseas eliminar el bloqueo huérfano de forma segura? [s/N]: " del_lck
        if [[ "$del_lck" =~ ^[sS]$ ]]; then
            sudo rm -f /var/lib/pacman/db.lck
            echo -e "${GREEN}  ✓ Bloqueo eliminado con éxito.${RESET}"
        else
            echo -e "${RED}Cancelado por el usuario.${RESET}"
            exit 1
        fi
    fi
else
    echo -e "${GREEN}  ✓ Base de datos desbloqueada y lista.${RESET}"
fi
echo ""

# 3. Comprobar espacio suficiente en disco raíz (/)
echo -e "${BOLD}[3/7] Verificando espacio disponible en disco...${RESET}"
free_space_kb=$(df --output=avail / | tail -n 1 | tr -d ' ')
free_space_gb=$(( free_space_kb / 1024 / 1024 ))
if (( free_space_gb < 3 )); then
    echo -e "${RED}[ALERTA CRÍTICA] Solo tienes ${free_space_gb} GB libres en la partición raíz (/).${RESET}"
    echo -e "${RED}Actualizar ahora podría colapsar el sistema por falta de espacio.${RESET}"
    read -rp "¿Quieres abortar para liberar espacio? [S/n]: " abort_space
    if [[ ! "$abort_space" =~ ^[nN]$ ]]; then
        echo -e "${YELLOW}Ejecutando paccache para intentar liberar espacio previo...${RESET}"
        sudo paccache -r -k 1 || true
        free_space_kb=$(df --output=avail / | tail -n 1 | tr -d ' ')
        free_space_gb=$(( free_space_kb / 1024 / 1024 ))
        if (( free_space_gb < 3 )); then
            echo -e "${RED}Espacio aún insuficiente (${free_space_gb} GB). Cancela y limpia archivos.${RESET}"
            read -rp "Presiona [Enter] para salir..."
            exit 1
        fi
    fi
fi
echo -e "${GREEN}  ✓ Espacio seguro disponible: ${free_space_gb} GB libres en disco.${RESET}"
echo ""

# 4. Análisis de paquetes pendientes y advertencias críticas
echo -e "${BOLD}[4/7] Analizando paquetes pendientes...${RESET}"
official_updates=$(checkupdates 2>/dev/null || true)
aur_updates=$(paru -Qua 2>/dev/null || true)

official_count=0
aur_count=0
[[ -n "$official_updates" ]] && official_count=$(echo "$official_updates" | wc -l)
[[ -n "$aur_updates" ]] && aur_count=$(echo "$aur_updates" | wc -l)
total_count=$(( official_count + aur_count ))

if (( total_count == 0 )); then
    echo -e "${GREEN}✨ ¡Tu sistema ya está 100% al día! No hay actualizaciones pendientes.${RESET}"
    echo ""
    read -rp "Presiona [Enter] para salir..."
    exit 0
fi

echo -e "${CYAN}Total de actualizaciones: ${BOLD}${total_count}${RESET} (${official_count} oficiales, ${aur_count} AUR)"
echo ""

# Detectar componentes críticos
critical_found=()
critical_regex="(linux|linux-lts|systemd|glibc|mesa|intel-media-driver|hyprland|sddm|wireplumber|pipewire)"
while IFS= read -r line; do
    pkg_name=$(echo "$line" | awk '{print $1}')
    if [[ "$pkg_name" =~ ^${critical_regex}$ ]]; then
        critical_found+=("$pkg_name")
    fi
done <<< "$official_updates"

if (( ${#critical_found[@]} > 0 )); then
    echo -e "${YELLOW}⚠️  ATENCIÓN: Se actualizarán componentes clave del sistema:${RESET}"
    for c in "${critical_found[@]}"; do
        echo -e "   • ${YELLOW}${c}${RESET}"
    done
    echo -e "${YELLOW}   (Es recomendable no apagar el equipo durante el proceso).${RESET}"
    echo ""
fi

# 5. Confirmación del usuario
read -rp "¿Deseas proceder con la actualización completa ahora? [S/n]: " proceed
if [[ "$proceed" =~ ^[nN]$ ]]; then
    echo -e "${YELLOW}Operación cancelada por el usuario.${RESET}"
    exit 0
fi
echo ""

# 6. Ejecutar actualización atómica completa
echo -e "${BOLD}[5/7] Descargando e instalando actualizaciones de forma segura...${RESET}"
echo -e "${CYAN}------------------------------------------------------------------${RESET}"

if command -v paru >/dev/null 2>&1; then
    paru -Syu --combinedupgrade
else
    sudo pacman -Syu
fi

echo -e "${CYAN}------------------------------------------------------------------${RESET}"
echo -e "${GREEN}  ✓ Instalación de paquetes finalizada con éxito.${RESET}"
echo ""

# 7. Post-actualización: Detección de archivos .pacnew y mantenimiento
echo -e "${BOLD}[6/7] Verificando archivos de configuración (.pacnew)...${RESET}"
pacnew_files=$(sudo find /etc -name "*.pacnew" 2>/dev/null || true)
if [[ -n "$pacnew_files" ]]; then
    echo -e "${YELLOW}⚠️  Se detectaron archivos de configuración nuevos (.pacnew):${RESET}"
    echo "$pacnew_files"
    echo -e "${YELLOW}Tip: Puedes revisarlos cuando desees con la herramienta 'pacdiff'.${RESET}"
else
    echo -e "${GREEN}  ✓ No hay conflictos de configuración (.pacnew).${RESET}"
fi
echo ""

# 8. Comprobar si se requiere reinicio
echo -e "${BOLD}[7/7] Verificando necesidad de reinicio...${RESET}"
reboot_needed=false
if (( ${#critical_found[@]} > 0 )); then
    for c in "${critical_found[@]}"; do
        if [[ "$c" =~ ^(linux|linux-lts|systemd|glibc)$ ]]; then
            reboot_needed=true
            break
        fi
    done
fi

if [[ "$reboot_needed" == "true" ]]; then
    echo -e "${YELLOW}==================================================================${RESET}"
    echo -e "${YELLOW}🔄 Se ha actualizado el Núcleo (Kernel) o librerías base del sistema.${RESET}"
    echo -e "${YELLOW}Se recomienda reiniciar el equipo cuando termines tus tareas activas.${RESET}"
    echo -e "${YELLOW}==================================================================${RESET}"
else
    echo -e "${GREEN}==================================================================${RESET}"
    echo -e "${GREEN}🎉 ¡Sistema completamente actualizado y en perfecto estado!${RESET}"
    echo -e "${GREEN}No es necesario reiniciar el equipo.${RESET}"
    echo -e "${GREEN}==================================================================${RESET}"
fi

echo ""
read -rp "Presiona [Enter] para cerrar esta ventana..."
