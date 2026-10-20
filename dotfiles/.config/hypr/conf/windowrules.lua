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

-- --- Games: tearing for the lowest input lag, game content type for direct scanout ---
hl.window_rule({
    name = "games-immediate",
    match = { class = "^(steam_app_.*|gamescope)$" },
    immediate = true,
    content = "game",
})

hl.window_rule({
    name = "games-declared",
    match = { content = "game" },
    immediate = true,
})

-- --- Steam: small dialogs float instead of taking a tile ---
hl.window_rule({
    name = "steam-dialogs",
    match = { class = "steam", title = "^(Friends List|Steam Settings|Properties.*|Screenshot Manager)$" },
    float = true,
    center = true,
})

-- --- Anything fullscreen (games, videos) keeps the screen from dimming and locking ---
hl.window_rule({
    name = "fullscreen-no-idle",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})

-- --- AnyDesk: connection prompts and settings float, the main window stays tiled ---
hl.window_rule({
    name = "anydesk-dialogs",
    match = { class = "(?i)anydesk" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "anydesk-main",
    match = { class = "(?i)anydesk", title = "^AnyDesk$" },
    tile = true,
})

-- --- Screenshot editor: floating, centered ---
hl.window_rule({
    name = "satty-float",
    match = { class = "com.gabm.satty" },
    float = true,
    center = true,
})

-- --- Region picker: slurp's dim overlay must be gone before grim takes the shot ---
hl.layer_rule({
    name = "selection-no-anim",
    match = { namespace = "selection" },
    no_anim = true,
})

-- --- Picture-in-picture (Chrome, Firefox): a small window in the corner on every workspace ---
hl.window_rule({
    name = "picture-in-picture",
    match = { title = "^Picture[- ]in[- ][Pp]icture$" },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    size = { "monitor_w * 0.3", "monitor_h * 0.3" },
    move = { "monitor_w - window_w - 20", "monitor_h - window_h - 20" },
})
