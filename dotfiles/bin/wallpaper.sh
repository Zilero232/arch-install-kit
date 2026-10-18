#!/usr/bin/env bash
# Sets the desktop background: a live Wallpaper Engine scene or a static picture via hyprpaper + waypaper.
# The last choice is remembered, so the next login starts the same kind of wallpaper.
# Usage: wallpaper.sh           restore the last mode (autostart)
#        wallpaper.sh random    random static picture from ~/Images (Super+W)
#        wallpaper.sh pick      choose a static picture in waypaper (Super+Ctrl+W)
#        wallpaper.sh live      animated Wallpaper Engine scene (Super+Shift+W)

set -euo pipefail

readonly WALLPAPER_ID="3162872709" # Steam Workshop id
readonly SCALING="fill"
readonly STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper-mode"
readonly WORKSHOP_DIR="$HOME/.local/share/Steam/steamapps/workshop/content/431960"

# --- Helpers ---

usage() {
    echo "Usage: wallpaper.sh [random|pick|live]"
    echo "  (none)  restore the last mode"
    echo "  random  random static picture from ~/Images"
    echo "  pick    choose a static picture in waypaper"
    echo "  live    animated Wallpaper Engine scene"
}

notify() {
    notify-send "Wallpaper" "$1" || true
}

# --- Mode ---

save_mode() {
    mkdir -p "$(dirname "$STATE_FILE")"
    echo "$1" >"$STATE_FILE"
}

saved_mode() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        # A fresh install has no Wallpaper Engine scene yet, so start with a picture
        echo static
    fi
}

# True when linux-wallpaperengine and the Workshop scene it renders are both there
can_go_live() {
    command -v linux-wallpaperengine >/dev/null && [[ -d "$WORKSHOP_DIR/$WALLPAPER_ID" ]]
}

# --- Wallpapers ---

# hyprpaper must be running before waypaper can talk to it over IPC
start_static() {
    pkill -x linux-wallpaper || true

    if ! pgrep -x hyprpaper >/dev/null; then
        hyprpaper >/dev/null 2>&1 &
        disown
        sleep 1
    fi

    save_mode static
}

start_live() {
    local monitor
    local args=()

    if ! can_go_live; then
        notify "Wallpaper Engine scene $WALLPAPER_ID is not installed (Steam Workshop), keeping the picture"
        start_static
        waypaper --restore
        return 0
    fi

    # One --screen-root per connected monitor
    while read -r monitor; do
        args+=(--scaling "$SCALING" --screen-root "$monitor" --bg "$WALLPAPER_ID")
    done < <(hyprctl -j monitors | jq -r '.[].name')

    pkill -x hyprpaper || true
    pkill -x linux-wallpaper || true
    save_mode live

    linux-wallpaperengine --silent "${args[@]}" >/dev/null 2>&1 &
    disown
}

# --- Main ---

main() {
    case "${1:-restore}" in
        restore)
            if [[ "$(saved_mode)" == live ]]; then
                start_live
            else
                start_static
                waypaper --restore
            fi
            ;;
        random)
            start_static
            waypaper --random
            ;;
        pick)
            start_static
            waypaper
            ;;
        live)
            start_live
            ;;
        *)
            usage >&2
            exit 1
            ;;
    esac
}

# Sourcing the file (tests) loads the functions without running main
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
