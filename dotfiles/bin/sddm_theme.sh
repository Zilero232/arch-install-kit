#!/usr/bin/env bash
# Lists or switches the SDDM Astronaut theme variant (astronaut, cyberpunk, pixel_sakura...).
# The variant is the ConfigFile line in the theme's metadata.desktop; a package update resets it.
# Usage: sddm_theme.sh list
#        sddm_theme.sh set <variant>

set -euo pipefail

readonly THEME_DIR=/usr/share/sddm/themes/sddm-astronaut-theme
readonly METADATA="$THEME_DIR/metadata.desktop"

# --- Messages ---

usage() {
    echo "Usage: sddm_theme.sh <list|set> [variant]"
    echo "  list           show available variants (* = current)"
    echo "  set <variant>  make <variant> the login screen"
}

notify() {
    local message=$1
    local icon=$2

    notify-send "$message" -i "$icon" || true
}

fail() {
    echo "$1" >&2
    notify "$1" "dialog-error"
    exit 1
}

# --- Theme ---

require_theme() {
    if [[ ! -f "$METADATA" ]]; then
        fail "SDDM Astronaut theme is not installed (sddm-astronaut-theme)."
    fi
}

current_variant() {
    sed -n 's|^ConfigFile=Themes/\(.*\)\.conf$|\1|p' "$METADATA"
}

list_variants() {
    local file name current

    current=$(current_variant)

    for file in "$THEME_DIR"/Themes/*.conf; do
        name=$(basename "$file" .conf)
        if [[ "$name" == "$current" ]]; then
            echo "* $name"
        else
            echo "  $name"
        fi
    done
}

set_variant() {
    local variant=$1

    if [[ ! -f "$THEME_DIR/Themes/$variant.conf" ]]; then
        fail "Variant '$variant' not found. Run 'sddm_theme.sh list' to see them."
    fi

    sudo sed -i "s|^ConfigFile=.*|ConfigFile=Themes/$variant.conf|" "$METADATA"
    echo "SDDM variant '$variant' has been set."
    notify "SDDM variant '$variant' has been set" "dialog-ok"
}

# --- Main ---

main() {
    require_theme

    case "${1:-}" in
        list)
            list_variants
            ;;
        set)
            if [[ $# -ne 2 ]]; then
                usage >&2
                exit 1
            fi
            set_variant "$2"
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
