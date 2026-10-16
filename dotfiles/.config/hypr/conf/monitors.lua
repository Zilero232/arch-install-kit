-- Monitors: every output gets its preferred mode, placed automatically.
-- https://wiki.hypr.land/Configuring/Monitors/
-- Scale "auto" follows pixel density: 1 on a 1080p screen, 1.6 on a 13" 2560x1600 laptop panel.

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})
