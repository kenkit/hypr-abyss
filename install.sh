#!/usr/bin/env bash
# ==============================================================================
# 🌌 HYPR-ABYSS INSTALLER
# Automated Setup & Dependency Installer for Hyprland + Quickshell
# ==============================================================================
set -e

BOLD="\033[1m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}"
cat << "BANNER"
  _    _                  _ _                      
 | |  | |                | | |                     
 | |__| |_   _ _ __  _ __| | |__  _   _ ___ ___    
 |  __  | | | | '_ \| '__| | '_ \| | | / __/ __|   
 | |  | | |_| | |_) | |  | | |_) | |_| \__ \__ \   
 |_|  |_|\__, | .__/|_|  |_|_.__/ \__, |___/___/   
          __/ | |                  __/ |           
         |___/|_|                 |___/            
BANNER
echo -e "${RESET}"
echo -e "${BOLD}Welcome to the Hypr-Abyss Cyberpunk Setup Installer!${RESET}\n"

# 1. Check Distro & Package Manager
AUR_HELPER=""
if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
fi

PKG_MANAGER=""
if command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
fi

# 2. Ask or confirm dependency installation
INSTALL_DEPS=true
if [[ "$1" == "-y" || "$1" == "--yes" ]]; then
    INSTALL_DEPS=true
else
    read -rp "Install required packages and dependencies? [Y/n]: " ans
    if [[ "$ans" =~ ^[nN]$ ]]; then
        INSTALL_DEPS=false
    fi
fi

if [[ "$INSTALL_DEPS" == "true" ]]; then
    if [[ "$PKG_MANAGER" == "pacman" ]]; then
        echo -e "\n${BLUE}==> Installing core dependencies via pacman/AUR...${RESET}"
        PACKAGES=(
            hyprland quickshell kitty rofi dunst
            mpv socat yt-dlp playerctl
            python-pywal python-gobject
            pipewire wireplumber pamixer brightnessctl
            grim slurp wl-clipboard wf-recorder
            fastfetch fish swww
            ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts-emoji
        )
        
        if [[ -n "$AUR_HELPER" ]]; then
            $AUR_HELPER -S --needed --noconfirm "${PACKAGES[@]}" || true
        else
            sudo pacman -S --needed --noconfirm "${PACKAGES[@]}" || true
        fi
    else
        echo -e "${YELLOW}Non-Arch system detected. Please ensure you have installed:${RESET}"
        echo "hyprland, quickshell, mpv, socat, yt-dlp, pywal, kitty, rofi, dunst, swww, grim, slurp, wl-clipboard"
    fi
fi

# 3. Backup existing configs
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config.bak.$(date +%Y%m%d_%H%M%S)"

echo -e "\n${BLUE}==> Backing up existing configurations...${RESET}"
for item in quickshell hypr kitty fastfetch fish dunst rofi mpv; do
    if [ -d "$CONFIG_DIR/$item" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$CONFIG_DIR/$item" "$BACKUP_DIR/"
        echo -e "  ${YELLOW}Backed up: ~/.config/$item -> $BACKUP_DIR/$item${RESET}"
    fi
done

# 4. Copy configurations
echo -e "\n${BLUE}==> Deploying configurations to ~/.config...${RESET}"
mkdir -p "$CONFIG_DIR"
cp -r "$DOTFILES_DIR/config/"* "$CONFIG_DIR/"

# 5. Fix permissions
echo -e "\n${BLUE}==> Setting executable permissions on scripts...${RESET}"
chmod +x "$CONFIG_DIR/quickshell/scripts/"* 2>/dev/null || true
chmod +x "$CONFIG_DIR/hypr/scripts/"* 2>/dev/null || true
chmod +x "$CONFIG_DIR/dunst/"*.sh 2>/dev/null || true

# 6. Setup default Wallpapers directory & initial wallpaper
PICS_DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"
WALL_DIR="$PICS_DIR/Wallpapers"
mkdir -p "$WALL_DIR"
if [ -z "$(ls -A "$WALL_DIR" 2>/dev/null)" ]; then
    echo -e "${BLUE}==> Downloading starter Cyberpunk wallpaper...${RESET}"
    curl -sL "https://raw.githubusercontent.com/cybrcore/cybrpapers/main/wallpapers/akihabara/akihabara-1920x1080.jpg" -o "$WALL_DIR/cyberpunk-akihabara.jpg" 2>/dev/null || true
fi

# 7. Enable systemd user service for Quickshell if available
if command -v systemctl >/dev/null 2>&1; then
    echo -e "\n${BLUE}==> Reloading systemd user daemon...${RESET}"
    systemctl --user daemon-reload 2>/dev/null || true
fi

# 8. Done!
echo -e "\n${GREEN}${BOLD}✔ Installation completed successfully!${RESET}"
echo -e "${CYAN}Keybindings Cheat Sheet:${RESET}"
echo -e "  ${BOLD}Super + Y${RESET}       : Aura Music Player (YouTube stream & Mix & Favorites)"
echo -e "  ${BOLD}Super + B${RESET}       : Retro Desktop Clock Widget (draggable)"
echo -e "  ${BOLD}Super + N${RESET}       : Control Center & Notifications (WiFi, Bluetooth, Audio)"
echo -e "  ${BOLD}Super + P${RESET}       : Power Menu (Lock, Logout, Reboot, Shutdown)"
echo -e "  ${BOLD}Super + V${RESET}       : Wallpaper Selector (live preview)"
echo -e "  ${BOLD}Super + W${RESET}       : Random Wallpaper + Pywal Auto-Theming"
echo -e "  ${BOLD}Super + Z${RESET}       : Kitty Terminal"
echo -e "  ${BOLD}Super + A${RESET}       : Rofi Application Menu"
echo -e "  ${BOLD}Super + Q${RESET}       : Close Active Window"
echo -e "  ${BOLD}Super + R${RESET}       : Stop Music & Close Aura Player"
echo -e "  ${BOLD}Super + F${RESET}       : Toggle Fullscreen"
echo -e "\n${BOLD}Enjoy your Hypr-Abyss desktop!${RESET}\n"
