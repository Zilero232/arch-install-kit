-- Misc behavior, rendering and debug. https://wiki.hypr.land/Configuring/Variables/#misc

hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 2, -- adaptive sync for fullscreen windows only
        mouse_move_enables_dpms = true,
        enable_swallow = false,
        focus_on_activate = false,
        initial_workspace_tracking = 0,
        middle_click_paste = false,
        enable_anr_dialog = true,
        anr_missed_pings = 15,             -- default 5 flags slow apps too eagerly
        allow_session_lock_restore = true, -- a crashed hyprlock can be restarted instead of a red screen
    },

    render = {
        direct_scanout = 2, -- only for windows that declare game content: less input lag in games
    },

    -- X11 apps draw at native resolution instead of being upscaled (blurry);
    -- autostart.lua tells Java and Steam to scale themselves
    xwayland = {
        force_zero_scaling = true,
    },

    -- Logging stays off: writing every debug line (each touchpad event included)
    -- blocks the compositor loop and makes animations stutter
    debug = {
        disable_logs = true,
        vfr = true,
    },
})
