#!/usr/bin/env bash
# Sets a random image from ~/Images as the hyprpaper wallpaper and saves it as the
# default for the next start (Super+W).

set -euo pipefail

readonly WALLPAPER_DIR="$HOME/Images"
readonly HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"

fail() {
    notify-send "Error" "$1" -u critical
    exit 1
}

pick_random_image() {
    local images=()
    mapfile -d '' images < <(find "$WALLPAPER_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -print0 2>/dev/null)

    if [[ ${#images[@]} -eq 0 ]]; then
        fail "No images found in $WALLPAPER_DIR"
    fi
    echo "${images[RANDOM % ${#images[@]}]}"
}

save_as_default() {
    local image=$1
    cat >"$HYPRPAPER_CONFIG" <<EOF
# Static wallpaper (fallback when linux-wallpaperengine is missing).
# Rewritten by ~/bin/random_wallpaper.sh. https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/

splash = false
ipc = true

wallpaper {
    monitor =
    path = $image
    fit_mode = cover
}
EOF
}

# Prefer live IPC; restart hyprpaper when it is not running or IPC fails
apply_now() {
    local image=$1
    if pgrep -x hyprpaper >/dev/null && hyprctl hyprpaper wallpaper ",$image" >/dev/null; then
        notify-send "Wallpaper" "Successfully changed" -i image
        return
    fi

    pkill -x hyprpaper || true
    hyprpaper >/dev/null 2>&1 &
    disown
    notify-send "Wallpaper" "Successfully changed (restarted hyprpaper)" -i image
}

main() {
    command -v hyprctl >/dev/null || fail "hyprctl is not installed"
    [[ -d "$WALLPAPER_DIR" ]] || fail "Images directory not found"

    local image
    image=$(pick_random_image)
    save_as_default "$image"
    apply_now "$image"
}

main "$@"
