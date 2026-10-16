#!/usr/bin/env bash
# Runs the interactive setup of the SDDM Astronaut login theme.
set -euo pipefail

readonly SETUP=/usr/share/sddm/themes/sddm-astronaut-theme/setup.sh

report() {
    local message=$1 icon=$2
    echo "$message"
    notify-send "$message" -i "$icon" || true
}

main() {
    if [[ ! -f "$SETUP" ]]; then
        report "SDDM Astronaut theme is not installed. Please install it first." "dialog-error"
        exit 1
    fi

    if bash "$SETUP"; then
        report "SDDM Astronaut theme has been set successfully." "dialog-ok"
    else
        report "Failed to set SDDM Astronaut theme." "dialog-error"
        exit 1
    fi
}

main "$@"
