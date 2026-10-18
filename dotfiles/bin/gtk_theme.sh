#!/usr/bin/env bash
# Applies the GTK theme from ~/.config/gtk-3.0/settings.ini through gsettings.
# GTK apps on Wayland read gsettings, not settings.ini, so the ini stays the single source.

set -euo pipefail

readonly SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
readonly SCHEMA="org.gnome.desktop.interface"

# Value of "key=value" from settings.ini
ini_value() {
    sed -n "s/^$1=//p" "$SETTINGS"
}

main() {
    # $(…) inside an argument hides sed's failure from set -e, so check the file up front
    if [[ ! -f "$SETTINGS" ]]; then
        echo "Error: $SETTINGS not found" >&2
        exit 1
    fi

    gsettings set "$SCHEMA" gtk-theme "$(ini_value gtk-theme-name)"
    gsettings set "$SCHEMA" icon-theme "$(ini_value gtk-icon-theme-name)"
    gsettings set "$SCHEMA" cursor-theme "$(ini_value gtk-cursor-theme-name)"
    gsettings set "$SCHEMA" cursor-size "$(ini_value gtk-cursor-theme-size)"
    gsettings set "$SCHEMA" font-name "$(ini_value gtk-font-name)"
    gsettings set "$SCHEMA" color-scheme prefer-dark
}

# Sourcing the file (tests) loads the functions without running main
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
