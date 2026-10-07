#!/usr/bin/env bash
# ==============================================================================
# Sincronizador de Tema y Fondo de Pantalla para SDDM
# Aplica el fondo actual al gestor de inicio SDDM
# ==============================================================================

SDDM_CONF_DIR="/etc/sddm.conf.d"
THEME_DIR="/usr/share/sddm/themes/maldives"
WALLPAPER="$(cat "$HOME/.cache/wal/wal" 2>/dev/null || echo "$HOME/Pictures/Wallpapers/cyber_city_ai.jpg")"

if [[ $EUID -ne 0 ]]; then
    echo "Este script requiere permisos de administrador."
    echo "Ejecútalo con: sudo $0"
    exit 1
fi

mkdir -p "$SDDM_CONF_DIR"

# 1. Establecer tema moderno
cat << 'EOF' > "$SDDM_CONF_DIR/theme.conf"
[Theme]
Current=maldives
CursorTheme=Adwaita
EOF

# 2. Copiar wallpaper actual como fondo de SDDM
if [[ -f "$WALLPAPER" && -d "$THEME_DIR" ]]; then
    cp "$WALLPAPER" "$THEME_DIR/background.jpg"
    chmod 644 "$THEME_DIR/background.jpg"
    echo "✓ Fondo de pantalla de SDDM actualizado con éxito."
fi

echo "✓ Tema de SDDM aplicado correctamente."
