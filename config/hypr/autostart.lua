local home = os.getenv("HOME")

hl.on("hyprland.start", function ()
    -- Agente de autenticación polkit
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

    -- Demonio de wallpapers para cambio dinámico
    hl.exec_cmd(home .. "/.local/bin/swww-daemon")

    -- Quickshell (Dynamic Island)
    hl.exec_cmd("quickshell")

    -- Inicialización de fondo y sincronización de tema
    hl.exec_cmd(home .. "/.config/hypr/scripts/wallchange.sh")

    -- Demonio de inactividad y bloqueo automático (hypridle)
    hl.exec_cmd("hypridle")
end)
