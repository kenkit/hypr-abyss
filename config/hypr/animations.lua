hl.config({
    animations = {
        enabled = true,
    },
})

-- Curvas Bézier y resortes
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238, dampening = 24 })

-- Animaciones de ventanas y capas
hl.animation({ leaf = "global",        enabled = true, speed = 8,    bezier = "default" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.5,  spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.0,  spring = "easy", style = "popin 85%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2.0,  bezier = "linear", style = "popin 85%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.8,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.5,  bezier = "almostLinear" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.8,  bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 2.0,  bezier = "almostLinear", style = "fade" })
