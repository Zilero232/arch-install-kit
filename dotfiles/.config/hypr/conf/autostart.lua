-- Programs started once at login. https://wiki.hypr.land/Configuring/Autostart/

local programs = require("conf.programs")

hl.on("hyprland.start", function()
    -- --- Scaling for X11 apps (see xwayland in misc.lua) ---
    local monitor = hl.get_active_monitor()
    local scale = string.format("%.2f", monitor and monitor.scale or 1)
    hl.env("STEAM_FORCE_DESKTOPUI_SCALING", scale)
    local java_scale = "JAVA_TOOL_OPTIONS=-Dsun.java2d.uiScale=" .. scale .. " "

    -- --- Session services ---
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("hyprctl setcursor Hackneyed-Dark-24px 24")
    hl.exec_cmd(programs.scripts .. "/gtk_theme.sh")

    -- --- Desktop shell ---
    hl.exec_cmd("waybar")
    -- swaync goes through its systemd unit: a notification sent before it starts
    -- D-Bus-activates that unit, and a second plain `swaync` would then fail.
    hl.exec_cmd("systemctl --user start swaync")
    hl.exec_cmd(programs.scripts .. "/wallpaper.sh")
    hl.exec_cmd("swayosd-server")           -- volume / brightness / caps lock pop-ups
    hl.exec_cmd("batsignal -b -w 20 -c 10") -- notifications at 20% and 10% battery
    hl.exec_cmd("udiskie")                   -- automount USB drives

    -- --- Clipboard: history, and keep copied text after the source app closes ---
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("wl-clip-persist --clipboard regular")

    -- --- Apps ---
    hl.exec_cmd(programs.messenger .. " -startintray")
    hl.exec_cmd(java_scale .. "incy --autostart") -- Java/X11 app, scales itself
end)
