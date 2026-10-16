-- Environment variables. https://wiki.hypr.land/Configuring/Environment-variables/

-- --- Toolkit backends ---
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- --- XDG session (wiki-recommended; harmless if Hyprland/uwsm already set them) ---
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- --- Qt ---
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- --- Cursor (Hyprland falls back to XCursor for non-hyprcursor themes) ---
hl.env("XCURSOR_THEME", "Hackneyed-Dark-24px")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
