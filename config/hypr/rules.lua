-- ==============================================================================
-- Hyprland Window & Layer Rules (Translucent & Frosted Glass)
-- ==============================================================================

-- Ignorar eventos de maximizado forzado
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix para arrastres en XWayland
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
    },
    no_focus = true,
})

-- Reglas para Gestor de Archivos Thunar
hl.window_rule({
    name = "thunar-translucent",
    match = { class = "thunar|Thunar" },
    opacity = "0.85 0.72",
})

hl.window_rule({
    name = "thunar-dialogs-floating",
    match = {
        class = "thunar|Thunar",
        title = "Confirmación.*|Progreso.*|Propiedades.*|Atención.*|File Operation.*",
    },
    float = true,
})

-- Reglas para Terminal Kitty
hl.window_rule({
    name = "kitty-translucent",
    match = { class = "kitty" },
    opacity = "0.85 0.75",
})

-- Reglas de capa (Layer rules) para desenfoque en la superficie
hl.layer_rule({
    match = "quickshell",
    blur  = true,
})

hl.layer_rule({
    match = "rofi",
    blur  = true,
})
-- Zoom flotante para diálogos y controles de llamada
hl.window_rule({
    name  = "zoom-floating",
    match = { class = "^zoom$" },
    float = true,
})
-- Forzar flotante y centrado para diálogos modales y ventanas emergentes
hl.window_rule({
    match = { title = ".*(modificado|guardar|Save|Open|Confirm).*" },
    float = true,
    center = true,
})


-- Centrar cualquier ventana que esté flotando
hl.window_rule({
    match = { float = true },
    center = true,
})
