#!/usr/bin/env bash
# Opens wlogout with vertical margins sized to the focused monitor (Super+X).
set -euo pipefail

readonly BUTTONS_PER_ROW=5
readonly MARGIN_RATIO=0.27

# Margin in logical pixels: a fixed share of the focused monitor's height
vertical_margin() {
    local height scale
    read -r height scale < <(hyprctl -j monitors | jq -r '.[] | select(.focused) | "\(.height) \(.scale)"')
    awk -v h="$height" -v s="$scale" -v r="$MARGIN_RATIO" 'BEGIN { printf "%d", h * r / s }'
}

main() {
    local margin
    margin=$(vertical_margin)
    wlogout -b "$BUTTONS_PER_ROW" -T "$margin" -B "$margin"
}

main "$@"
