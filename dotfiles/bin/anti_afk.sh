#!/usr/bin/env bash
# Keeps the session "active" by nudging the cursor every 30-60 s via Hyprland IPC.
# Usage: anti_afk.sh   (Ctrl+C to stop)

set -euo pipefail

readonly MAX_OFFSET=50

# "x y" while the cursor is moved away, so Ctrl+C during a nudge can put it back
NUDGE_ORIGIN=""

# --- Helpers ---

require() {
    local cmd

    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null; then
            echo "Error: $cmd is not installed" >&2
            exit 1
        fi
    done
}

# --- Cursor ---

random_offset() {
    echo $((RANDOM % (MAX_OFFSET * 2 + 1) - MAX_OFFSET))
}

move_cursor() {
    hyprctl dispatch "hl.dsp.cursor.move({ x = $1, y = $2 })" >/dev/null
}

# EXIT trap: undo a nudge that Ctrl+C interrupted
restore_cursor() {
    if [[ -n "$NUDGE_ORIGIN" ]]; then
        move_cursor "${NUDGE_ORIGIN% *}" "${NUDGE_ORIGIN#* }"
    fi
}

nudge_cursor() {
    local x y dx dy

    read -r x y < <(hyprctl -j cursorpos | jq -r '"\(.x) \(.y)"')
    dx=$(random_offset)
    dy=$(random_offset)

    echo "Moving cursor by $dx, $dy"
    NUDGE_ORIGIN="$x $y"
    move_cursor "$((x + dx))" "$((y + dy))"

    sleep 2
    move_cursor "$x" "$y"
    NUDGE_ORIGIN=""
}

# --- Main ---

main() {
    require hyprctl jq
    trap restore_cursor EXIT
    trap 'exit 130' INT TERM
    echo "Anti-AFK started. Press Ctrl+C to stop."

    while true; do
        nudge_cursor
        sleep $((RANDOM % 31 + 30))
    done
}

# Sourcing the file (tests) loads the functions without running main
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
