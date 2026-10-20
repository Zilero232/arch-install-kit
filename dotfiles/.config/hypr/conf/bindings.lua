-- Key bindings. https://wiki.hypr.land/Configuring/Binds/
-- hl.bind(keys, dispatcher, { description = … }) — descriptions show in `hyprctl binds`.
-- Flags: repeating = repeat while held, locked = works on the lock screen, mouse = mouse bind.

local programs = require("conf.programs")
local theme = require("theme")

local MAIN = "SUPER"

-- bind("SHIFT + F", …) means Super+Shift+F
local function bind(keys, dispatcher, description, flags)
    local options = flags or {}
    options.description = description
    hl.bind(MAIN .. " + " .. keys, dispatcher, options)
end

local function run(command)
    return hl.dsp.exec_cmd(command)
end

-- Cursor zoom: never below 1 (no zoom)
local function zoom_by(step)
    return function()
        local current = hl.get_config("cursor.zoom_factor")
        hl.config({ cursor = { zoom_factor = math.max(1, current + step) } })
    end
end

-- Game mode: no animations, blur or gaps, so the GPU (and the battery) only works for the game.
-- Animations on means game mode is off; a second press puts the theme.lua look back
local function toggle_game_mode()
    local turning_on = hl.get_config("animations.enabled")

    hl.config({
        animations = { enabled = not turning_on },
        decoration = { blur = { enabled = not turning_on } },
        general = {
            gaps_in = turning_on and 0 or theme.gaps_in,
            gaps_out = turning_on and 0 or theme.gaps_out,
        },
    })
    hl.dispatch(run("notify-send 'Game mode' '" .. (turning_on and "On" or "Off") .. "'"))
end

-- --- Launchers ---
bind("Return", run(programs.terminal), "Terminal")
bind("D", run(programs.menu), "App launcher")
-- Copy only when something was picked: an empty pick would otherwise wipe the clipboard
bind("V", run(
    "sel=$(cliphist list | rofi -dmenu -theme menu) && printf '%s' \"$sel\" | cliphist decode | wl-copy"
), "Clipboard history")
bind("C", run("hyprpicker -a"), "Color picker")
-- menu.rasi: a compact centered list instead of the fullscreen app grid
bind("period", run("rofi -show emoji -modes emoji -theme menu"), "Emoji picker")
bind("equal", run("rofi -show calc -modes calc -no-show-match -no-sort -theme menu"), "Calculator")
bind("slash", run(programs.scripts .. "/keybinds.sh"), "Keybinding cheat sheet")

-- --- Apps ---
bind("SHIFT + H", run(programs.browser), "Chrome")
bind("SHIFT + CTRL + H", run(programs.browser .. " --incognito"), "Chrome (incognito)")
bind("SHIFT + F", run(programs.browser_alt), "Firefox")
bind("SHIFT + CTRL + F", run(programs.browser_alt .. " --private-window"), "Firefox (private)")
bind("SHIFT + N", run(programs.file_manager), "File manager")
bind("SHIFT + C", run(programs.editor), "Editor")
bind("SHIFT + P", run("phpstorm"), "PhpStorm")
bind("SHIFT + T", run(programs.messenger), "Telegram")
bind("SHIFT + Z", run(programs.audio_mixer), "Audio mixer")
bind("SHIFT + V", run("virtualbox"), "VirtualBox")
bind("SHIFT + K", run(programs.terminal .. " -e calcurse"), "Calendar (calcurse)")

-- --- Session ---
-- Through logind, so hypridle's lock_cmd runs (it switches the layout to us first)
bind("L", run("loginctl lock-session"), "Lock screen")
bind("X", run(programs.scripts .. "/power_menu.sh"), "Power menu")
bind("SHIFT + Q", hl.dsp.exit(), "Exit Hyprland")

-- --- Desktop ---
bind("P", run("pkill -SIGUSR1 -x waybar"), "Toggle Waybar")
bind("N", run("swaync-client -t -sw"), "Notification center")
bind("W", run(programs.scripts .. "/wallpaper.sh random"), "Random wallpaper")
bind("CTRL + W", run(programs.scripts .. "/wallpaper.sh pick"), "Pick wallpaper")
bind("SHIFT + W", run(programs.scripts .. "/wallpaper.sh live"), "Live wallpaper")
bind("G", toggle_game_mode, "Game mode (no animations, blur, gaps)")
bind("comma", run("swaync-client --close-latest"), "Dismiss the latest notification")
bind("SHIFT + comma", run("swaync-client --close-all"), "Dismiss all notifications")

-- --- Screenshots ---
-- PrtSc works like Windows' Snipping Tool: select a region, annotate in satty, Enter copies and saves
hl.bind("Print", run("hyprshot -m region --raw | satty --filename -"), { description = "Screenshot region and annotate" })
hl.bind("SHIFT + Print", run("hyprshot -m output -m active --raw | satty --filename -"), { description = "Screenshot screen and annotate" })
bind("S", run("hyprshot -m output -m active --clipboard-only"), "Screenshot active monitor to clipboard")
bind("SHIFT + S", run("hyprshot -m region -o ~/Screenshots"), "Screenshot region to ~/Screenshots")
-- Copy only non-empty text: a cancelled selection or an empty result keeps the clipboard as it was
bind("SHIFT + O", run(
    "text=$(hyprshot -m region --raw | tesseract - - -l eng+rus 2>/dev/null); "
        .. "if [ -n \"$(printf '%s' \"$text\" | tr -d '[:space:]')\" ]; then "
        .. "printf '%s' \"$text\" | wl-copy && notify-send 'Text copied' 'OCR result is in the clipboard'; fi"
), "Copy text from a screen region (OCR)")

-- --- Screen recording ---
-- Press once to pick a region and record, again to stop; files go to ~/Videos
bind("SHIFT + R", run(
    "if pkill -INT -x wf-recorder; then notify-send 'Recording stopped' 'Saved to ~/Videos'; "
        .. "else region=$(slurp) && notify-send 'Recording…' 'Press Super+Shift+R again to stop' && "
        .. "wf-recorder -g \"$region\" -f ~/Videos/recording-$(date +%F_%H-%M-%S).mp4; fi"
), "Start / stop screen recording")

-- --- Zoom ---
bind("SHIFT + mouse_up", zoom_by(0.5), "Zoom in")
bind("SHIFT + mouse_down", zoom_by(-0.5), "Zoom out")
bind("CTRL + Z", function()
    hl.config({ cursor = { zoom_factor = 1 } })
end, "Reset zoom")

-- --- Windows ---
bind("Q", hl.dsp.window.close(), "Close window")
bind("F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Fullscreen")
bind("T", hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
bind("J", hl.dsp.layout("togglesplit"), "Toggle split")
bind("O", hl.dsp.workspace.toggle_special("overlay"), "Toggle overlay (chat and mixer)")
bind("Y", hl.dsp.window.pin({ action = "toggle" }), "Pin a floating window to every workspace")

-- Scratchpad: a hidden workspace for anything you want at hand (a terminal, notes)
bind("grave", hl.dsp.workspace.toggle_special("scratch"), "Toggle scratchpad")
bind("SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratch" }), "Move window to scratchpad")

-- Alt+Tab like on Windows: the next window comes to the front
hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end, { description = "Next window" })
hl.bind("ALT + SHIFT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end, { description = "Previous window" })

for _, direction in ipairs({ "left", "right", "up", "down" }) do
    bind(direction, hl.dsp.focus({ direction = direction }), "Focus " .. direction)
    bind("CTRL + " .. direction, hl.dsp.window.swap({ direction = direction }), "Swap window " .. direction)
end

bind("SHIFT + left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), "Shrink width", { repeating = true })
bind("SHIFT + right", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), "Grow width", { repeating = true })
bind("SHIFT + up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), "Shrink height", { repeating = true })
bind("SHIFT + down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), "Grow height", { repeating = true })

bind("mouse:272", hl.dsp.window.drag(), "Move window", { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), "Resize window", { mouse = true })

-- --- Workspaces ---
-- Keys 1-9 and 0 map to workspaces 1-10
for workspace = 1, 10 do
    local key = tostring(workspace % 10)
    bind(key, hl.dsp.focus({ workspace = workspace }), "Workspace " .. workspace)
    bind("SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }), "Move window to workspace " .. workspace)
end

bind("Tab", hl.dsp.focus({ workspace = "previous" }), "Previous workspace")
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Next workspace")
bind("mouse_up", hl.dsp.focus({ workspace = "e-1" }), "Previous workspace (wheel)")

-- --- Hardware keys ---
local function hardware(key, command, description, repeating)
    hl.bind(key, run(command), { description = description, locked = true, repeating = repeating })
end

-- swayosd changes the value and shows a pop-up with the new level
hardware("XF86AudioRaiseVolume", "swayosd-client --output-volume +2", "Volume up", true)
hardware("XF86AudioLowerVolume", "swayosd-client --output-volume -2", "Volume down", true)
hardware("XF86AudioMute", "swayosd-client --output-volume mute-toggle", "Mute")
hardware("XF86AudioMicMute", "swayosd-client --input-volume mute-toggle", "Mute microphone")

hardware("XF86MonBrightnessUp", "swayosd-client --brightness +10", "Brightness up", true)
hardware("XF86MonBrightnessDown", "swayosd-client --brightness -10", "Brightness down", true)

hardware("XF86AudioPlay", "playerctl play-pause", "Play/pause")
hardware("XF86AudioPause", "playerctl pause", "Pause")
hardware("XF86AudioNext", "playerctl next", "Next track")
hardware("XF86AudioPrev", "playerctl previous", "Previous track")
