-- ==============================================================================
-- Hyprland Theme Configuration (Cyberpunk Frosted Glass / Translucent)
-- ==============================================================================

-- Función para cargar dinámicamente la paleta de colores de Pywal
local function get_pywal_borders()
    local path = os.getenv("HOME") .. "/.cache/wal/colors.json"
    local f = io.open(path, "r")
    if f then
        local content = f:read("*a")
        f:close()
        local c4 = content:match('"color4"%s*:%s*"#([%x]+)"')
        local c5 = content:match('"color5"%s*:%s*"#([%x]+)"')
        if c4 and c5 then
            return { "rgba(" .. c4 .. "ee)", "rgba(" .. c5 .. "ee)" }
        end
    end
    -- Fallback por defecto si aún no se ha generado la paleta
    return { "rgba(00ffccee)", "rgba(bd93f9ee)" }
end

local active_colors = get_pywal_borders()

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,
        border_size = 2,

        col = {
            -- Borde dinámico con gradiente sincronizado con la paleta activa
            active_border   = { colors = active_colors, angle = 45 },
            inactive_border = "rgba(15172666)",
        },

        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding = 12,
        rounding_power = 2,

        -- Estética semitransparente global
        active_opacity   = 0.85,
        inactive_opacity = 0.72,

        shadow = {
            enabled      = true,
            range        = 14,
            render_power = 3,
            color        = 0x66000000,
        },

        -- Calibración de desenfoque tipo vidrio esmerilado (frosted glass)
        blur = {
            enabled           = true,
            size              = 8,
            passes            = 3,
            vibrancy          = 0.2,
            new_optimizations = true,
        },
    },

    dwindle = {
        preserve_split = true,
    },
})
