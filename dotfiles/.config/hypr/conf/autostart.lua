-- Programs started once at login. https://wiki.hypr.land/Configuring/Autostart/

local programs = require("conf.programs")

hl.on("hyprland.start", function()
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
    hl.exec_cmd("incy --autostart")
end)
