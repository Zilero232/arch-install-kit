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


# --- Wallpapers ---

# hyprpaper must be running before waypaper can talk to it over IPC.
# Callers save the mode: a live fallback keeps "live" for the next login.
start_static() {
    pkill -x linux-wallpaper || true

    if ! pgrep -x hyprpaper >/dev/null; then
        hyprpaper >/dev/null 2>&1 &
        disown
        sleep 1
    fi
}

# Shows the picture instead of the scene; the saved mode decides what the next login tries
fall_back_to_static() {
    notify "$1"
    start_static
    waypaper --restore
}

start_live() {
    local monitor
    local args=()

    # Without the program live mode can't work, so the next login starts with the picture
    if ! command -v linux-wallpaperengine >/dev/null; then
        save_mode static
        fall_back_to_static "linux-wallpaperengine is not installed, keeping the picture"
        return 0
    fi

    # The scene may be missing only for now (Steam re-downloading it), so the choice stays live
    save_mode live
    if [[ ! -d "$WORKSHOP_DIR/$WALLPAPER_ID" ]]; then
        fall_back_to_static \
            "Wallpaper Engine scene $WALLPAPER_ID is not installed (Steam Workshop), keeping the picture"
        return 0
    fi

    # One --screen-root per connected monitor
    while read -r monitor; do
        args+=(--scaling "$SCALING" --screen-root "$monitor" --bg "$WALLPAPER_ID")
    done < <(hyprctl -j monitors | jq -r '.[].name')

    # No monitor yet: killing hyprpaper now would leave a black screen
    if ((${#args[@]} == 0)); then
        fall_back_to_static "No monitor found for the Wallpaper Engine scene, keeping the picture"
        return 0
    fi

    pkill -x hyprpaper || true
    pkill -x linux-wallpaper || true

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
                save_mode static
                waypaper --restore
            fi
            ;;
        random)
            start_static
            save_mode static
            waypaper --random
            ;;
        pick)
            start_static
            save_mode static
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
