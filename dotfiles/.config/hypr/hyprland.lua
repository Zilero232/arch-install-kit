-- Hyprland entry point. Wiki: https://wiki.hypr.land/Configuring/Start/
-- Every concern lives in its own module under conf/; colours and sizes live in theme.lua.
-- Check a change without applying it: Hyprland --verify-config -c ~/.config/hypr/hyprland.lua

require("conf.envs")
require("conf.monitors")
require("conf.autostart")
require("conf.input")
require("conf.layout_switch")
require("conf.looknfeel")
require("conf.misc")
require("conf.bindings")
require("conf.windowrules")
