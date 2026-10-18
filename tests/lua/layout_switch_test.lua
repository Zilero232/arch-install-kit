-- Tests for dotfiles/.config/hypr/conf/layout_switch.lua with a stub `hl` (no Hyprland needed).
-- Usage: lua tests/lua/layout_switch_test.lua   (exits 1 when a scenario fails)

local script_dir = arg[0]:match("^(.*)/") or "."
local CONFIG = script_dir .. "/../../dotfiles/.config/hypr/conf/layout_switch.lua"

-- XKB keycodes (evdev code + 8), as the config uses them
local KEY = {
    ctrl = 37, ctrl_r = 105,
    alt = 64, alt_r = 108,
    shift = 50, shift_r = 62,
    t = 36, a = 46, tab = 31,
}
local RELEASED, PRESSED = 0, 1

-- --- Stub hl ---

-- Loads the config fresh against a stub hl; returns a key(), a switches() counter
local function load_config()
    local handler
    local commands = {}

    _G.hl = {
        on = function(event, fn)
            assert(event == "input.keyboard.key", "unexpected event " .. event)
            handler = fn
        end,
        exec_cmd = function(cmd)
            commands[#commands + 1] = cmd
        end,
    }
    dofile(CONFIG)
    assert(handler, "the config registered no key handler")

    local function key(name, state)
        handler(assert(KEY[name], "no keycode for " .. name), nil, state)
    end

    local function switches()
        for _, cmd in ipairs(commands) do
            assert(cmd == "hyprctl switchxkblayout all next", "unexpected command " .. cmd)
        end
        return #commands
    end

    return key, switches
end

-- press/release helpers: "+ctrl" presses, "-ctrl" releases
local function play(key, events)
    for _, event in ipairs(events) do
        local state = event:sub(1, 1) == "+" and PRESSED or RELEASED
        key(event:sub(2), state)
    end
end

-- --- Scenarios ---

local scenarios = {
    { "Ctrl+Shift tap switches", { "+ctrl", "+shift", "-shift", "-ctrl" }, 1 },
    { "Shift+Ctrl (other order) switches", { "+shift", "+ctrl", "-ctrl", "-shift" }, 1 },
    { "Alt+Shift tap switches", { "+alt", "+shift", "-alt", "-shift" }, 1 },
    { "right Alt + right Shift switches", { "+alt_r", "+shift_r", "-shift_r", "-alt_r" }, 1 },
    { "Ctrl+Shift+T does not switch", { "+ctrl", "+shift", "+t", "-t", "-shift", "-ctrl" }, 0 },
    { "Alt+Shift+Tab does not switch", { "+alt", "+shift", "+tab", "-tab", "-shift", "-alt" }, 0 },
    { "Alt alone does not switch", { "+alt", "-alt" }, 0 },
    { "Shift alone does not switch", { "+shift", "-shift" }, 0 },
    { "typing capitals does not switch", { "+shift", "+a", "-a", "+t", "-t", "-shift" }, 0 },
    {
        "autorepeat while holding the chord still switches once",
        { "+ctrl", "+shift", "+shift", "+shift", "-shift", "-ctrl" },
        1,
    },
    { "two taps switch twice", { "+alt", "+shift", "-shift", "-alt", "+ctrl", "+shift", "-ctrl", "-shift" }, 2 },
    {
        "a key pressed before the chord does not block it",
        { "+a", "-a", "+ctrl", "+shift", "-shift", "-ctrl" },
        1,
    },
}

local failed = 0

local function check(name, ok, detail)
    if ok then
        print("ok     " .. name)
    else
        failed = failed + 1
        print("FAILED " .. name .. (detail and (": " .. detail) or ""))
    end
end

for _, scenario in ipairs(scenarios) do
    local name, events, expected = scenario[1], scenario[2], scenario[3]
    local key, switches = load_config()

    play(key, events)
    check(name, switches() == expected, ("expected %d switch(es), got %d"):format(expected, switches()))
end

-- The switch waits for the last key of the chord, not the first one let go
do
    local key, switches = load_config()

    play(key, { "+ctrl", "+shift", "-shift" })
    local early = switches()
    play(key, { "-ctrl" })
    check("switch happens only after the last key is up", early == 0 and switches() == 1,
        ("after first release %d, after last %d"):format(early, switches()))
end

print(("%d scenario(s), %d failed"):format(#scenarios + 1, failed))
os.exit(failed == 0 and 0 or 1)
