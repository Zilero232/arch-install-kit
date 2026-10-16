#!/usr/bin/env bash
# Starts the animated Wallpaper Engine background on every monitor; falls back to
# the static hyprpaper wallpaper when linux-wallpaperengine is not installed.

set -euo pipefail

readonly WALLPAPER_ID="3162872709" # Steam Workshop id
readonly SCALING="fill"

fail() {
    notify-send "Error" "$1" -u critical
    exit 1
}

main() {
    if ! command -v linux-wallpaperengine >/dev/null; then
        if command -v hyprpaper >/dev/null; then
            hyprpaper &
            sleep 1
            # Bring back the last wallpaper picked with waypaper (Super+W)
            waypaper --restore || true
            exit 0
        fi
        fail "Neither linux-wallpaperengine nor hyprpaper is installed"
    fi

    # One --screen-root per connected monitor
    local monitor args=()
    while read -r monitor; do
        args+=(--scaling "$SCALING" --screen-root "$monitor" --bg "$WALLPAPER_ID")
    done < <(hyprctl -j monitors | jq -r '.[].name')

    [[ ${#args[@]} -gt 0 ]] || fail "No monitors reported by hyprctl"
    exec linux-wallpaperengine --silent "${args[@]}"
}

main "$@"
