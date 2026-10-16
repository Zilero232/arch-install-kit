-- Window rules, grouped by app. https://wiki.hypr.land/Configuring/Window-Rules/

-- --- Terminal: see-through ---
hl.window_rule({
    name = "opacity-terminal",
    match = { class = "Alacritty" },
    opacity = "0.7",
})

-- --- Chat and mixer: fullscreen on the special "overlay" workspace (Super+O) ---
hl.window_rule({
    name = "communication-overlay",
    match = { class = "(org.telegram.desktop|org.pulseaudio.pavucontrol)" },
    fullscreen = true,
    workspace = "special:overlay",
})

-- --- Screenshot editor: floating, centred ---
hl.window_rule({
    name = "satty-float",
    match = { class = "com.gabm.satty" },
    float = true,
    center = true,
})
