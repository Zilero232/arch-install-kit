#!/usr/bin/env bash
# Prints pending pacman/AUR update counts as waybar JSON (custom/updates module).
# Needs checkupdates (pacman-contrib); yay is optional.

set -euo pipefail

readonly ICON_OFFICIAL="󰏗"
readonly ICON_AUR="󰚰"

count_official() {
    # checkupdates exits 2 when there is nothing to update
    { checkupdates 2>/dev/null || true; } | wc -l
}

count_aur() {
    if command -v yay >/dev/null; then
        { yay -Qua 2>/dev/null || true; } | wc -l
    else
        echo 0
    fi
}

main() {
    if ! command -v checkupdates >/dev/null; then
        echo '{"text": ""}'
        exit 0
    fi

    local official aur parts=()
    official=$(count_official)
    aur=$(count_aur)

    if [[ $((official + aur)) -eq 0 ]]; then
        echo '{"text": ""}'
        exit 0
    fi

    if [[ "$official" -gt 0 ]]; then
        parts+=("$ICON_OFFICIAL $official")
    fi
    if [[ "$aur" -gt 0 ]]; then
        parts+=("$ICON_AUR $aur")
    fi

    # "\\n" stays literal on purpose: it is the newline escape inside the JSON tooltip
    printf '{"text": "%s", "tooltip": "Official: %s\\nAUR: %s"}\n' "${parts[*]}" "$official" "$aur"
}

main "$@"
