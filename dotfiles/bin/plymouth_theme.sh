#!/usr/bin/env bash
# Lists or switches the Plymouth boot splash theme (rebuilds the initramfs on set).
# Usage: plymouth_theme.sh list
#        plymouth_theme.sh set <theme-name>

set -euo pipefail

usage() {
    echo "Usage: plymouth_theme.sh <list|set> [theme-name]"
    echo "  list              show installed themes"
    echo "  set <theme-name>  make <theme-name> the default"
}

notify() {
    local message=$1 icon=$2
    notify-send "$message" -i "$icon" || true
}

fail() {
    echo "$1" >&2
    notify "$1" "dialog-error"
    exit 1
}

require_plymouth() {
    if ! command -v plymouth-set-default-theme >/dev/null; then
        fail "Plymouth is not installed. Please install plymouth first."
    fi
}

list_themes() {
    require_plymouth
    plymouth-set-default-theme -l
    notify "Available Plymouth themes listed" "dialog-information"
}

set_theme() {
    local theme=$1
    require_plymouth

    if ! plymouth-set-default-theme -l | grep -qx -- "$theme"; then
        fail "Theme '$theme' not found. Run 'plymouth_theme.sh list' to see installed themes."
    fi

    if ! sudo plymouth-set-default-theme -R "$theme"; then
        fail "Failed to set theme '$theme'."
    fi

    echo "Theme '$theme' has been set."
    notify "Theme '$theme' has been set" "dialog-ok"
}

main() {
    case "${1:-}" in
        list)
            list_themes
            ;;
        set)
            if [[ $# -ne 2 ]]; then
                usage
                fail "Invalid usage"
            fi
            set_theme "$2"
            ;;
        "")
            usage
            exit 1
            ;;
        *)
            usage
            fail "Unknown command: $1"
            ;;
    esac
}

main "$@"
