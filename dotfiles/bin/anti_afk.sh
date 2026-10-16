#!/usr/bin/env bash
# Keeps the session "active" by nudging the cursor every 30-60 s via Hyprland IPC.
# Usage: anti_afk.sh   (Ctrl+C to stop)

set -euo pipefail

readonly MAX_OFFSET=50

require() {
    local cmd
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null; then
            echo "Error: $cmd is not installed" >&2
            exit 1
        fi
    done
}

random_offset() {
    echo $((RANDOM % (MAX_OFFSET * 2 + 1) - MAX_OFFSET))
}

nudge_cursor() {
    local x y dx dy
    read -r x y < <(hyprctl -j cursorpos | jq -r '"\(.x) \(.y)"')
    dx=$(random_offset)
    dy=$(random_offset)

    echo "Moving cursor by $dx, $dy"
    hyprctl dispatch movecursor "$((x + dx))" "$((y + dy))" >/dev/null
    sleep 2
    hyprctl dispatch movecursor "$x" "$y" >/dev/null
}

main() {
    require hyprctl jq
    echo "Anti-AFK started. Press Ctrl+C to stop."

    while true; do
        nudge_cursor
        sleep $((RANDOM % 31 + 30))
    done
}

main "$@"
