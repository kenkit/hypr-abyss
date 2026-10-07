local mainMod = "SUPER"

local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "pkill rofi || rofi -show drun -show-icons"
local navegador ="zen-browser"
-- Aplicaciones y control de ventanas
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(navegador))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprctl dispatch exit"))
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("zeditor"))


-- Captura directa de toda la pantalla al portapapeles con Super + Print
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grim - | wl-copy"))

local home = os.getenv("HOME")

-- Atajo para cambiar Wallpaper + Recargar tema dinámico
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/wallchange.sh"))

-- Atajo para abrir Selector Visual de Fondos (Super + V)
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("quickshell ipc call wallpaper toggle"))

-- Atajo para abrir Centro de Control y Notificaciones (Super + N)
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("quickshell ipc call controlcenter toggle"))

-- Atajo para abrir Menú de Energía y Apagado (Super + P)
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("quickshell ipc call powermenu toggle"))

-- Navegación con flechas
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces 1 al 10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Multimedia y Brillo (con OSD interactivo estilo Dolphin)
local volScript    = home .. "/.config/hypr/scripts/volumecontrol.sh"
local brightScript = home .. "/.config/hypr/scripts/brightness.sh"

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(volScript .. " --inc"),        { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(volScript .. " --dec"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(volScript .. " --toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(volScript .. " --toggle-mic"), { locked = true, repeating = true })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(brightScript .. " up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(brightScript .. " down"), { locked = true, repeating = true })

