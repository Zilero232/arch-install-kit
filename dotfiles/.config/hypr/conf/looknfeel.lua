-- Gaps, borders, decoration, animations, layout. Values come from theme.lua.
-- https://wiki.hypr.land/Configuring/Variables/

local theme = require("theme")

hl.config({
    general = {
        layout = "dwindle",
        gaps_in = theme.gaps_in,
        gaps_out = theme.gaps_out,
        border_size = theme.border_size,
        resize_on_border = true,
        col = {
            active_border = theme.active_border,
            inactive_border = theme.inactive_border,
        },
    },

    decoration = {
        rounding = theme.rounding,
        active_opacity = 1.0,
        inactive_opacity = 0.8,
        fullscreen_opacity = 1.0,
        dim_inactive = false,
        dim_strength = 0.5,

        blur = {
            enabled = true,
            size = 16,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
        special_scale_factor = 0.8,
    },
})

-- --- Animations ---
-- https://wiki.hypr.land/Configuring/Animations/
local function animate(leaf, speed, style)
    hl.animation({ leaf = leaf, enabled = true, speed = speed, bezier = "default", style = style })
end

animate("windowsIn", 1)
animate("windowsOut", 4, "popin")
animate("windowsMove", 6, "slide")

animate("fadeIn", 6)
animate("fadeOut", 6)
animate("fadeSwitch", 6)
animate("fadeShadow", 6)
animate("fadeDim", 6)

animate("border", 4)
animate("workspaces", 6, "slide")
