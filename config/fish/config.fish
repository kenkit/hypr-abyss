# Quitar mensaje inicial de bienvenida
set -g fish_greeting ""

# Ejecutar fastfetch solo en sesiones interactivas
if status is-interactive
    fastfetch
end
