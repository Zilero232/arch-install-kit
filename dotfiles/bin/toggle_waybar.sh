#!/usr/bin/env bash
# Shows Waybar if it is hidden, hides it if it is running (Super+P).

set -euo pipefail

fail() {
    notify-send "Error" "$1" -u critical
    exit 1
}

hide_waybar() {
    pkill -x waybar || fail "Failed to kill waybar"
    notify-send "Waybar" "Successfully hidden" -i window-close
}

show_waybar() {
    waybar >/dev/null 2>&1 &
    disown
    sleep 0.5 # give waybar time to start

    pgrep -x waybar >/dev/null || fail "Failed to launch waybar"
    notify-send "Waybar" "Successfully launched" -i window-new
}

main() {
    command -v waybar >/dev/null || fail "Waybar not found"

    if pgrep -x waybar >/dev/null; then
        hide_waybar
    else
        show_waybar
    fi
}

main "$@"
