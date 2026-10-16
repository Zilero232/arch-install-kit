-- Windows-style layout switch: tap Ctrl+Shift and let go.
-- xkb's grp:ctrl_shift_toggle fires on press, so Ctrl+Shift+T, Ctrl+Shift+Left or
-- Ctrl+Shift+C in a terminal would switch the language too. Here the switch happens
-- on release, and only if no other key was pressed while Ctrl+Shift was held.
-- Events: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Events/

-- XKB keycodes (evdev code + 8)
local CTRL_KEYS = { [37] = true, [105] = true }  -- Control_L, Control_R
local SHIFT_KEYS = { [50] = true, [62] = true }  -- Shift_L, Shift_R
local RELEASED = 0
local PRESSED = 1

local ctrl_down = false
local shift_down = false
local armed = false -- Ctrl and Shift were held together and nothing else was pressed

local function switch_layout()
    hl.exec_cmd("hyprctl switchxkblayout all next")
end

hl.on("input.keyboard.key", function(keycode, _, state)
    local is_ctrl = CTRL_KEYS[keycode]
    local is_shift = SHIFT_KEYS[keycode]

    if not is_ctrl and not is_shift then
        if state == PRESSED then
            armed = false
        end
        return
    end

    if state == PRESSED then
        if is_ctrl then
            ctrl_down = true
        else
            shift_down = true
        end
        armed = ctrl_down and shift_down
    elseif state == RELEASED then
        if armed then
            switch_layout()
            armed = false
        end
        if is_ctrl then
            ctrl_down = false
        else
            shift_down = false
        end
    end
end)
