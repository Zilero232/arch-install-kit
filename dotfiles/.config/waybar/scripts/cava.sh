#!/usr/bin/env bash
# Streams the cava audio spectrum for the custom/cava module while a media player is playing.
# Quiet parts of a video still show the bars; with nothing playing the line is empty, so waybar hides the module.

set -euo pipefail

readonly BARS="▁▂▃▄▅▆▇█"
readonly CONFIG_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-cava.conf"
readonly STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-cava-player"

# --- Cava ---

write_cava_config() {
    cat >"$CONFIG_FILE" <<EOF
[general]
framerate = 30
bars = 14

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF
}

# sed script that turns cava's digits 0-7 into bar glyphs and drops the separators
build_sed_script() {
    local script="s/;//g"
    local i

    for ((i = 0; i < ${#BARS}; i++)); do
        script+=";s/$i/${BARS:$i:1}/g"
    done

    echo "$script"
}

# --- Player state ---

# Keeps STATE_FILE at the status of the player that changed last (Playing, Paused, Stopped)
watch_players() {
    local status

    while read -r status; do
        echo "$status" >"$STATE_FILE"
    done < <(playerctl --all-players --follow status 2>/dev/null)
}

# Prints each frame while a player is playing; when it stops, one empty line hides the module
gate_on_player() {
    local frame
    local hidden=false

    while IFS= read -r frame; do
        if [[ "$(<"$STATE_FILE")" == Playing ]]; then
            echo "$frame"
            hidden=false
        elif [[ "$hidden" == false ]]; then
            echo ""
            hidden=true
        fi
    done
}

# Status right now, written before the frames start so the gate never reads a missing file
seed_player_state() {
    local status

    status=$(playerctl --all-players status 2>/dev/null | head -1) || true
    echo "${status:-Stopped}" >"$STATE_FILE"
}

# Stops the watcher and its playerctl; runs on exit, when waybar restarts this module
stop_watcher() {
    pkill -P "$WATCHER_PID" || true
    kill "$WATCHER_PID" 2>/dev/null || true
}

# --- Main ---

main() {
    write_cava_config
    seed_player_state

    # Global, not local: the EXIT trap runs after main has returned
    watch_players &
    WATCHER_PID=$!
    trap stop_watcher EXIT
    # Waybar signals the whole process group, which ends cava and the watcher too;
    # the EXIT trap covers the script being stopped on its own
    trap 'exit 0' TERM INT HUP

    cava -p "$CONFIG_FILE" | sed -u "$(build_sed_script)" | gate_on_player
}

# Sourcing the file (tests) loads the functions without running main
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
