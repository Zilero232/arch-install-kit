-- Windows-style layout switch: tap Alt+Shift (or Ctrl+Shift) and let go.
-- xkb's grp:*_shift_toggle fires on press, so Ctrl+Shift+T or Alt+Shift+Tab would
-- switch the language too, and a lone Alt reaching an app opens its menu and steals
-- focus from the text field. Here the switch happens on release, and only if no
-- other key was pressed while the chord was held; apps see Alt+Shift, not a lone Alt.
-- Events: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Events/

-- XKB keycodes (evdev code + 8)
local MOD_KEYS = {
    [37] = true, [105] = true, -- Control_L, Control_R
    [64] = true, [108] = true, -- Alt_L, Alt_R
}
local SHIFT_KEYS = { [50] = true, [62] = true }  -- Shift_L, Shift_R
local RELEASED = 0
local PRESSED = 1

local mod_down = false
local shift_down = false
local armed = false -- Alt/Ctrl and Shift were held together and nothing else was pressed since

local function switch_layout()
    hl.exec_cmd("hyprctl switchxkblayout all next")
end

hl.on("input.keyboard.key", function(keycode, _, state)
    local is_mod = MOD_KEYS[keycode]
    local is_shift = SHIFT_KEYS[keycode]

    if not is_mod and not is_shift then
        if state == PRESSED then
            armed = false
        end
        return
    end

    if state == PRESSED then
        if is_mod then
            mod_down = true
        else
            shift_down = true
        end
        if mod_down and shift_down then
            armed = true
        end
    elseif state == RELEASED then
        if is_mod then
            mod_down = false
        else
            shift_down = false
        end
        -- Switch only once both keys are up: switching while Alt/Ctrl is still held
        -- leaves that modifier stuck in the focused app, so typing turns into shortcuts
        if armed and not mod_down and not shift_down then
            armed = false
            switch_layout()
        end
    end
end)
